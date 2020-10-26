module tabs;

import std.file:                 exists, mkdirRecurse, write;
import glib.Util:                Util;
import gtk.Main:                 Main;
import gtk.Widget:               Widget;
import gtk.HBox:                 HBox;
import gtk.Notebook:             Notebook;
import gtk.Label:                Label;
import gtk.Button:               Button;
import gtk.Image:                GtkIconSize;
import gio.TlsCertificate:       TlsCertificate, TlsCertificateFlags;
import glib.ErrorG:              ErrorG;
import gobject.ObjectG:          ObjectG;
import gobject.ParamSpec:        ParamSpec;
import webkit2.CookieManager:    CookieManager, CookieAcceptPolicy, CookiePersistentStorage;
import webkit2.NavigationAction: NavigationAction;
import webkit2.Settings:         Settings;
import webkit2.WebView:          LoadEvent, InsecureContentEvent, WebView;
import globals:                  programNameRaw;
import storage:                  UserSettings;

/**
 * Widget that represents the tabs of the browser.
 */
final class Tabs : Notebook {
    /**
     * Pack the structure and initialize all the pertitent locals.
     * It does not add any tabs.
     */
    this() {
        setScrollable(true);
    }

    /**
     * Adds a tab featuring the passed webview.
     * It will put it on focus, so it will be accessible with `getActive`.
     */
    void addTab(WebView view) {
        // Create webview and apply the settings.
        auto viewset = view.getSettings();
        auto viewcok = view.getContext.getCookieManager();

        viewset.setEnableSmoothScrolling(UserSettings.smoothScrolling);
        viewset.setEnablePageCache(UserSettings.pageCache);
        viewset.setEnableJavascript(UserSettings.javascript);
        viewset.setEnableSiteSpecificQuirks(UserSettings.sitequirks);
        viewcok.setAcceptPolicy(cast(CookieAcceptPolicy)UserSettings.cookiePolicy);

        // Set cookie storage path if needed.
        if (UserSettings.cookieKeep) {
            auto userdata  = Util.getUserDataDir();
            auto storepath = Util.buildFilename([userdata, programNameRaw]);
            auto store     = Util.buildFilename([storepath, "cookies.sqlite"]);

            if (!exists(store)) {
                mkdirRecurse(storepath);
                write(store, "");
            }

            viewcok.setPersistentStorage(store, CookiePersistentStorage.SQLITE);
        }

        view.addOnLoadChanged(&loadChangedSignal);
        view.addOnLoadFailed(&loadFailedSignal);
        view.addOnCreate(&createSignal);
        view.addOnNotify(&titleChangedSignal, "title");
        view.addOnInsecureContentDetected(&insecureContentSignal);
        view.addOnClose(&viewCloseSignal);
        viewcok.addOnChanged(&changedCookiesSignal);

        // Finally, pack the UI.
        auto title  = new Label("");
        auto button = new Button("window-close", GtkIconSize.BUTTON);
        button.addOnClicked(&closeTabSignal);

        auto titleBox = new HBox(false, 10);
        titleBox.packStart(title, false, false, 0);
        titleBox.packEnd(button,  false, false, 0);
        titleBox.showAll();

        auto index = appendPage(view, titleBox);
        showAll(); // We need the tabs to be visible for the switch to ocurr.
        setCurrentPage(index);
        setTabReorderable(view, true);
        setShowTabs(index != 0);
    }

    /**
     * Returns the current active webview.
     */
    WebView getCurrentWebview() {
        return cast(WebView)getNthPage(getCurrentPage());
    }

    // Called when the load status changed of some view.
    private void loadChangedSignal(LoadEvent event, WebView sender) {
        TlsCertificate      tls;
        TlsCertificateFlags flags;

        // Check for only HTTPS.
        if (UserSettings.forceHTTPS && event == LoadEvent.COMMITTED) {
            if (sender.getTlsInfo(tls, flags) == false) {
                sender.stopLoading();
            }
        }
    }

    // Called each time a load fails, that is, either internal error or
    // a call to `stopLoading`.
    // We will just check the reason for the stop and act accordingly.
    private bool loadFailedSignal(LoadEvent, string uri, ErrorG, WebView view) {
        TlsCertificate      tls;
        TlsCertificateFlags flags;

        // Check if we really are dealing with an HTTPS error.
        if (UserSettings.forceHTTPS && view.getTlsInfo(tls, flags) == false) {
            view.loadAlternateHtml("
                <!DOCTYPE html>
                <html>
                    <head>
                        <title>Cancelled</title>
                    </head>
                    <body>
                        <p>The TLS info of '" ~ uri ~ "' says no HTTPS.</p>
                    </body>
                </html>
            ", uri, null);
        }

        return false;
    }

    // Called when insecure content is found in a view.
    // That is, HTTP content on an HTTPS site.
    private void insecureContentSignal(InsecureContentEvent, WebView sender) {
        if (!UserSettings.insecureContent) {
            sender.loadAlternateHtml("
                <!DOCTYPE html>
                <html>
                    <head>
                        <title>Cancelled</title>
                    </head>
                    <body>
                        <p>Load was cancelled: Insecure content on HTTPS</p>
                    </body>
                </html>
            ", sender.getUri(), null);
        }
    }

    // Called when the view is tried to be closed, its our responsability to
    // destroy it.
    // Destroying it will also remove it from the tabs, so no problem there.
    private void viewCloseSignal(WebView view) {
        view.destroy();
    }

    // If this doesn't exist it wont save the cookies.
    // I do not know why.
    // I do not know who thought this was a good idea to leave this
    // undocumented on the official docs. Sigh.
    private void changedCookiesSignal(CookieManager) {
        return;
    }

    // Called when a new webview is requested.
    private WebView createSignal(NavigationAction action, WebView webview) {
        auto view = new WebView(webview);
        view.loadUri(action.getRequest.getUri);
        addTab(view);
        return view;
    }

    // Called when a close button of a tab is pressed.
    private void closeTabSignal(Button b) {
        const auto count = getNPages();
        foreach (i; 0..count) {
            auto view             = cast(WebView)getNthPage(i);
            auto titleBox         = cast(HBox)getTabLabel(view);
            auto titleBoxChildren = titleBox.getChildren().toArray!(Widget);
            auto titleBoxButton   = cast(Button)titleBoxChildren[1];

            if (titleBoxButton is b) {
                detachTab(view);
                view.tryClose();
                switch (getNPages()) {
                    case 1:
                        setShowTabs(false);
                        break;
                    case 0:
                        Main.quit();
                        break;
                    default:
                        break;
                }
                break;
            }
        }
    }

    // Called when the title of a webview changes.
    private void titleChangedSignal(ParamSpec, ObjectG obj) {
        auto sender           = cast(WebView)obj;
        auto titleBox         = cast(HBox)getTabLabel(sender);
        auto titleBoxChildren = titleBox.getChildren().toArray!(Widget);
        auto titleBoxLabel    = cast(Label)titleBoxChildren[0];
        titleBoxLabel.setText(sender.getTitle());
    }
}
