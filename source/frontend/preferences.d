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

private immutable WIN_WIDTH = 500;
private immutable WIN_HEIGHT = 600;

private immutable CLOSE_SIGNAL = -4;

private void packBox(VBox box, Widget widget) {
    box.packStart(widget, false, false, 0);
}

class Preferences : Dialog {
    private CheckButton smoothScrolling;
    private CheckButton pageCache;
    private CheckButton javascript;
    private CheckButton siteSpecificQuirks;
    private Entry homepage;
    private CheckButton useHeaderBar;

    this() {
        // Init ourselves first.
	    super();
        this.setDefaultSize(WIN_WIDTH, WIN_HEIGHT);

        // Init the buttons and input boxes.
        this.smoothScrolling = new CheckButton("Enable smooth scrolling");
        this.pageCache = new CheckButton("Enable page caching");
        this.javascript = new CheckButton("Enable javascript");
        this.siteSpecificQuirks = new CheckButton("Enable site specific quirks");
        this.homepage = new Entry();
        this.useHeaderBar = new CheckButton("Use GTK+'s header bar for the UI");

        // Set current values.
        this.smoothScrolling.setActive(SMOOTH_SCROLLING);
        this.pageCache.setActive(PAGE_CACHE);
        this.javascript.setActive(JAVASCRIPT);
        this.siteSpecificQuirks.setActive(SITEQUIRKS);
        this.homepage.setText(HOMEPAGE);
        this.useHeaderBar.setActive(HEADERBAR);

        // Add items to boxes.
        auto tabs = new Notebook();

        auto engine = new VBox(false, 10);
        packBox(engine, this.smoothScrolling);
        packBox(engine, this.pageCache);
        packBox(engine, this.javascript);
        packBox(engine, this.siteSpecificQuirks);
        tabs.appendPage(engine, new Label("Engine"));

        auto browsing = new VBox(false, 10);
        packBox(browsing, new Label("Homepage"));
        packBox(browsing, this.homepage);
        tabs.appendPage(browsing, new Label("Browsing"));

        auto appearance = new VBox(false, 10);
        packBox(appearance, this.useHeaderBar);
        tabs.appendPage(appearance, new Label("Appearance"));

        // Add the tabs and response and show all.
        auto content = this.getContentArea();
        content.packStart(tabs, true, true, 0);
        content.add(new Label("Settings will be applied next restart"));
        this.addOnResponse(toDelegate(&(this.saveCloseSignal)));
        this.showAll();
    }

    private void saveCloseSignal(int signal, Dialog dialog) {
        switch (signal) {
            case CLOSE_SIGNAL:
                SMOOTH_SCROLLING = this.smoothScrolling.getActive();
                PAGE_CACHE = this.pageCache.getActive();
                JAVASCRIPT = this.javascript.getActive();
                SITEQUIRKS = this.siteSpecificQuirks.getActive();
                HOMEPAGE = urlFromUserInput(this.homepage.getText());
                HEADERBAR = this.useHeaderBar.getActive();
                saveSettings();
                break;
            default:
                break;
        }
    }
}
