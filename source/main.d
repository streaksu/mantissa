module main;

import gtk.Main;
import settings;
import frontend.browser;

void main(string[] args) {
    Main.init(args);
    auto browser = new Browser(HOMEPAGE);
    Main.run();
}
