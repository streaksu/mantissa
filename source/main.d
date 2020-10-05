module main;

import std.functional:   toDelegate;
import std.algorithm:    remove;
import gio.c.types:      GApplicationFlags;
import gio.FileIF:       FileIF;
import gio.Application:  gioApplication = Application;
import gtk.Application:  Application;
import gtk.Window:       Window;
import globals:          programID;
import frontend.browser: Browser;
import storage:          UserSettings;

/**
 * GTKApplication that represents the browser to the GTK ecosystem.
 * It handles everything from opening commandline files to main windows.
 */
class MainApplication : Application {
    /**
     * Will create the object and set up the proper signals.
     */
    this() {
        super(programID, GApplicationFlags.HANDLES_OPEN); // Handle opening URLs
        addOnActivate(toDelegate(&activateSignal));
        addOnOpen(toDelegate(&openTabsSignal));
    }

    // When no URL to be opened is passed, this is called instead of
    // openTabsSignal.
    // In this case we are going to open a new main window.
    private void activateSignal(gioApplication) {
        addWindow(new Browser(this, UserSettings.homepage));
    }

    // When some URLs are to be opened, this is called instead of
    // activateSignal.
    // In this case, we will want to append tabs to the active window.
    private void openTabsSignal(FileIF[] files, string, gioApplication) {
        auto win = cast(Browser)getActiveWindow();
        if (win is null) {
            win = new Browser(this, files[0].getUri);
            addWindow(win);
            files = files.remove(0);
        }

        foreach (file; files) {
            win.newTab(file.getUri());
        }
    }
}

void main(string[] args) {
    auto app = new MainApplication();
    app.run(args);
}
