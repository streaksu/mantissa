module frontend.extramenu;

import std.functional:       toDelegate;
import gtk.c.types:          GtkPolicyType;
import gtk.ScrolledWindow:   ScrolledWindow;
import gtk.VBox:             VBox;
import gtk.HBox:             HBox;
import gtk.ToggleButton:     ToggleButton;
import gtk.CheckButton:      CheckButton;
import gtk.Entry:            Entry;
import gtk.ComboBox:         ComboBox;
import gtk.ListStore:        ListStore;
import gobject.c.types:      GType;
import gtk.CellRendererText: CellRendererText;
import gtk.Button:           Button;
import gtk.Label:            Label;
import frontend.about:       About;
import globals:              programName;
import settings:             BrowserSettings;

/**
 * Menu supposed to represent a utility panned menu in the main browser page.
 * Should handle settings, along with another comodities like cookie management.
 */
final class ExtraMenu : ScrolledWindow {
    private VBox            box;
    private BrowserSettings settings;
    private CheckButton     smoothScrolling;
    private CheckButton     pageCache;
    private CheckButton     javascript;
    private CheckButton     sitequirks;
    private Entry           homepage;
    private ComboBox        cookiePolicy;
    private CheckButton     cookieKeep;
    private CheckButton     forceHTTPS;
    private CheckButton     insecureContent;
    private Button          about;

    /**
     * Pack the structure and initialize all the pertitent locals.
     */
    this() {
        // Initialize everything.
        // super();
        box             = new VBox(false, 10);
        settings        = new BrowserSettings();
        smoothScrolling = new CheckButton("Enable Smooth Scrolling");
        pageCache       = new CheckButton("Enable Page Cache");
        javascript      = new CheckButton("Enable Javascript Support");
        sitequirks      = new CheckButton("Enable Site-Specific Quirks");
        homepage        = new Entry();
        cookiePolicy    = new ComboBox(false);
        cookieKeep      = new CheckButton("Keep cookies between sessions");
        forceHTTPS      = new CheckButton("Force HTTPS Navigation");
        insecureContent = new CheckButton("Allow HTTP content on HTTPS sites");
        about           = new Button("About " ~ programName);

        // Set values.
        smoothScrolling.setActive(settings.smoothScrolling);
        pageCache.setActive(settings.pageCache);
        javascript.setActive(settings.javascript);
        sitequirks.setActive(settings.sitequirks);
        homepage.setText(settings.homepage);
        cookiePolicy.setActive(settings.cookiePolicy);
        cookieKeep.setActive(settings.cookieKeep);
        forceHTTPS.setActive(settings.forceHTTPS);
        insecureContent.setActive(settings.insecureContent);

        // Pack the UI.
        auto homePBox = new HBox(false, 5);
        homePBox.packStart(new Label("Homepage"), false, false, 5);
        homePBox.packStart(homepage,              true,  true,  5);

        auto cookieBox = new HBox(false, 5);
        cookieBox.packStart(new Label("Cookie Policy"), false, false, 5);
        cookieBox.packStart(cookiePolicy,               true,  true,  5);
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

        box.packStart(new Label("Engine settings"), false, false, 10);
        box.packStart(smoothScrolling,              false, false, 10);
        box.packStart(pageCache,                    false, false, 10);
        box.packStart(javascript,                   false, false, 10);
        box.packStart(sitequirks,                   false, false, 10);
        box.packStart(new Label("Browsing"),        false, false, 10);
        box.packStart(homePBox,                     false, false, 10);
        box.packStart(cookieBox,                    false, false, 10);
        box.packStart(cookieKeep,                   false, false, 10);
        box.packStart(forceHTTPS,                   false, false, 10);
        box.packStart(insecureContent,              false, false, 10);

        // Wire signals.
        smoothScrolling.addOnToggled(toDelegate(&checkbuttonToggledSignal));
        pageCache.addOnToggled(toDelegate(&checkbuttonToggledSignal));
        javascript.addOnToggled(toDelegate(&checkbuttonToggledSignal));
        sitequirks.addOnToggled(toDelegate(&checkbuttonToggledSignal));
        homepage.addOnActivate(toDelegate(&entryActivateSignal));
        cookiePolicy.addOnChanged(toDelegate(&comboChangedSignal));
        cookieKeep.addOnToggled(toDelegate(&checkbuttonToggledSignal));
        forceHTTPS.addOnToggled(toDelegate(&checkbuttonToggledSignal));
        insecureContent.addOnToggled(toDelegate(&checkbuttonToggledSignal));
        about.addOnClicked(toDelegate(&aboutPressedSignal));

        // Show all.
        addWithViewport(box);
        setPropagateNaturalWidth(true);
        setMaxContentWidth(500);
        showAll();
    }

    // Called when one of the checkbuttons is checked or unchecked.
    private void checkbuttonToggledSignal(ToggleButton button) {
        const auto set = button.getActive();

        if (button is smoothScrolling)      settings.smoothScrolling = set;
        else if (button is pageCache)       settings.pageCache       = set;
        else if (button is javascript)      settings.javascript      = set;
        else if (button is sitequirks)      settings.sitequirks      = set;
        else if (button is cookieKeep)      settings.cookieKeep      = set;
        else if (button is forceHTTPS)      settings.forceHTTPS      = set;
        else if (button is insecureContent) settings.insecureContent = set;
        else assert(0);
    }

    // Called when an entry is pressed enter on.
    private void entryActivateSignal(Entry) {
        settings.homepage = homepage.getText();
    }

    // Called when the user changes the item of a combobox.
    private void comboChangedSignal(ComboBox) {
        settings.cookiePolicy = cookiePolicy.getActive();
    }

    // Called when the about button is pressed.
    private void aboutPressedSignal(Button) {
        new About();
    }
}
