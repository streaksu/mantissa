module frontend.preferences;

import std.functional: toDelegate;
import gtk.Dialog;
import gtk.CheckButton;
import gtk.Entry;
import gtk.Label;
import gio.Settings;

private immutable WIN_WIDTH = 800;
private immutable WIN_HEIGHT = 450;

private immutable SAVE_SIGNAL = 0;
private immutable CLOSE_SIGNAL = 1;

private immutable SCHEMA_ID = "org.streaksu.Mantissa";
private immutable SMOOTH_SCROLLING_KEY = "smooth-scrolling";
private immutable PAGE_CACHE_KEY = "page-cache";
private immutable JAVASCRIPT_KEY = "javascript";
private immutable MEDIASOURCE_KEY = "mediasource";
private immutable HOMEPAGE_KEY = "homepage";

shared bool SMOOTH_SCROLLING;
shared bool PAGE_CACHE;
shared bool JAVASCRIPT;
shared bool MEDIASOURCE;
shared string HOMEPAGE;

shared static this() {
    auto s = new Settings(SCHEMA_ID);

    SMOOTH_SCROLLING = s.getBoolean(SMOOTH_SCROLLING_KEY);
    PAGE_CACHE = s.getBoolean(PAGE_CACHE_KEY);
    JAVASCRIPT = s.getBoolean(JAVASCRIPT_KEY);
    MEDIASOURCE = s.getBoolean(MEDIASOURCE_KEY);
    HOMEPAGE = s.getString(HOMEPAGE_KEY);
}

class Preferences : Dialog {
    CheckButton smoothScrolling;
    CheckButton pageCache;
    CheckButton javascript;
    CheckButton mediaSource;
    Entry homepage;

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
        auto vbox = this.getContentArea();
        vbox.add(new Label("Engine settings"));
        vbox.add(this.smoothScrolling);
        vbox.add(this.pageCache);
        vbox.add(this.javascript);
        vbox.add(this.mediaSource);
        vbox.add(new Label("Homepage"));
        vbox.add(this.homepage);

        // Add the buttons and show all.
        this.addButton(StockID.SAVE, SAVE_SIGNAL);
        this.addButton(StockID.CLOSE, CLOSE_SIGNAL);
        this.addOnResponse(toDelegate(&(this.saveCloseSignal)));
        this.showAll();
    }

    private void saveCloseSignal(int signal, Dialog dialog) {
        switch (signal) {
            case SAVE_SIGNAL:
                auto s = new Settings(SCHEMA_ID);
                s.setBoolean(SMOOTH_SCROLLING_KEY, this.smoothScrolling.getActive());
                s.setBoolean(PAGE_CACHE_KEY, this.pageCache.getActive());
                s.setBoolean(JAVASCRIPT_KEY, this.javascript.getActive());
                s.setBoolean(MEDIASOURCE_KEY, this.mediaSource.getActive());
                s.setString(HOMEPAGE_KEY, this.homepage.getText());

                SMOOTH_SCROLLING = s.getBoolean(SMOOTH_SCROLLING_KEY);
                PAGE_CACHE = s.getBoolean(PAGE_CACHE_KEY);
                JAVASCRIPT = s.getBoolean(JAVASCRIPT_KEY);
                MEDIASOURCE = s.getBoolean(MEDIASOURCE_KEY);
                HOMEPAGE = s.getString(HOMEPAGE_KEY);
                break;
            case CLOSE_SIGNAL:
                this.close();
                break;
            default:
                break;
        }
    }
}
