module main;

import std.functional:   toDelegate;
import gio.c.types:      GApplicationFlags;
import gio.FileIF:       FileIF;
import gio.Application:  gioApplication = Application;
import gtk.Application:  gtkApplication = Application;
import globals:          programID;
import settings:         BrowserSettings;
import frontend.browser: Browser;

class MainApplication : gtkApplication {
    private Browser mainWindow;

    this() {
        super(programID, GApplicationFlags.HANDLES_OPEN);
        addOnActivate(toDelegate(&activate));
        addOnOpen(toDelegate(&openTabs));
    }

    void activate(gioApplication app) {
        auto settings = new BrowserSettings();
        createOrTab(settings.homepage);
    }

    void openTabs(FileIF[] files, string, gioApplication app) {
        foreach (file; files) {
            createOrTab(file.getUri());
        }
    }

    private void createOrTab(string uri) {
        if (mainWindow is null) {
            mainWindow = new Browser(uri);
            addWindow(mainWindow);
        } else {
            mainWindow.newTab(uri);
        }
    }
}

void main(string[] args) {
    auto app = new MainApplication();
    app.run(args);
}
