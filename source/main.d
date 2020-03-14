module main;

import gtk.Main;
import frontend.browser;
import frontend.preferences;

void main(string[] args) {
    Main.init(args);
    auto browser = new Browser(HOMEPAGE);
    Main.run();
}
