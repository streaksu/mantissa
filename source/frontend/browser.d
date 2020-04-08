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
import globals;
import settings;
import frontend.about;
import frontend.preferences;
import backend.url;
import backend.webkit.webview;
import backend.webkit.webviewsettings;

private immutable WIN_WIDTH = 1600;
private immutable WIN_HEIGHT = 900;

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
        super(PROGRAM_NAME);
        this.setDefaultSize(WIN_WIDTH, WIN_HEIGHT);

        // Initialize buttons and data.
        this.previousPage = new Button(StockID.GO_BACK, true);
        this.nextPage     = new Button(StockID.GO_FORWARD, true);
        this.refresh      = new Button(StockID.REFRESH, true);
        this.urlBar       = new Entry();
        this.urlBar.setHexpand(true);
        this.urlBar.setPlaceholderText("Enter address");
        this.addTab      = new Button(StockID.ADD, true);
        this.about       = new Button(StockID.ABOUT, true);
        this.preferences = new Button(StockID.PREFERENCES, true);
        this.tabs        = new Notebook();
        this.tabs.setScrollable(true);

        this.previousPage.addOnClicked(toDelegate(&(this.previousSignal)));
        this.nextPage.addOnClicked(toDelegate(&(this.nextSignal)));
        this.refresh.addOnClicked(toDelegate(&(this.refreshSignal)));
        this.urlBar.addOnActivate(toDelegate(&(this.urlBarEnterSignal)));
        this.addTab.addOnClicked(toDelegate(&(this.newTabSignal)));
        this.about.addOnClicked(toDelegate(&(this.aboutSignal)));
        this.preferences.addOnClicked(toDelegate(&(this.preferencesSignal)));
        this.tabs.addOnSwitchPage(toDelegate(&(this.tabChangedSignal)));

        // Depending on the user, use the header bar or an extra bar.
        if (HEADERBAR) {
            auto header = new HeaderBar();
            header.packStart(this.previousPage);
            header.packStart(this.nextPage);
            header.packStart(this.refresh);
            header.setCustomTitle(this.urlBar);
            header.packEnd(this.preferences);
            header.packEnd(this.about);
            header.packEnd(this.addTab);
            header.setShowCloseButton(true);

            this.setTitlebar(header);
            this.add(this.tabs);
        } else {
            auto toolbar = new HBox(false, 10);
            toolbar.setMarginTop(10);
            toolbar.setMarginBottom(10);
            toolbar.setMarginLeft(10);
            toolbar.setMarginRight(10);
            toolbar.packStart(this.previousPage, false, true, 0);
            toolbar.packStart(this.nextPage, false, true, 0);
            toolbar.packStart(this.refresh, false, true, 0);
            toolbar.setCenterWidget(this.urlBar);
            toolbar.packEnd(this.preferences, false, true, 0);
            toolbar.packEnd(this.about, false, true, 0);
            toolbar.packEnd(this.addTab, false, true, 0);

            auto windowBox = new VBox(false, 0);
            windowBox.packStart(toolbar, false, true, 0);
            windowBox.packStart(this.tabs, true, true, 0);

            this.add(windowBox);
        }

        // Add a tab and show all.
        this.newTab(homepage);
        this.showAll();
    }

    private Webview getCurrentWebview() {
        auto current = this.tabs.getCurrentPage();
        return cast(Webview)(this.tabs.getNthPage(current));
    }

    private void newTab(string url) {
        auto title  = new Label("");
        auto button = new Button(StockID.CLOSE, true);
        button.addOnClicked(toDelegate(&(this.closeTabSignal)));

        auto content         = new Webview();
        auto contentSettings = new WebviewSettings();

        contentSettings.smoothScrolling    = SMOOTH_SCROLLING;
        contentSettings.pageCache          = PAGE_CACHE;
        contentSettings.javascript         = JAVASCRIPT;
        contentSettings.siteSpecificQuirks = SITEQUIRKS;

        content.uri      = url;
        content.settings = contentSettings;
        content.addOnLoadChanged(toDelegate(&(this.loadChangedSignal)));

        auto titleBox = new HBox(false, 10);
        titleBox.packStart(title, false, false, 0);
        titleBox.packEnd(button, false, false, 0);
        this.tabLabels[content] = title;
        this.tabClose[button]   = content;
        titleBox.showAll();

        auto index = this.tabs.appendPage(content, titleBox);
        this.tabs.showAll(); // We need the item to be visible for switching.
        this.tabs.setCurrentPage(index);
        this.tabs.setTabReorderable(content, true);
        this.tabs.setShowTabs(index != 0);
    }
    
    private void closeTabSignal(Button b) {
        this.tabs.detachTab(this.tabClose[b]);
        
        if (this.tabs.getNPages() == 0) {
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
        newTab(HOMEPAGE);
    }

    private void aboutSignal(Button b) {
        new About();
    }

    private void preferencesSignal(Button b) {
        new Preferences();
    }

    private void tabChangedSignal(Widget contents, uint index, Notebook book) {
        auto uri = (cast(Webview)contents).uri;
        this.urlBar.setText(uri);
        this.urlBar.showAll();
    }

    private void loadChangedSignal(Webview sender, WebkitLoadEvent event) {
        tabLabels[sender].setText(sender.title);

        this.previousPage.setSensitive(sender.canGoBack);
        this.nextPage.setSensitive(sender.canGoForward);

        if (getCurrentWebview() != sender) {
            return;
        }

        this.urlBar.setText(sender.uri);

        final switch (event) {
            case WebkitLoadEvent.Started:
                this.urlBar.setProgressFraction(0.25);
                break;
            case WebkitLoadEvent.Redirected:
                this.urlBar.setProgressFraction(0.5);
                break;
            case WebkitLoadEvent.Committed:
                this.urlBar.setProgressFraction(0.75);
                break;
            case WebkitLoadEvent.Finished:
                this.urlBar.setProgressFraction(0);
                break;
        }

        if (sender.isLoading) {
            this.refresh.setImage(new Image(StockID.STOP, GtkIconSize.BUTTON));
        } else {
            this.refresh.setImage(new Image(StockID.REFRESH, GtkIconSize.BUTTON));
        }
    }
}
