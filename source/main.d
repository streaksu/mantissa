module main;

import gtk.Main;
import settings;
import frontend.browser;

void main(string[] args) {
    // Take homepage url from commandline.
    auto url = args.length > 1 ? args[1] : HOMEPAGE;

    Main.init(args);
    auto browser = new Browser(url);
    Main.run();
}
