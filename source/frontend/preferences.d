module frontend.preferences;

import gtk.MainWindow;

private immutable WIN_WIDTH = 800;
private immutable WIN_HEIGHT = 450;

class Preferences : MainWindow {
    this() {
        // Init ourselves.
        super("Preferences");
        this.setDefaultSize(WIN_WIDTH, WIN_HEIGHT);
        this.showAll();
    }
}
