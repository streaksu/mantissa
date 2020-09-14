module frontend.browser;

import std.functional:                 toDelegate;
import gtk.Main:                       Main;
import gtk.MainWindow:                 MainWindow;
import gtk.HeaderBar:                  HeaderBar;
import gtk.Button:                     Button;
import globals:                        programName;
import gtk.Entry:                      Entry;
import gtk.Notebook:                   Notebook;
import gtk.Label:                      Label;
import gtk.Widget:                     Widget;
import gtk.VBox:                       VBox;
import gtk.HBox:                       HBox;
import gtk.CheckButton:                CheckButton;
import gtk.Image:                      StockID, GtkIconSize, Image;
import settings:                       BrowserSettings;
import frontend.about:                 About;
import backend.url:                    urlFromUserInput;
import backend.webkit.webview:         WebkitLoadEvent, Webview;
import backend.webkit.webviewsettings: WebviewSettings;

private immutable windowWidth  = 1366;
private immutable windowHeight = 768;

class Browser : MainWindow {
    private BrowserSettings settings;

    private Button   previousPage;
    private Button   nextPage;
    private Button   refresh;
    private Entry    urlBar;
    private Button   addTab;
    private Button   extra;
    private HBox     mainBox;
    private Notebook tabs;
    private VBox     extraBox;

    private CheckButton smoothScrolling;
    private CheckButton pageCache;
    private CheckButton javascript;
    private CheckButton sitequirks;
    private Entry       homepage;
    private Button      about;

    private Label[Webview]  tabLabels;
    private Webview[Button] tabClose;

    this(string openurl) {
        // Init ourselves.
        super(programName);
        setDefaultSize(windowWidth, windowHeight);

        // Create a settings registry.
        settings = new BrowserSettings();

        // Initialize buttons and data.
        previousPage = new Button("go-previous",  GtkIconSize.BUTTON);
        nextPage     = new Button("go-next",      GtkIconSize.BUTTON);
        refresh      = new Button("view-refresh", GtkIconSize.BUTTON);
        urlBar       = new Entry();
        addTab       = new Button("list-add",           GtkIconSize.BUTTON);
        extra        = new Button("open-menu-symbolic", GtkIconSize.BUTTON);
        mainBox      = new HBox(false, 0);
        tabs         = new Notebook();
        extraBox     = new VBox(false, 10);

        smoothScrolling = new CheckButton("Enable Smooth Scrolling");
        pageCache       = new CheckButton("Enable Page Cache");
        javascript      = new CheckButton("Enable Javascript Support");
        sitequirks      = new CheckButton("Enable Site-Specific Quirks");
        homepage        = new Entry();
        about           = new Button("About " ~ programName);

        previousPage.addOnClicked(toDelegate(&previousSignal));
        nextPage.addOnClicked(toDelegate(&nextSignal));
        refresh.addOnClicked(toDelegate(&refreshSignal));
        urlBar.addOnActivate(toDelegate(&urlBarEnterSignal));
        urlBar.setHexpand(true);
        addTab.addOnClicked(toDelegate(&newTabSignal));
        extra.addOnClicked(toDelegate(&extraSignal));
        tabs.addOnSwitchPage(toDelegate(&tabChangedSignal));
        tabs.setScrollable(true);
        about.addOnClicked(toDelegate(&aboutSignal));

        // Pack the header.
        auto header = new HeaderBar();
        header.packStart(previousPage);
        header.packStart(nextPage);
        header.packStart(refresh);
        header.setCustomTitle(urlBar);
        header.packEnd(extra);
        header.packEnd(addTab);
        header.setShowCloseButton(true);
        setTitlebar(header);

        // Pack the main overlay.
        mainBox.packStart(tabs,     true,  true,  0);
        mainBox.packStart(extraBox, false, false, 0);
        add(mainBox);

        // Pack the extra pannel.
        auto homePBox = new HBox(true, 5);
        homePBox.packStart(new Label("Homepage"), false, false, 5);
        homePBox.packStart(homepage,              false, false, 5);

        extraBox.packStart(new Label("Engine settings"), false, false, 10);
        extraBox.packStart(smoothScrolling,              false, false, 10);
        extraBox.packStart(pageCache,                    false, false, 10);
        extraBox.packStart(javascript,                   false, false, 10);
        extraBox.packStart(sitequirks,                   false, false, 10);
        extraBox.packStart(new Label("Browsing"),        false, false, 10);
        extraBox.packStart(homePBox,                     false, false, 10);
        extraBox.packStart(about,                        false, false, 10);

        // Make new tab, show all.
        newTab(openurl);
        showAll();
        extraBox.hide();
    }

    void newTab(string url) {
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

    private Webview getCurrentWebview() {
        auto current = tabs.getCurrentPage();
        return cast(Webview)(tabs.getNthPage(current));
    }

    private void closeTabSignal(Button b) {
        tabs.detachTab(tabClose[b]);

        switch (tabs.getNPages()) {
            case 1:
                tabs.setShowTabs(false);
                break;
            case 0:
                Main.quit();
                break;
            default:
                break;
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
        newTab(settings.homepage);
    }

    private void extraSignal(Button b) {
        if (extraBox.isVisible()) {
            settings.smoothScrolling = smoothScrolling.getActive();
            settings.pageCache       = pageCache.getActive();
            settings.javascript      = javascript.getActive();
            settings.sitequirks      = sitequirks.getActive();
            extraBox.hide();
        } else {
            smoothScrolling.setActive(settings.smoothScrolling);
            pageCache.setActive(settings.pageCache);
            javascript.setActive(settings.javascript);
            sitequirks.setActive(settings.sitequirks);
            homepage.setText(settings.homepage);
            extraBox.show();
        }
    }

    private void aboutSignal(Button b) {
        new About();
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
