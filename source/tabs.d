module tabs;

import gtk.Main:                 Main;
import gtk.Widget:               Widget;
import gtk.HBox:                 HBox;
import gtk.Notebook:             Notebook;
import gtk.Label:                Label;
import gtk.Button:               Button;
import gtk.Image:                Image, IconSize;
import gio.TlsCertificate:       TlsCertificate, TlsCertificateFlags;
import glib.ErrorG:              ErrorG;
import gobject.ObjectG:          ObjectG;
import gobject.ParamSpec:        ParamSpec;
import webkit2.NavigationAction: NavigationAction;
import webkit2.WebView:          LoadEvent, WebView;
import customview:               CustomView;

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
    void addTab(CustomView view) {
        // Wire signals.
        view.addOnCreate(&createSignal);
        view.addOnNotify(&titleChangedSignal, "title");
        view.addOnClose(&viewCloseSignal);

        // Finally, pack the UI.
        auto title  = new Label("");
        auto button = new Button("window-close", IconSize.BUTTON);
        button.addOnClicked(&closeTabSignal);

        auto titleBox = new HBox(false, 10);
        if (view.isEphemeral()) {
            auto image  = new Image("dialog-password-symbolic", IconSize.SMALL_TOOLBAR);
            titleBox.packStart(image, false, false, 0);
        }

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

    // Called when the view is tried to be closed, its our responsability to
    // destroy it.
    // Destroying it will also remove it from the tabs, so no problem there.
    private void viewCloseSignal(WebView view) {
        view.destroy();
    }

    // Called when a new webview is requested.
    private WebView createSignal(NavigationAction action, WebView webview) {
        auto view = new CustomView(webview);
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
            auto titleBoxButton   = cast(Button)titleBoxChildren[view.isEphemeral() ? 2 : 1];

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
        auto titleBoxLabel    = cast(Label)titleBoxChildren[sender.isEphemeral() ? 1 : 0];
        titleBoxLabel.setText(sender.getTitle());
    }
}
