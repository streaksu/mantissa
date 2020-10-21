module frontend.preferences;

import gtk.Window:           Window;
import gtk.Widget:           Widget;
import gtk.StackSidebar:     StackSidebar;
import gtk.Stack:            Stack;
import gtk.VBox:             VBox;
import gtk.HBox:             HBox;
import gtk.CheckButton:      CheckButton;
import gtk.Label:            Label;
import gtk.Entry:            Entry;
import gtk.ComboBox:         ComboBox;
import gtk.ListStore:        ListStore;
import gobject.c.types:      GType;
import gtk.CellRendererText: CellRendererText;
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
    private CheckButton  siteSpecificQuirks;
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
        super("Preferences");
        mainBox = new HBox(false, 10);
        sidebar = new StackSidebar();
        stack   = new Stack();
        mainBox.packStart(sidebar, false, false, 0);
        mainBox.packStart(stack, true, true, 10);
        sidebar.setStack(stack);
        add(mainBox);

        // Initialize inputs and set values.
        smoothScrolling    = new CheckButton("Enable Smooth Scrolling");
        pageCache          = new CheckButton("Enable Page Caching");
        javascript         = new CheckButton("Enable Javascript Support");
        siteSpecificQuirks = new CheckButton("Enable Site-Specific Quirks");
        homepage           = new Entry();
        searchEngine       = new Entry();
        cookiePolicy       = new ComboBox(false);
        cookieKeep         = new CheckButton("Keep Cookies Between Sessions");
        forceHTTPS         = new CheckButton("Force HTTPS Navigation");
        insecureContent    = new CheckButton("Allow Insecure Content On HTTPS");
        useHeaderBar       = new CheckButton("Use GTK's Header Bar");
        smoothScrolling.setActive(UserSettings.smoothScrolling);
        pageCache.setActive(UserSettings.pageCache);
        javascript.setActive(UserSettings.javascript);
        siteSpecificQuirks.setActive(UserSettings.sitequirks);
        homepage.setText(UserSettings.homepage);
        searchEngine.setText(UserSettings.searchEngine);
        cookiePolicy.setActive(UserSettings.cookiePolicy);
        cookieKeep.setActive(UserSettings.cookieKeep);
        forceHTTPS.setActive(UserSettings.forceHTTPS);
        insecureContent.setActive(UserSettings.insecureContent);
        useHeaderBar.setActive(UserSettings.useHeaderBar);

        // Pack the stack.
        auto engineSettings = new VBox(false, 10);
        engineSettings.packStart(smoothScrolling,    false, false, 10);
        engineSettings.packStart(pageCache,          false, false, 10);
        engineSettings.packStart(javascript,         false, false, 10);
        engineSettings.packStart(siteSpecificQuirks, false, false, 10);
        stack.addTitled(engineSettings, "engineSettings", "Engine Settings");

        auto homepageBox   = new HBox(false, 10);
        auto homepageLabel = new Label("Homepage");
        homepageLabel.setWidthChars(15);
        homepageLabel.setXalign(0);
        homepageBox.packStart(homepageLabel, false, false, 0);
        homepageBox.packStart(homepage,      true, true,   0);

        auto searchEngineBox   = new HBox(false, 10);
        auto searchEngineLabel = new Label("Search Engine");
        searchEngineLabel.setWidthChars(15);
        searchEngineLabel.setXalign(0);
        searchEngineBox.packStart(searchEngineLabel, false, false, 0);
        searchEngineBox.packStart(searchEngine,      true, true,   0);

        auto cookiePolicyBox   = new HBox(false, 10);
        auto cookiePolicyLabel = new Label("Cookie Policy");
        cookiePolicyLabel.setWidthChars(15);
        cookiePolicyLabel.setXalign(0);
        cookiePolicyBox.packStart(cookiePolicyLabel, false, false, 0);
        cookiePolicyBox.packStart(cookiePolicy,      true,  true,  0);
        auto store = new ListStore([GType.STRING]);
        auto iter1 = store.createIter();
        auto iter2 = store.createIter();
        auto iter3 = store.createIter();
        store.setValue(iter1, 0, "Accept all cookies unconditionally");
        store.setValue(iter2, 0, "Reject all cookies unconditionally");
        store.setValue(iter3, 0, "Accept only cookies set by the main site");
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
        stack.addTitled(browserSettings, "browserSettings", "Browser Settings");

        auto appearanceSettings = new VBox(false, 10);
        appearanceSettings.packStart(useHeaderBar, false, false, 10);
        stack.addTitled(appearanceSettings, "appearanceSettings", "Appearance");

        // Wire signals and show all.
        addOnDestroy(&closeSignal);
        showAll();
    }

    // Called when the window is closed.
    // We will use the signal to save the settings.
    private void closeSignal(Widget) {
        UserSettings.smoothScrolling = smoothScrolling.getActive();
        UserSettings.pageCache       = pageCache.getActive();
        UserSettings.javascript      = javascript.getActive();
        UserSettings.sitequirks      = siteSpecificQuirks.getActive();
        UserSettings.homepage        = homepage.getText();
        UserSettings.searchEngine    = searchEngine.getText();
        UserSettings.cookiePolicy    = cookiePolicy.getActive();
        UserSettings.cookieKeep      = cookieKeep.getActive();
        UserSettings.forceHTTPS      = forceHTTPS.getActive();
        UserSettings.insecureContent = insecureContent.getActive();
        UserSettings.useHeaderBar    = useHeaderBar.getActive();
    }
}
