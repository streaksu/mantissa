module options;

import std.datetime.systime:  Clock, SysTime;
import gtk.MenuButton:        MenuButton;
import gtk.Menu:              Menu;
import gtk.MenuItem:          MenuItem;
import gtk.ImageMenuItem:     ImageMenuItem;
import gtk.SeparatorMenuItem: SeparatorMenuItem;
import gtk.Image:             Image, IconSize;
import translations:          _;
import about:                 About;
import preferences:           Preferences;
import globals:               programName;
import storage:               HistoryStore;

/**
 * Options button for the headerbar.
 */
final class Options : MenuButton {
    private Menu     popup;
    private Menu     historyMenu;
    private MenuItem privateBrowsing;
    private MenuItem findText;
    private MenuItem clearTodayHistory;
    private MenuItem clearAllHistory;
    private ImageMenuItem preferences;
    private ImageMenuItem about;
    private void delegate(string) historyCallback;
    private HistoryStore.HistoryURI[] history;

    /**
     * Constructs the widget.
     */
    this(void delegate(string) historyChose) {
        // Initialize everything and signals.
        popup             = new Menu();
        historyMenu       = popup.appendSubmenu(_("History"));
        privateBrowsing   = new MenuItem(_("New Private Tab"));
        findText          = new MenuItem(_("Find in Website"));
        clearTodayHistory = new MenuItem(_("Clear Today's History"));
        clearAllHistory   = new MenuItem(_("Clear All History"));
        preferences       = new ImageMenuItem(_("Preferences"));
        about             = new ImageMenuItem(_("About Mantissa"));    
        historyCallback   = historyChose;
        history           = HistoryStore.history;

        clearTodayHistory.addOnActivate(&deleteTodayHistorySignal);
        clearAllHistory.addOnActivate(&deleteAllHistorySignal);
        preferences.setImage(new Image("preferences-other-symbolic", IconSize.MENU));
        preferences.setAlwaysShowImage(true);
        preferences.addOnActivate(&preferencesSignal);
        about.setImage(new Image("help-about-symbolic", IconSize.MENU));
        about.setAlwaysShowImage(true);
        about.addOnActivate(&aboutSignal);

        // Wire widgets.
        historyMenu.append(clearTodayHistory);
        historyMenu.append(clearAllHistory);
        popup.append(privateBrowsing);
        popup.append(findText);
        popup.append(preferences);
        popup.append(about);

        // Fill history and bookmarks listing.
        historyMenu.append(new SeparatorMenuItem());
        foreach_reverse (uri; history) {
            auto item = new MenuItem(uri.title);
            item.addOnActivate(&historyChosenSignal);
            historyMenu.append(item);
        }

        // Set popup.
        historyMenu.showAll();
        popup.showAll();
        setPopup(popup);
    }

    /**
     * Add callback for when the user requests a private tab.
     */
    void addOnPrivateTabRequest(void delegate() callback) {
        privateBrowsing.addOnActivate((MenuItem) {
            callback();
        });
    }

    /**
     * Add callback for when the user requests find.
     */
    void addOnFindRequest(void delegate() callback) {
        findText.addOnActivate((MenuItem) {
            callback();
        });
    }

    // Called when the user wants to delete the history of the day.
    private void deleteTodayHistorySignal(MenuItem) {
        const auto curr = Clock.currTime;
        foreach (uri; history) {
            if (curr.day == uri.time.day) {
                HistoryStore.deleteEntry(uri);
            }
        }
    }

    // Called when the user wants to delete ALL history.
    private void deleteAllHistorySignal(MenuItem) {
        foreach (uri; history) {
            HistoryStore.deleteEntry(uri);
        }
    }

    // Called when the preferences item is deemed active.
    private void preferencesSignal(MenuItem) {
        new Preferences();
    }

    // Called when the about item is deemed active.
    private void aboutSignal(MenuItem) {
        new About();
    }

    // Activated when a history item is chosen.
    private void historyChosenSignal(MenuItem item) {
        foreach (uri; history) {
            if (item.getLabel() == uri.title) {
                historyCallback(uri.uri);
                break;
            }
        }
    }
}
