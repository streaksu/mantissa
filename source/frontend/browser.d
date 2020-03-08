module frontend.browser;

import std.functional: toDelegate;
import gtk.MainWindow;
import gtk.HeaderBar;
import gtk.Button;
import gtk.Entry;
import gtk.Notebook;
import gtk.Label;
import gtk.Widget;
import frontend.preferences;
import backend.webview;

private immutable WIN_WIDTH = 1600;
private immutable WIN_HEIGHT = 900;

class Browser : MainWindow {
    Button previousPage;
    Button nextPage;
    Button refresh;
    Entry urlBar;
    Button addTab;
    Button preferences;
    Notebook tabs;

    this(string homepage) {
        // Init ourselves.
        super("");
        this.setDefaultSize(WIN_WIDTH, WIN_HEIGHT);

        // Initialize buttons.
        this.previousPage = new Button(StockID.GO_BACK, true);
        this.nextPage = new Button(StockID.GO_FORWARD, true);
        this.refresh = new Button(StockID.REFRESH, true);
        this.urlBar = new Entry();
        this.addTab = new Button(StockID.ADD, true);
        this.preferences = new Button(StockID.PREFERENCES, true);

        this.previousPage.addOnClicked(toDelegate(&(this.previousSignal)));
        this.nextPage.addOnClicked(toDelegate(&(this.nextSignal)));
        this.refresh.addOnClicked(toDelegate(&(this.refreshSignal)));
        this.urlBar.setWidthChars(100);
        this.urlBar.addOnActivate(toDelegate(&(this.urlBarEnterSignal)));
        this.addTab.addOnClicked(toDelegate(&(this.newTabSignal)));
        this.preferences.addOnClicked(toDelegate(&(this.settingsSignal)));

        // Set the header and pack the buttons.
        auto header = new HeaderBar();
        header.packStart(this.previousPage);
        header.packStart(this.nextPage);
        header.packStart(this.refresh);
        header.setCustomTitle(this.urlBar);
        header.packEnd(this.preferences);
        header.packEnd(this.addTab);
        header.setShowCloseButton(true);

        // Create tabs.
        this.tabs = new Notebook();
        this.tabs.addOnSwitchPage(toDelegate(&(this.tabChangedSignal)));
        this.newTab(homepage);

        // Add the items and show.
        this.setTitlebar(header);
        this.add(this.tabs);
        this.showAll();
    }

    Webview getCurrentWebview() {
        auto current = this.tabs.getCurrentPage();
        return cast(Webview)(this.tabs.getNthPage(current));
    }

    void newTab(string url) {
        auto content = new Webview();
        auto tabTitle = new Label("");
        auto index = this.tabs.appendPage(content, tabTitle);

        content.loadUri(url);
        content.addOnUriChange(toDelegate(&(this.uriChangedSignal)));

        this.tabs.showAll(); // We need the item to be visible for switching.
        this.tabs.setCurrentPage(index);
        this.tabs.setShowTabs(index != 0);
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
        auto uri = widget.getUri();
        widget.loadUri(uri);
    }

    private void urlBarEnterSignal(Entry entry) {
        auto request = entry.getText();
        auto widget = getCurrentWebview();
        widget.loadUri(request);
    }

    private void newTabSignal(Button b) {
        newTab("https://google.com");
    }

    private void settingsSignal(Button b) {
        auto p = new Preferences();
    }

    private void tabChangedSignal(Widget contents, uint index, Notebook book) {
        auto uri = (cast(Webview)contents).getUri();
        this.urlBar.setText(uri);
        this.urlBar.showAll();
    }

    private void uriChangedSignal(Webview sender) {
        auto title = sender.getTitle();
        this.tabs.setTabLabelText(sender, title);

        if (getCurrentWebview() == sender) {
            this.urlBar.setText(sender.getUri());
            this.previousPage.setSensitive(sender.canGoBack());
            this.nextPage.setSensitive(sender.canGoForward());
        }
    }
}
