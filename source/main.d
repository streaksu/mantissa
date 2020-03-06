module main;

import gtk.Main;
import frontend.browser;

void main(string[] args) {
    Main.init(args);
    auto browser = new Browser("https://google.com");
    Main.run();
}
