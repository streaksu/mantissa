module main;

import std.getopt;
import std.stdio;
import core.stdc.stdlib;
import gtk.Main;
import globals;
import settings;
import frontend.browser;

void main(string[] args) {
    // Init GTK.
    Main.init(args);

    // Set defaults and handle command line.
    bool vers  = false;
    auto settings = new BrowserSettings();
    string url = settings.homepage;

    try {
        auto cml = getopt(
            args,
            "V|version", "Print the version and targets", &vers,
            "u|url", "URL to open with the browser", &url
        );

        if (cml.helpWanted) {
            defaultGetoptPrinter("Flags and options:", cml.options);
            exit(0);
        }
    } catch (Exception e) {
        writefln("ERROR: %s", e.msg);
        exit(1);
    }

    if (vers) {
        writefln("%s %s", programName, programVersion);
        writefln("Distributed under the %s license", programLicense);
        exit(0);
    }

    // Create browser window and run.
    new Browser(url);
    Main.run();
}
