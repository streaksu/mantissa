module preferences;

import gtk.Window:           Window;
import gtk.Widget:           Widget;
import gtk.StackSidebar:     StackSidebar;
import gtk.Stack:            Stack;
import gtk.VBox:             VBox;
import gtk.HBox:             HBox;
import gtk.CheckButton:      CheckButton;
import gtk.Button:           Button;
import gtk.Label:            Label;
import gtk.Entry:            Entry;
import gtk.EditableIF:       EditableIF;
import gtk.ComboBox:         ComboBox;
import gtk.ListStore:        ListStore;
import gobject.c.types:      GType;
import gtk.CellRendererText: CellRendererText;
import translations:         _;
import storage:              UserSettings;

/**
 * Preferences window.
 */
final class Preferences : Window {
    private HBox         mainBox;
    private StackSidebar sidebar;
    private Stack        stack;
    private CheckButton  smoothScrolling;
    private CheckButton  pageCache;
    private CheckButton  javascript;
    private CheckButton  sitequirks;
    private Entry        homepage;
    private Entry        searchEngine;
    private ComboBox     cookiePolicy;
    private CheckButton  cookieKeep;
    private CheckButton  forceHTTPS;
    private CheckButton  insecureContent;
    private CheckButton  useHeaderBar;

    /**
     * Creates the object.
     */
    this() {
        // Initialize ourselves and pack the window.
        super(_("Preferences"));
        mainBox = new HBox(false, 10);
        sidebar = new StackSidebar();
        stack   = new Stack();
        mainBox.packStart(sidebar, false, false, 0);
        mainBox.packStart(stack,   true,  true,  10);
        sidebar.setStack(stack);
        add(mainBox);

        // Initialize inputs and set values.
        smoothScrolling = new CheckButton(_("Enable Smooth Scrolling"));
        pageCache       = new CheckButton(_("Enable Page Caching"));
        javascript      = new CheckButton(_("Enable JavaScript Support"));
        sitequirks      = new CheckButton(_("Enable Site-Specific Quirks"));
        homepage        = new Entry();
        searchEngine    = new Entry();
        cookiePolicy    = new ComboBox(false);
        cookieKeep      = new CheckButton(_("Keep Cookies Between Sessions"));
        forceHTTPS      = new CheckButton(_("Force HTTPS Navigation"));
        insecureContent = new CheckButton(_("Allow Insecure Content On HTTPS"));
        useHeaderBar    = new CheckButton(_("Use GTK's Header Bar"));
        smoothScrolling.setActive(UserSettings.smoothScrolling);
        smoothScrolling.addOnClicked(&checkButtonPressed);
        pageCache.setActive(UserSettings.pageCache);
        pageCache.addOnClicked(&checkButtonPressed);
        javascript.setActive(UserSettings.javascript);
        javascript.addOnClicked(&checkButtonPressed);
        sitequirks.setActive(UserSettings.sitequirks);
        sitequirks.addOnClicked(&checkButtonPressed);
        homepage.setText(UserSettings.homepage);
        homepage.addOnChanged(&entryChanged);
        searchEngine.setText(UserSettings.searchEngine);
        searchEngine.addOnChanged(&entryChanged);
        cookiePolicy.setActive(UserSettings.cookiePolicy);
        cookiePolicy.addOnChanged(&comboBoxChanged);
        cookieKeep.setActive(UserSettings.cookieKeep);
        cookieKeep.addOnClicked(&checkButtonPressed);
        forceHTTPS.setActive(UserSettings.forceHTTPS);
        forceHTTPS.addOnClicked(&checkButtonPressed);
        insecureContent.setActive(UserSettings.insecureContent);
        insecureContent.addOnClicked(&checkButtonPressed);
        useHeaderBar.setActive(UserSettings.useHeaderBar);
        useHeaderBar.addOnClicked(&checkButtonPressed);

        // Pack the stack.
        auto engineSettings = new VBox(false, 10);
        engineSettings.packStart(smoothScrolling,    false, false, 10);
        engineSettings.packStart(pageCache,          false, false, 10);
        engineSettings.packStart(javascript,         false, false, 10);
        engineSettings.packStart(sitequirks, false, false, 10);
        stack.addTitled(engineSettings, "engineSettings", _("Engine Settings"));

        auto homepageBox   = new HBox(false, 10);
        auto homepageLabel = new Label(_("Homepage"));
        homepageLabel.setWidthChars(15);
        homepageLabel.setXalign(0);
        homepageBox.packStart(homepageLabel, false, false, 0);
        homepageBox.packStart(homepage,      true, true,   0);

        auto searchEngineBox   = new HBox(false, 10);
        auto searchEngineLabel = new Label(_("Search Engine"));
        searchEngineLabel.setWidthChars(15);
        searchEngineLabel.setXalign(0);
        searchEngineBox.packStart(searchEngineLabel, false, false, 0);
        searchEngineBox.packStart(searchEngine,      true, true,   0);

        auto cookiePolicyBox   = new HBox(false, 10);
        auto cookiePolicyLabel = new Label(_("Cookie Policy"));
        cookiePolicyLabel.setWidthChars(15);
        cookiePolicyLabel.setXalign(0);
        cookiePolicyBox.packStart(cookiePolicyLabel, false, false, 0);
        cookiePolicyBox.packStart(cookiePolicy,      true,  true,  0);
        auto store = new ListStore([GType.STRING]);
        auto iter1 = store.createIter();
        auto iter2 = store.createIter();
        auto iter3 = store.createIter();
        store.setValue(iter1, 0, _("Accept all cookies"));
        store.setValue(iter2, 0, _("Reject all cookies"));
        store.setValue(iter3, 0, _("Accept only cookies set by the main site"));
        cookiePolicy.setModel(store);
        cookiePolicy.showAll();
        auto col = new CellRendererText();
        cookiePolicy.packStart(col, true);
        cookiePolicy.addAttribute(col, "text", 0);

        auto browserSettings = new VBox(false, 10);
        browserSettings.packStart(homepageBox,     false, false, 10);
        browserSettings.packStart(searchEngineBox, false, false, 10);
        browserSettings.packStart(cookiePolicyBox, false, false, 10);
        browserSettings.packStart(cookieKeep,      false, false, 10);
        browserSettings.packStart(forceHTTPS,      false, false, 10);
        browserSettings.packStart(insecureContent, false, false, 10);
        stack.addTitled(browserSettings, "browserSettings", _("Browser Settings"));

        auto appearanceSettings = new VBox(false, 10);
        appearanceSettings.packStart(useHeaderBar, false, false, 10);
        stack.addTitled(appearanceSettings, "appearanceSettings", _("Appearance"));

        // Wire signals and show all.
        showAll();
    }

    // Called when a checkbutton is pressed.
    private void checkButtonPressed(Button button) {
        const auto set = (cast(CheckButton)button).getActive();
        if      (button is smoothScrolling) UserSettings.smoothScrolling = set;
        else if (button is pageCache)       UserSettings.pageCache       = set;
        else if (button is javascript)      UserSettings.javascript      = set;
        else if (button is sitequirks)      UserSettings.sitequirks      = set;
        else if (button is cookieKeep)      UserSettings.cookieKeep      = set;
        else if (button is forceHTTPS)      UserSettings.forceHTTPS      = set;
        else if (button is insecureContent) UserSettings.insecureContent = set;
        else if (button is useHeaderBar)    UserSettings.useHeaderBar    = set;
        else assert(0, "Someone forgot an item!");
    }

    // Called when the user finishes an entry insertion.
    private void entryChanged(EditableIF entry) {
        const auto text = (cast(Entry)entry).getText();
        if      (entry is homepage)     UserSettings.homepage     = text;
        else if (entry is searchEngine) UserSettings.searchEngine = text;
        else assert(0, "Someone forgot an item! Again!");
    }

    // Called when the user selects an option of a combobox.
    private void comboBoxChanged(ComboBox) {
        UserSettings.cookiePolicy = cookiePolicy.getActive();
    }
}
