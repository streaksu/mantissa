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
    private CheckButton mediaSource;
    private Entry homepage;

    this() {
        // Init ourselves first.
	    super();
        this.setDefaultSize(WIN_WIDTH, WIN_HEIGHT);

        // Init the buttons and input boxes.
        this.smoothScrolling = new CheckButton("Enable smooth scrolling");
        this.pageCache = new CheckButton("Enable page caching");
        this.javascript = new CheckButton("Enable javascript");
        this.mediaSource = new CheckButton("Enable Media Source");
        this.homepage = new Entry();

        // Set current values.
        this.smoothScrolling.setActive(SMOOTH_SCROLLING);
        this.pageCache.setActive(PAGE_CACHE);
        this.javascript.setActive(JAVASCRIPT);
        this.mediaSource.setActive(MEDIASOURCE);
        this.homepage.setText(HOMEPAGE);

        // Add items to boxes.
        auto tabs = new Notebook();

        auto engine = new VBox(false, 10);
        packBox(engine, this.smoothScrolling);
        packBox(engine, this.pageCache);
        packBox(engine, this.javascript);
        packBox(engine, this.mediaSource);
        tabs.appendPage(engine, new Label("Engine"));

        auto browsing = new VBox(false, 10);
        packBox(browsing, new Label("Homepage"));
        packBox(browsing, this.homepage);
        tabs.appendPage(browsing, new Label("Browsing"));

        // Add the tabs and response and show all.
        this.getContentArea().packStart(tabs, true, true, 0);
        this.addOnResponse(toDelegate(&(this.saveCloseSignal)));
        this.showAll();
    }

    private void saveCloseSignal(int signal, Dialog dialog) {
        switch (signal) {
            case CLOSE_SIGNAL:
                SMOOTH_SCROLLING = this.smoothScrolling.getActive();
                PAGE_CACHE = this.pageCache.getActive();
                JAVASCRIPT = this.javascript.getActive();
                MEDIASOURCE = this.mediaSource.getActive();
                HOMEPAGE = this.homepage.getText();
                saveSettings();
                break;
            default:
                break;
        }
    }
}
