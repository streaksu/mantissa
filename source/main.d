/// Main function and its most immediate utilities.
module main;

import gio.FileIF:      FileIF;
import gio.Application: gioApplication = Application;
import gtk.Application: Application;
import ui.browser:      Browser;

/// GTKApplication that represents the browser to the GTK ecosystem.
/// It handles everything from opening commandline files to main windows.
final class MainApplication : Application {
    /// Will create the object and set up the proper signals.
    this() {
        import gio.c.types: ApplicationFlags;
        import globals:     programID;

        super(programID, ApplicationFlags.HANDLES_OPEN | ApplicationFlags.NON_UNIQUE);
        addOnActivate(&activateSignal);
        addOnOpen(&openTabsSignal);
    }

    // When no URL to be opened is passed, this is called instead of
    // openTabsSignal.
    // In this case we are going to open a new main window.
    private void activateSignal(gioApplication) {
        import storage.usersettings: getHomepage;
        addWindow(new Browser(this, getHomepage()));
    }

    // When some URLs are to be opened, this is called instead of
    // activateSignal.
    // In this case, we will want to append tabs to the active window.
    private void openTabsSignal(FileIF[] files, string, gioApplication) {
        size_t i = 0;
        auto win = cast(Browser)getActiveWindow();
        if (win is null) {
            win = new Browser(this, files[0].getUri);
            addWindow(win);
            i++;
        }

        for (; i < files.length; i++) {
            win.newTab(files[i].getUri());
        }
    }
}

/// Main function of the program.
void main(string[] args) {
    auto app = new MainApplication();
    app.run(args);
}
