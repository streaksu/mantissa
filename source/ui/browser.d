/// Main browser window and its utilities.
module ui.browser;

import std.datetime.systime:   Clock;
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
import gtk.EditableIF:         EditableIF;
import webkit2.WebView:        LoadEvent, WebView;
import webkit2.FindController: FindController, FindOptions;
import gio.TlsCertificate:     TlsCertificate, TlsCertificateFlags;
import gobject.ObjectG:        ObjectG;
import gobject.ParamSpec:      ParamSpec;
import engine.customview:      CustomView;
import ui.findbar:             FindBar;
import ui.options:             Options;
import ui.searchbar:           SearchBar;
import ui.tabs:                Tabs;
import storage.usersettings;   // A lot, might as well all.
import storage.history:        HistoryURI, addToHistory;

/// Main browser window.
final class Browser : ApplicationWindow {
    private AccelGroup shortcuts;
    private Button     previousPage;
    private Button     nextPage;
    private Button     refresh;
    private SearchBar  urlBar;
    private Button     addTab;
    private Options    options;
    private Tabs       tabs;
    private FindBar    find;

    /// Constructs the main window with the passed url as only one.
    this(Application app, string openurl) {
        // Init ourselves.
        super(app);
        addOnDelete(&closeSignal);
        setDefaultSize(getMainWindowWidth(), getMainWindowHeight());

        // Initialize buttons and data.
        shortcuts    = new AccelGroup();
        previousPage = new Button("go-previous-symbolic", IconSize.SMALL_TOOLBAR);
        nextPage     = new Button("go-next-symbolic", IconSize.SMALL_TOOLBAR);
        refresh      = new Button("view-refresh-symbolic", IconSize.SMALL_TOOLBAR);
        urlBar       = new SearchBar(this);
        addTab       = new Button("list-add-symbolic", IconSize.SMALL_TOOLBAR);
        options      = new Options(&historyTabSignal);
        tabs         = new Tabs(this);
        find         = new FindBar();

        previousPage.addOnClicked(&previousSignal);
        nextPage.addOnClicked(&nextSignal);
        refresh.addOnClicked(&refreshSignal);
        urlBar.addOnActivate(&urlBarEnterSignal);
        urlBar.setHexpand(true);
        addTab.addOnClicked(&newTabSignal);
        options.addOnPrivateTabRequest(&privateTabSignal);
        options.addOnFindRequest(&startFindSignal);
        tabs.addOnSwitchPage(&tabChangedSignal);
        find.addOnSearchRequest(&findSignal);
        find.addOnPreviousRequested(&previousFindSignal);
        find.addOnNextRequested(&nextFindSignal);

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
        AccelGroup.acceleratorParse("<Control>f", key, mods);
        shortcuts.connect(key, mods, flags, new DClosure(&startFindSignal));

        // Pack the window depending on appearance settings.
        auto mainBox = new VBox(false, 0);
        if (getUseUIHeaderBar()) {
            auto header = new HeaderBar();
            header.packStart(previousPage);
            header.packStart(nextPage);
            header.packStart(refresh);
            header.setCustomTitle(urlBar);
            header.packEnd(options);
            header.packEnd(addTab);
            header.setShowCloseButton(true);
            setTitlebar(header);
            mainBox.packStart(tabs, true,  true,  0);
            mainBox.packStart(find, false, false, 0);
        } else {
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
            mainBox.packStart(find,      false, false, 0);
        }
        add(mainBox);

        // Make new tab, show all.
        showAll();
        newTab(openurl);
    }

    /// Adds a new tab to the browser, processing the pertinent triggers.
    void newTab(string uri, bool isPrivate = false) {
        auto view = new CustomView(null, isPrivate);
        view.loadUri(uri);
        view.addOnLoadChanged(&loadChangedSignal);
        view.addOnNotify(&titleChangedSignal, "title");
        view.addOnEnterFullscreen(&enterFullscreenSignal);
        view.addOnLeaveFullscreen(&leaveFullscreenSignal);
        tabs.addTab(view);
    }

    // Called when the user requests a private browsing tab.
    private void privateTabSignal() {
        newTab(getHomepage(), true);
    }

    // Called when the window closes, we will use it to save some settings.
    private bool closeSignal(Event, Widget) {
        int width, height; // @suppress(dscanner.suspicious.unmodified)
        getSize(width, height);
        setMainWindowWidth(width);
        setMainWindowHeight(height);
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
        newTab(getHomepage());
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

        final switch (event) {
            case LoadEvent.STARTED:
                urlBar.removeIcon();
                urlBar.setProgressFraction(0.25);
                break;
            case LoadEvent.REDIRECTED:
                urlBar.setProgressFraction(0.5);
                break;
            case LoadEvent.COMMITTED:
                urlBar.setText(sender.getUri());
                previousPage.setSensitive(sender.canGoBack());
                nextPage.setSensitive(sender.canGoForward());
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

    // Called when a view request fullscreen.
    private bool enterFullscreenSignal(WebView view) {
        import gtk.Dialog:      Dialog, DialogFlags, ResponseType;
        import gtk.Label:       Label;
        import ui.translations: _;

        // See if its a main one or not.
        if (tabs.getCurrentWebview() == view) {
            tabs.setShowTabs(false);
            return false;
        }

        // Ask the user if a non main tab can go fullscreen.
        auto dialog = new Dialog(
            _("Tab requested fullscreen"),
            this,
            DialogFlags.DESTROY_WITH_PARENT,
            [_("Allow"), _("Deny permission")],
            [ResponseType.ACCEPT, ResponseType.CLOSE]
        );
        auto cont = dialog.getContentArea();
        cont.add(new Label(_("A tab different than the active one asked for permission to go fullscreen")));
        cont.add(new Label(_("Do you want to switch to it and allow it? Or block the request")));
        dialog.showAll();

        const auto response = dialog.run();
        dialog.destroy();
        if (response == ResponseType.ACCEPT) {
            tabs.setCurrentPage(view);
            tabs.setShowTabs(false);
            return false;
        } else {
            return true;
        }
    }

    // Called when a view request to exit fullscreen.
    private bool leaveFullscreenSignal(WebView) {
        tabs.setShowTabs(tabs.getNPages() != 0);
        return false;
    }

    // Called when the title changes, that we will use as signal to add
    // to the history.
    private void titleChangedSignal(ParamSpec, ObjectG obj) {
        auto sender = cast(WebView)obj;
        auto title  = sender.getTitle();

        if (title != "" && !sender.isEphemeral()) {
            addToHistory(HistoryURI(sender.getUri(), title, false, Clock.currTime));
        }

        if (sender == tabs.getCurrentWebview()) {
            setTitle(title);

            // for on-site navigation.
            previousPage.setSensitive(sender.canGoBack());
            nextPage.setSensitive(sender.canGoForward());
            urlBar.setText(sender.getUri());
        }
    }

    // Called when the user requests to either open or close the find dialog.
    private void startFindSignal() {
        find.setSearchMode(!find.getSearchMode());
    }

    // Called when it comes to find text on a website.
    private void findSignal(string searchText) {
        auto findController = tabs.getCurrentWebview().getFindController();
        findController.search(searchText, FindOptions.CASE_INSENSITIVE,
            findController.getMaxMatchCount());
    }

    // Called when it comes to find the next text match on a website.
    private void previousFindSignal() {
        auto findController = tabs.getCurrentWebview().getFindController();
        findController.searchPrevious();
    }

    // Called when it comes to find the next text match on a website.
    private void nextFindSignal() {
        auto findController = tabs.getCurrentWebview().getFindController();
        findController.searchNext();
    }
}
