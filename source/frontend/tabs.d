module frontend.tabs;

import std.file:                       exists, mkdir, write;
import std.functional:                 toDelegate;
import glib.Util:                      Util;
import gtk.Main:                       Main;
import gtk.Widget:                     Widget;
import gtk.HBox:                       HBox;
import gtk.Notebook:                   Notebook;
import gtk.Label:                      Label;
import gtk.Button:                     Button;
import gtk.Image:                      GtkIconSize;
import backend.webkit.cookiemanager:   CookieManager, CookiePolicy, PersistentStorage;
import backend.webkit.webview:         LoadEvent, InsecureContentEvent, Webview;
import backend.webkit.webviewsettings: WebviewSettings;
import globals:                        programNameRaw;
import settings:                       BrowserSettings;

/**
 * Widget that represents the tabs of the browser.
 */
final class Tabs : Notebook {
    private BrowserSettings settings;

    /**
     * Pack the structure and initialize all the pertitent locals.
     * It does not add any tabs.
     */
    this() {
        settings = new BrowserSettings();
        setScrollable(true);
    }

    /**
     * Adds a tab featuring a webview set to the passed uri.
     * It will put it on focus, so it will be accessible with `getActive`.
     */
    void addTab(string uri) {
        // Create webview and apply the settings.
        auto view    = new Webview();
        auto viewset = view.settings;
        auto viewcok = view.context.cookieManager;

        view.uri                   = uri;
        viewset.smoothScrolling    = settings.smoothScrolling;
        viewset.pageCache          = settings.pageCache;
        viewset.javascript         = settings.javascript;
        viewset.siteSpecificQuirks = settings.sitequirks;
        viewcok.acceptPolicy       = cast(CookiePolicy)settings.cookiePolicy;

        // Set cookie storage path if needed.
        if (settings.cookieKeep) {
            auto userdata  = Util.getUserDataDir();
            auto storepath = Util.buildFilename([userdata, programNameRaw]);
            auto store     = Util.buildFilename([storepath, "cookies.txt"]);

            if (!exists(store)) {
                mkdir(storepath);
                write(store, "");
            }

            viewcok.setPersistentStorage(store, PersistentStorage.Text);
        }

        view.addOnLoadChanged(toDelegate(&loadChangedSignal));
        view.addOnInsecureContent(toDelegate(&insecureContentSignal));
        view.addOnDestroy(toDelegate(&viewDestroySignal));
        viewcok.addOnChanged(toDelegate(&changedCookiesSignal));

        // Finally, pack the UI.
        auto title  = new Label("");
        auto button = new Button("window-close", GtkIconSize.BUTTON);
        button.addOnClicked(toDelegate(&closeTabSignal));

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
    Webview getCurrentWebview() {
        return cast(Webview)getNthPage(getCurrentPage());
    }

    // Called when the load status changed of some view.
    private void loadChangedSignal(Webview sender, LoadEvent event) {
        // Change the title of the label.
        auto titleBox         = cast(HBox)getTabLabel(sender);
        auto titleBoxChildren = titleBox.getChildren().toArray!(Widget);
        auto titleBoxLabel    = cast(Label)titleBoxChildren[0];
        titleBoxLabel.setText(sender.title);

        // Check for only HTTPS.
        if (settings.forceHTTPS && event == LoadEvent.Committed) {
            if (sender.getTLSInfo() == false) {
                sender.loadAlternateHTML("
                    <!DOCTYPE html>
                    <html>
                        <head>
                            <title>Cancelled</title>
                        </head>
                        <body>
                            <p>Load was cancelled: TLS info says no HTML.</p>
                        </body>
                    </html>
                ", sender.uri, null);
            }
        }
    }

    // Called when insecure content is found in a view.
    // That is, HTTP content on an HTTPS site.
    private void insecureContentSignal(Webview sender, InsecureContentEvent) {
        if (!settings.insecureContent) {
            sender.loadAlternateHTML("
                <!DOCTYPE html>
                <html>
                    <head>
                        <title>Cancelled</title>
                    </head>
                    <body>
                        <p>Load was cancelled: Insecure content on HTTPS</p>
                    </body>
                </html>
            ", sender.uri, null);
        }
    }

    // The view may be deleated non inmidiately, we do not want the view to
    // keey loading and playing video or whatever on the meantime.
    private void viewDestroySignal(Widget view) {
        auto v = cast(Webview)view;
        v.loadAlternateHTML("", "", null);
    }

    // If this doesn't exist it wont save the cookies.
    // I do not know why.
    // I do not know who thought this was a good idea to leave this
    // undocumented on the official docs. Sigh.
    private void changedCookiesSignal(CookieManager) {
        return;
    }

    // Called when a close button of a tab is pressed.
    private void closeTabSignal(Button b) {
        const auto count = getNPages();
        foreach (i; 0..count) {
            auto view             = getNthPage(i);
            auto titleBox         = cast(HBox)getTabLabel(view);
            auto titleBoxChildren = titleBox.getChildren().toArray!(Widget);
            auto titleBoxButton   = cast(Button)titleBoxChildren[1];

            if (titleBoxButton is b) {
                detachTab(view);
                view.destroy();
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
}
