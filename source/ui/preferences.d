module ui.preferences;

import gtk.Window:           Window;
import gtk.Widget:           Widget, GdkEventFocus;
import gtk.StackSidebar:     StackSidebar;
import gtk.Stack:            Stack;
import gtk.VBox:             VBox;
import gtk.HBox:             HBox;
import gtk.CheckButton:      CheckButton;
import gtk.Button:           Button;
import gtk.Label:            Label;
import gtk.Entry:            Entry, InputPurpose;
import gtk.EditableIF:       EditableIF;
import gtk.ComboBoxText:     ComboBoxText;
import ui.translations:      _;
import storage.usersettings; // Almost everything really.

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
    private ComboBoxText userAgent;
    private ComboBoxText cookiePolicy;
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
        userAgent       = new ComboBoxText(true);
        cookiePolicy    = new ComboBoxText(false);
        cookieKeep      = new CheckButton(_("Keep Cookies Between Sessions"));
        forceHTTPS      = new CheckButton(_("Force HTTPS Navigation"));
        insecureContent = new CheckButton(_("Allow Insecure Content On HTTPS"));
        useHeaderBar    = new CheckButton(_("Use GTK's Header Bar"));
        smoothScrolling.setActive(getUseSmoothScrolling());
        smoothScrolling.addOnClicked(&checkButtonPressed);
        pageCache.setActive(getUsePageCache());
        pageCache.addOnClicked(&checkButtonPressed);
        javascript.setActive(getUseJavascript());
        javascript.addOnClicked(&checkButtonPressed);
        sitequirks.setActive(getUseSiteQuirks());
        sitequirks.addOnClicked(&checkButtonPressed);
        homepage.setText(getHomepage());
        homepage.addOnFocusOut(&entryChanged);
        searchEngine.setText(getSearchEngineURL());
        searchEngine.addOnFocusOut(&entryChanged);
        userAgent.addOnChanged(&comboBoxChanged);
        cookiePolicy.addOnChanged(&comboBoxChanged);
        cookieKeep.setActive(getKeepSessionCookies());
        cookieKeep.addOnClicked(&checkButtonPressed);
        forceHTTPS.setActive(getForceHTTPS());
        forceHTTPS.addOnClicked(&checkButtonPressed);
        insecureContent.setActive(getAllowInsecureContent());
        insecureContent.addOnClicked(&checkButtonPressed);
        useHeaderBar.setActive(getUseUIHeaderBar());
        useHeaderBar.addOnClicked(&checkButtonPressed);
        homepage.setInputPurpose(InputPurpose.URL);
        searchEngine.setInputPurpose(InputPurpose.URL);

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
        cookiePolicy.appendText(_("Accept all cookies"));
        cookiePolicy.appendText(_("Reject all cookies"));
        cookiePolicy.appendText(_("Accept only cookies set by the main site"));
        cookiePolicy.setActive(getIncomingCookiePolicy());
        cookiePolicy.showAll();

        auto userAgentBox   = new HBox(false, 10);
        auto userAgentLabel = new Label(_("Cookie Policy"));
        userAgentLabel.setWidthChars(15);
        userAgentLabel.setXalign(0);
        userAgentBox.packStart(userAgentLabel, false, false, 0);
        userAgentBox.packStart(userAgent,      true,  true,  0);
        userAgent.appendText("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0 Safari/605.1.15");
        userAgent.appendText("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36");
        userAgent.appendText("Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)");
        auto entry = cast(Entry)userAgent.getChild();
        entry.addOnFocusOut((GdkEventFocus*, Widget entry) {
            auto ent = cast(Entry)entry;
            setUserAgent(ent.getText());
            return false;
        });
        entry.setText(getUserAgent());
        userAgent.showAll();

        auto browserSettings = new VBox(false, 10);
        browserSettings.packStart(homepageBox,     false, false, 10);
        browserSettings.packStart(searchEngineBox, false, false, 10);
        browserSettings.packStart(userAgentBox,    false, false, 10);
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
        if      (button is smoothScrolling) setUseSmoothScrolling(set);
        else if (button is pageCache)       setUsePageCache(set);
        else if (button is javascript)      setUseJavascript(set);
        else if (button is sitequirks)      setUseSiteQuirks(set);
        else if (button is cookieKeep)      setKeepSessionCookies(set);
        else if (button is forceHTTPS)      setForceHTTPS(set);
        else if (button is insecureContent) setAllowInsecureContent(set);
        else if (button is useHeaderBar)    setUseUIHeaderBar(set);
        else assert(0, "Someone forgot an item!");
    }

    // Called when the user finishes an entry insertion.
    private bool entryChanged(GdkEventFocus*, Widget entry) {
        const auto text = (cast(Entry)entry).getText();
        if      (entry is homepage)     setHomepage(text);
        else if (entry is searchEngine) setSearchEngineURL(text);
        else if (entry is userAgent)    setUserAgent(text);
        else assert(0, "Someone forgot an item! Again!");
        return false;
    }

    // Called when the user selects an option of a combobox.
    private void comboBoxChanged(ComboBoxText box) {
        if (box is userAgent) {
            auto entry = cast(Entry)userAgent.getChild();
            entry.setText(userAgent.getActiveText());
            setUserAgent(entry.getText());
        } else if (box is cookiePolicy) { 
            setIncomingCookiePolicy(cookiePolicy.getActive());
        } else {
            assert(0, "Someone forgot an item!");
        }
    }
}
