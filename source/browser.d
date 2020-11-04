module browser;

import gdk.Event:              Event;
import gtk.Application:        Application;
import gtk.ApplicationWindow:  ApplicationWindow;
import gtk.AccelGroup:         AccelGroup;
import gdk.c.types:            ModifierType;
import gtk.c.types:            AccelFlags, ReliefStyle;
import gobject.DClosure:       DClosure;
import gtk.HeaderBar:          HeaderBar;
import gtk.Button:             Button;
import globals:                programName;
import gtk.Entry:              Entry;
import gtk.Widget:             Widget;
import gtk.Notebook:           Notebook;
import gtk.HBox:               HBox;
import gtk.VBox:               VBox;
import gtk.Image:              IconSize, Image;
import webkit2.WebView:        LoadEvent, WebView;
import gio.TlsCertificate:     TlsCertificate, TlsCertificateFlags;
import gobject.ObjectG:        ObjectG;
import gobject.ParamSpec:      ParamSpec;
import customview:             CustomView;
import options:                Options;
import searchbar:              SearchBar;
import tabs:                   Tabs;
import storage:                HistoryStore, UserSettings;

/**
 * Main browser window.
 */
final class Browser : ApplicationWindow {
    private AccelGroup shortcuts;
    private Button previousPage;
    private Button nextPage;
    private Button refresh;
    private SearchBar  urlBar;
    private Button addTab;
    private Options    options;
    private Tabs       tabs;

    /**
     * Constructs the main window with the passed url as only one.
     */
    this(Application app, string openurl) {
        // Init ourselves.
        super(app);
        addOnDelete(&closeSignal);
        setDefaultSize(UserSettings.mainWindowWidth, UserSettings.mainWindowHeight);

        // Initialize buttons and data.
        shortcuts    = new AccelGroup();
        previousPage = new Button("go-previous-symbolic", IconSize.SMALL_TOOLBAR);
        nextPage     = new Button("go-next-symbolic", IconSize.SMALL_TOOLBAR);
        refresh      = new Button("view-refresh-symbolic", IconSize.SMALL_TOOLBAR);
        urlBar       = new SearchBar(this);
        addTab       = new Button("list-add-symbolic", IconSize.SMALL_TOOLBAR);
        options      = new Options(&historyTabSignal);
        tabs         = new Tabs();

        previousPage.addOnClicked(&previousSignal);
        nextPage.addOnClicked(&nextSignal);
        refresh.addOnClicked(&refreshSignal);
        urlBar.addOnActivate(&urlBarEnterSignal);
        urlBar.setHexpand(true);
        addTab.addOnClicked(&newTabSignal);
        options.addOnPrivateTabRequest(&privateTabSignal);
        tabs.addOnSwitchPage(&tabChangedSignal);

        // Setup shortcuts.
        addAccelGroup(shortcuts);
        uint key; // @suppress(dscanner.suspicious.unmodified)
        ModifierType mods;
        const auto flags = AccelFlags.VISIBLE;
        AccelGroup.acceleratorParse("F5", key, mods);
        shortcuts.connect(key, mods, flags, new DClosure(&refreshSignal));
        AccelGroup.acceleratorParse("F6", key, mods);
        shortcuts.connect(key, mods, flags, new DClosure(&focusSignal));
        AccelGroup.acceleratorParse("<Control>r", key, mods);
        shortcuts.connect(key, mods, flags, new DClosure(&refreshSignal));
        AccelGroup.acceleratorParse("<Control>q", key, mods);
        shortcuts.connect(key, mods, flags, new DClosure(&close));
        AccelGroup.acceleratorParse("<Alt>Left", key, mods);
        shortcuts.connect(key, mods, flags, new DClosure(&previousSignal));
        AccelGroup.acceleratorParse("<Alt>Right", key, mods);
        shortcuts.connect(key, mods, flags, new DClosure(&nextSignal));
        AccelGroup.acceleratorParse("<Control>t", key, mods);
        shortcuts.connect(key, mods, flags, new DClosure(&newTabSignal));
        AccelGroup.acceleratorParse("<Control><Shift>n", key, mods);
        shortcuts.connect(key, mods, flags, new DClosure(&privateTabSignal));

        // Pack the window depending on appearance settings.
        if (UserSettings.useHeaderBar) {
            auto header = new HeaderBar();
            header.packStart(previousPage);
            header.packStart(nextPage);
            header.packStart(refresh);
            header.setCustomTitle(urlBar);
            header.packEnd(options);
            header.packEnd(addTab);
            header.setShowCloseButton(true);
            setTitlebar(header);
            add(tabs);
        } else {
            auto mainBox   = new VBox(false, 0);
            auto headerBox = new HBox(false, 0);
            previousPage.setRelief(ReliefStyle.NONE);
            nextPage.setRelief(ReliefStyle.NONE);
            refresh.setRelief(ReliefStyle.NONE);
            addTab.setRelief(ReliefStyle.NONE);
            options.setRelief(ReliefStyle.NONE);
            headerBox.packStart(previousPage, false, false, 0);
            headerBox.packStart(nextPage,     false, false, 0);
            headerBox.packStart(refresh,      false, false, 0);
            headerBox.packStart(urlBar,       true,  true,  0);
            headerBox.packEnd(options,        false, false, 0);
            headerBox.packEnd(addTab,         false, false, 0);
            mainBox.packStart(headerBox, false, false, 0);
            mainBox.packStart(tabs,      true,  true,  0);
            add(mainBox);
        }

        // Make new tab, show all.
        showAll();
        newTab(openurl);
    }

    /**
     * Adds a new tab to the browser, processing the pertinent triggers.
     */
    void newTab(string uri, bool isPrivate = false) {
        auto view = new CustomView(null, isPrivate);
        view.loadUri(uri);
        view.addOnLoadChanged(&loadChangedSignal);
        view.addOnNotify(&titleChangedSignal, "title");
        tabs.addTab(view);
    }

    // Called when the user requests a private browsing tab.
    private void privateTabSignal() {
        newTab(UserSettings.homepage, true);
    }

    // Called when the window closes, we will use it to save some settings.
    private bool closeSignal(Event, Widget) {
        int width, height; // @suppress(dscanner.suspicious.unmodified)
        getSize(width, height);
        UserSettings.mainWindowWidth  = width;
        UserSettings.mainWindowHeight = height;
        destroy();
        return true;
    }

    // Called when a tab with a URI from the history is chosen.
    private void historyTabSignal(string uri) {
        newTab(uri);
    }

    // Called when pressing the previous button.
    // We assume the current view is able to go back, else, the button
    // should not be able to be pressed.
    private void previousSignal(Button) {
        auto widget = tabs.getCurrentWebview();
        widget.goBack();
    }

    // Ditto but for the next button.
    private void nextSignal(Button) {
        auto widget = tabs.getCurrentWebview();
        widget.goForward();
    }

    // Refresh button signal, we just stop or start depending on the state.
    private void refreshSignal(Button) {
        auto widget = tabs.getCurrentWebview();

        if (widget.isLoading) {
            widget.stopLoading();
        } else {
            widget.reload();
        }
    }

    // What happens when F6 and other means are pressed to focus the urlBar.
    private void focusSignal() {
        urlBar.grabFocus();
    }

    // What happens when the user finishes outputting a url.
    private void urlBarEnterSignal(Entry entry) {
        auto widget = tabs.getCurrentWebview();
        widget.loadUri(entry.getText());
    }

    // New tab button signal.
    private void newTabSignal(Button) {
        newTab(UserSettings.homepage);
    }

    // What happens when the main browser tab is changed.
    private void tabChangedSignal(Widget contents, uint, Notebook) {
        auto view = cast(WebView)contents;
        TlsCertificate      tls;
        TlsCertificateFlags flags;

        urlBar.setText(view.getUri());
        urlBar.setProgressFraction(0);
        urlBar.showAll();
        setTitle(view.getTitle());
        previousPage.setSensitive(view.canGoBack);
        nextPage.setSensitive(view.canGoForward);
        urlBar.setSecureIcon(view.getTlsInfo(tls, flags));
    }

    // Manage what happens when the load of a uri changes per webview.
    // We will discern what to do whether its the active one or not later.
    private void loadChangedSignal(LoadEvent event, WebView sender) {
        if (tabs.getCurrentWebview() != sender) {
            return;
        }

        urlBar.setText(sender.getUri());
        previousPage.setSensitive(sender.canGoBack());
        nextPage.setSensitive(sender.canGoForward());

        final switch (event) {
            case LoadEvent.STARTED:
                urlBar.removeIcon();
                urlBar.setProgressFraction(0.25);
                break;
            case LoadEvent.REDIRECTED:
                urlBar.setProgressFraction(0.5);
                break;
            case LoadEvent.COMMITTED:
                urlBar.setProgressFraction(0.75);
                break;
            case LoadEvent.FINISHED:
                TlsCertificate      tls;
                TlsCertificateFlags flags;
                urlBar.setProgressFraction(0);
                urlBar.setSecureIcon(sender.getTlsInfo(tls, flags));
                break;
        }

        const string id = sender.isLoading ? "process-stop-symbolic" : "view-refresh-symbolic";
        refresh.setImage(new Image(id, IconSize.SMALL_TOOLBAR));
    }

    // Called when the title changes, that we will use as signal to add
    // to the history.
    private void titleChangedSignal(ParamSpec, ObjectG obj) {
        auto sender = cast(WebView)obj;
        auto title  = sender.getTitle();

        if (title != "" && !sender.isEphemeral()) {
            HistoryStore.updateOrAdd(title, sender.getUri());
        }

        if (sender == tabs.getCurrentWebview()) {
            setTitle(title);
            urlBar.setText(sender.getUri()); // for on-site navigation.
        }
    }
}
