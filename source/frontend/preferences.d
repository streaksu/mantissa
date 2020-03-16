module frontend.preferences;

import std.functional: toDelegate;
import gtk.Dialog;
import gtk.CheckButton;
import gtk.Entry;
import gtk.Label;
import settings;

private immutable WIN_WIDTH = 800;
private immutable WIN_HEIGHT = 450;

private immutable SAVE_SIGNAL = 0;
private immutable CLOSE_SIGNAL = 1;

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
                SMOOTH_SCROLLING = this.smoothScrolling.getActive();
                PAGE_CACHE = this.pageCache.getActive();
                JAVASCRIPT = this.javascript.getActive();
                MEDIASOURCE = this.mediaSource.getActive();
                HOMEPAGE = this.homepage.getText();
                saveSettings();
                break;
            case CLOSE_SIGNAL:
                this.close();
                break;
            default:
                break;
        }
    }
}
