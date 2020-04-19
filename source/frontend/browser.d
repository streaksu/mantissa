module frontend.browser;

import std.functional: toDelegate;
import gtk.Main;
import gtk.MainWindow;
import gtk.HeaderBar;
import gtk.Button;
import gtk.Entry;
import gtk.Notebook;
import gtk.Label;
import gtk.Widget;
import gtk.VBox;
import gtk.HBox;
import gtk.Image;
import settings;
import frontend.about;
import frontend.preferences;
import backend.url;
import backend.webkit.webview;
import backend.webkit.webviewsettings;

private immutable windowWidth  = 1600;
private immutable windowHeight = 900;

class Browser : MainWindow {
    private Button          previousPage;
    private Button          nextPage;
    private Button          refresh;
    private Entry           urlBar;
    private Button          addTab;
    private Button          about;
    private Button          preferences;
    private Notebook        tabs;
    private Label[Webview]  tabLabels;
    private Webview[Button] tabClose;

    this(string homepage) {
        // Init ourselves.
        super("");
        setDefaultSize(windowWidth, windowHeight);

        // Initialize buttons and data.
        previousPage = new Button(StockID.GO_BACK, true);
        nextPage     = new Button(StockID.GO_FORWARD, true);
        refresh      = new Button(StockID.REFRESH, true);
        urlBar       = new Entry();
        urlBar.setHexpand(true);
        urlBar.setPlaceholderText("Enter address");
        addTab      = new Button(StockID.ADD, true);
        about       = new Button(StockID.ABOUT, true);
        preferences = new Button(StockID.PREFERENCES, true);
        tabs        = new Notebook();
        tabs.setScrollable(true);

        previousPage.addOnClicked(toDelegate(&previousSignal));
        nextPage.addOnClicked(toDelegate(&nextSignal));
        refresh.addOnClicked(toDelegate(&refreshSignal));
        urlBar.addOnActivate(toDelegate(&urlBarEnterSignal));
        addTab.addOnClicked(toDelegate(&newTabSignal));
        about.addOnClicked(toDelegate(&aboutSignal));
        preferences.addOnClicked(toDelegate(&preferencesSignal));
        tabs.addOnSwitchPage(toDelegate(&tabChangedSignal));

        // Pack the header.
        auto header = new HeaderBar();
        header.packStart(previousPage);
        header.packStart(nextPage);
        header.packStart(refresh);
        header.setCustomTitle(urlBar);
        header.packEnd(preferences);
        header.packEnd(about);
        header.packEnd(addTab);
        header.setShowCloseButton(true);

        // Pack header and final adjustements.
        setTitlebar(header);
        add(tabs);
        newTab(homepage);
        showAll();
    }

    private Webview getCurrentWebview() {
        auto current = tabs.getCurrentPage();
        return cast(Webview)(tabs.getNthPage(current));
    }

    private void newTab(string url) {
        auto title  = new Label("");
        auto button = new Button(StockID.CLOSE, true);
        button.addOnClicked(toDelegate(&closeTabSignal));

        auto content         = new Webview();
        auto contentSettings = new WebviewSettings();
        auto settings        = new BrowserSettings();
        contentSettings.smoothScrolling    = settings.smoothScrolling;
        contentSettings.pageCache          = settings.pageCache;
        contentSettings.javascript         = settings.javascript;
        contentSettings.siteSpecificQuirks = settings.sitequirks;

        content.uri      = url;
        content.settings = contentSettings;
        content.addOnLoadChanged(toDelegate(&loadChangedSignal));

        auto titleBox = new HBox(false, 10);
        titleBox.packStart(title, false, false, 0);
        titleBox.packEnd(button, false, false, 0);
        tabLabels[content] = title;
        tabClose[button]   = content;
        titleBox.showAll();

        auto index = tabs.appendPage(content, titleBox);
        tabs.showAll(); // We need the item to be visible for switching.
        tabs.setCurrentPage(index);
        tabs.setTabReorderable(content, true);
        tabs.setShowTabs(index != 0);
    }
    
    private void closeTabSignal(Button b) {
        tabs.detachTab(tabClose[b]);
        
        if (tabs.getNPages() == 0) {
            Main.quit();
        }
    }

    private void previousSignal(Button b) {
        auto widget = getCurrentWebview();
        widget.goBack();
    }

    private void nextSignal(Button b) {
        auto widget = getCurrentWebview();
        widget.goForward();
    }

    private void refreshSignal(Button b) {
        auto widget = getCurrentWebview();

        if (widget.isLoading) {
            widget.stopLoading();
        } else {
            widget.reload();
        }
    }

    private void urlBarEnterSignal(Entry entry) {
        auto widget = getCurrentWebview();
        widget.uri = urlFromUserInput(entry.getText());
    }

    private void newTabSignal(Button b) {
        auto settings = new BrowserSettings();
        newTab(settings.homepage);
    }

    private void aboutSignal(Button b) {
        new About();
    }

    private void preferencesSignal(Button b) {
        new Preferences();
    }

    private void tabChangedSignal(Widget contents, uint index, Notebook book) {
        auto uri = (cast(Webview)contents).uri;
        urlBar.setText(uri);
        urlBar.showAll();
    }

    private void loadChangedSignal(Webview sender, WebkitLoadEvent event) {
        tabLabels[sender].setText(sender.title);

        previousPage.setSensitive(sender.canGoBack);
        nextPage.setSensitive(sender.canGoForward);

        if (getCurrentWebview() != sender) {
            return;
        }

        this.urlBar.setText(sender.uri);

        final switch (event) {
            case WebkitLoadEvent.Started:
                urlBar.setProgressFraction(0.25);
                break;
            case WebkitLoadEvent.Redirected:
                urlBar.setProgressFraction(0.5);
                break;
            case WebkitLoadEvent.Committed:
                urlBar.setProgressFraction(0.75);
                break;
            case WebkitLoadEvent.Finished:
                urlBar.setProgressFraction(0);
                break;
        }

        if (sender.isLoading) {
            refresh.setImage(new Image(StockID.STOP, GtkIconSize.BUTTON));
        } else {
            refresh.setImage(new Image(StockID.REFRESH, GtkIconSize.BUTTON));
        }
    }
}
