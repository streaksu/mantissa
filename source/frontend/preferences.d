module frontend.preferences;

import std.functional: toDelegate;
import gtk.Dialog;
import gtk.CheckButton;
import gtk.Entry;
import gtk.Label;
import gtk.Notebook;
import gtk.VBox;
import gtk.Widget;
import settings;
import backend.url;

private immutable closeSignal = -4;

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
        packBox(engine, smoothScrolling);
        packBox(engine, pageCache);
        packBox(engine, javascript);
        packBox(engine, siteSpecificQuirks);
        tabs.appendPage(engine, new Label("Engine"));

        auto browsing = new VBox(false, 10);
        packBox(browsing, new Label("Homepage"));
        packBox(browsing, homepage);
        tabs.appendPage(browsing, new Label("Browsing"));

        // Add the tabs and response and show all.
        auto content = getContentArea();
        content.packStart(tabs, true, true, 0);
        content.add(new Label("Settings will be applied next restart"));
        addOnResponse(toDelegate(&closeSignalHandler));
        showAll();
    }
    
    private void packBox(VBox box, Widget widget) {
        box.packStart(widget, false, false, 0);
    }

    private void closeSignalHandler(int signal, Dialog dialog) {
        if (signal == closeSignal) {
            settings.smoothScrolling = smoothScrolling.getActive();
            settings.pageCache       = pageCache.getActive();
            settings.javascript      = javascript.getActive();
            settings.sitequirks      = siteSpecificQuirks.getActive();
            settings.homepage        = urlFromUserInput(homepage.getText());
            settings.save();
        }
    }
}
