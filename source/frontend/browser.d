module frontend.browser;

import std.functional:         toDelegate;
import gtk.Application:        Application;
import gtk.ApplicationWindow:  ApplicationWindow;
import gtk.AccelGroup:         AccelGroup;
import gdk.c.types:            ModifierType;
import gtk.c.types:            AccelFlags;
import gobject.DClosure:       DClosure;
import gtk.HeaderBar:          HeaderBar;
import gtk.Button:             Button;
import globals:                programName;
import gtk.Entry:              Entry;
import gtk.Widget:             Widget;
import gtk.Notebook:           Notebook;
import gtk.HBox:               HBox;
import gtk.Image:              IconSize, Image;
import webkit2gtkd.webview:    LoadEvent, Webview;
import frontend.options:       Options;
import frontend.searchbar:     SearchBar;
import frontend.tabs:          Tabs;
import storage:                HistoryStore, UserSettings;

private immutable windowWidth  = 1366;
private immutable windowHeight = 768;

/**
 * Main browser window.
 */
final class Browser : ApplicationWindow {
    private AccelGroup shortcuts;
    private Button     previousPage;
    private Button     nextPage;
    private Button     refresh;
    private SearchBar  urlBar;
    private Button     addTab;
    private Options    options;
    private Tabs       tabs;

    /**
     * Constructs the main window with the passed url as only one.
     */
    this(Application app, string openurl) {
        // Init ourselves.
        super(app);
        setDefaultSize(windowWidth, windowHeight);

        // Initialize buttons and data.
        shortcuts    = new AccelGroup();
        previousPage = new Button("go-previous",  IconSize.BUTTON);
        nextPage     = new Button("go-next",      IconSize.BUTTON);
        refresh      = new Button("view-refresh", IconSize.BUTTON);
        urlBar       = new SearchBar(this);
        addTab       = new Button("list-add", IconSize.BUTTON);
        options      = new Options(toDelegate(&historyTabSignal));
        tabs         = new Tabs();

        previousPage.addOnClicked(toDelegate(&previousSignal));
        nextPage.addOnClicked(toDelegate(&nextSignal));
        refresh.addOnClicked(toDelegate(&refreshSignal));
        urlBar.addOnActivate(toDelegate(&urlBarEnterSignal));
        urlBar.setHexpand(true);
        addTab.addOnClicked(toDelegate(&newTabSignal));
        tabs.addOnSwitchPage(toDelegate(&tabChangedSignal));

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

        // Pack the header.
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

        // Make new tab, show all.
        showAll();
        newTab(openurl);
    }

    /**
     * Adds a new tab to the browser, processing the pertinent triggers.
     */
    void newTab(string uri) {
        auto view = new Webview();
        view.uri = uri;
        view.addOnLoadChanged(toDelegate(&loadChangedSignal));
        view.addOnTitleChanged(toDelegate(&titleChangedSignal));
        tabs.addTab(view);
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
        widget.uri  = entry.getText();
    }

    // New tab button signal.
    private void newTabSignal(Button) {
        newTab(UserSettings.homepage);
    }

    // What happens when the main browser tab is changed.
    private void tabChangedSignal(Widget contents, uint, Notebook) {
        auto view = cast(Webview)contents;
        urlBar.setText(view.uri);
        urlBar.setProgressFraction(0);
        urlBar.showAll();
        setTitle(view.title);
        previousPage.setSensitive(view.canGoBack);
        nextPage.setSensitive(view.canGoForward);
        urlBar.setSecureIcon(view.getTLSInfo());
    }

    // Manage what happens when the load of a uri changes per webview.
    // We will discern what to do whether its the active one or not later.
    private void loadChangedSignal(Webview sender, LoadEvent event) {
        if (tabs.getCurrentWebview() != sender) {
            return;
        }

        urlBar.setText(sender.uri);
        previousPage.setSensitive(sender.canGoBack);
        nextPage.setSensitive(sender.canGoForward);

        final switch (event) {
            case LoadEvent.Started:
                urlBar.removeIcon();
                urlBar.setProgressFraction(0.25);
                break;
            case LoadEvent.Redirected:
                urlBar.setProgressFraction(0.5);
                break;
            case LoadEvent.Committed:
                urlBar.setProgressFraction(0.75);
                break;
            case LoadEvent.Finished:
                urlBar.setProgressFraction(0);
                urlBar.setSecureIcon(sender.getTLSInfo());
                break;
        }

        const string id = sender.isLoading ? "process-stop" : "view-refresh";
        refresh.setImage(new Image(id, IconSize.BUTTON));
    }

    // Called when the title changes, that we will use as signal to add
    // to the history.
    private void titleChangedSignal(Webview sender) {
        if (sender.title != "") {
            HistoryStore.updateOrAdd(sender.title, sender.uri);
        }

        if (sender == tabs.getCurrentWebview()) {
            setTitle(sender.title);
        }
    }
}
