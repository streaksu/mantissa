module frontend.options;

import std.datetime.systime:  Clock, SysTime;
import gtk.MenuButton:        MenuButton;
import gtk.Menu:              Menu;
import gtk.MenuItem:          MenuItem;
import gtk.SeparatorMenuItem: SeparatorMenuItem;
import frontend.about:        About;
import frontend.preferences:  Preferences;
import globals:               programName;
import storage:               HistoryStore;

/**
 * Options button for the headerbar.
 */
final class Options : MenuButton {
    private Menu     popup;
    private Menu     historyMenu;
    private MenuItem clearTodayHistory;
    private MenuItem clearAllHistory;
    private MenuItem preferences;
    private MenuItem about;
    private void delegate(string) historyCallback;
    private HistoryStore.HistoryURI[] history;

    /**
     * Constructs the widget.
     */
    this(void delegate(string) historyChose) {
        // Initialize everything and signals.
        popup             = new Menu();
        historyMenu       = popup.appendSubmenu("History");
        clearTodayHistory = new MenuItem("Clear Today's History");
        clearAllHistory   = new MenuItem("Clear All History");
        preferences       = new MenuItem("Preferences");
        about             = new MenuItem("About " ~ programName);    
        historyCallback   = historyChose;
        history           = HistoryStore.history;

        clearTodayHistory.addOnActivate(&deleteTodayHistorySignal);
        clearAllHistory.addOnActivate(&deleteAllHistorySignal);
        preferences.addOnActivate(&preferencesSignal);
        about.addOnActivate(&aboutSignal);

        // Wire widgets.
        historyMenu.append(clearTodayHistory);
        historyMenu.append(clearAllHistory);
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
