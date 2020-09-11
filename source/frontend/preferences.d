module frontend.preferences;

import std.functional: toDelegate;
import gtk.Dialog;
import gtk.CheckButton;
import gtk.Entry;
import gtk.Label;
import gtk.Notebook;
import gtk.VBox;
import gtk.HBox;
import gdk.Event;
import gtk.Widget;
import settings;
import backend.url;

private immutable windowWidth  = 455;
private immutable windowHeight = 256;

class Preferences : Dialog {
    private BrowserSettings settings;
    private CheckButton     smoothScrolling;
    private CheckButton     pageCache;
    private CheckButton     javascript;
    private CheckButton     siteSpecificQuirks;
    private Entry           homepage;

    this() {
        // Init the buttons and input boxes.
        settings           = new BrowserSettings();
        smoothScrolling    = new CheckButton("Enable smooth scrolling");
        pageCache          = new CheckButton("Enable page caching");
        javascript         = new CheckButton("Enable javascript");
        siteSpecificQuirks = new CheckButton("Enable site specific quirks");
        homepage           = new Entry();

        // Set current values.
        smoothScrolling.setActive(settings.smoothScrolling);
        pageCache.setActive(settings.pageCache);
        javascript.setActive(settings.javascript);
        siteSpecificQuirks.setActive(settings.sitequirks);
        homepage.setText(settings.homepage);

        // Add items to the dialog.
        auto tabs = new Notebook();

        auto engine = new VBox(false, 10);
        engine.packStart(smoothScrolling, true, true, 10);
        engine.packStart(pageCache, true, true, 10);
        engine.packStart(javascript, true, true, 10);
        engine.packStart(siteSpecificQuirks, true, true, 10);
        tabs.appendPage(engine, new Label("Engine"));

        auto browsing    = new VBox(false, 10);
        auto homepageBox = new HBox(false, 10);
        homepageBox.add(new Label("Homepage"));
        homepageBox.add(homepage);
        browsing.packStart(homepageBox, false, false, 0);
        tabs.appendPage(browsing, new Label("Browsing"));

        // Add the tabs and response and show all.
        auto content = getContentArea();
        content.packStart(tabs, false, false, 0);
        addOnDelete(toDelegate(&closeSignalHandler));
        setTitle("Preferences");
        resize(windowWidth, windowHeight);
        showAll();
    }

    private bool closeSignalHandler(Event pp, Widget dialog) {
        settings.smoothScrolling = smoothScrolling.getActive();
        settings.pageCache       = pageCache.getActive();
        settings.javascript      = javascript.getActive();
        settings.sitequirks      = siteSpecificQuirks.getActive();
        settings.homepage        = urlFromUserInput(homepage.getText());
        return false;
    }
}
