module frontend.options;

import std.functional:       toDelegate;
import gtk.MenuButton:       MenuButton;
import gtk.Menu:             Menu;
import gtk.MenuItem:         MenuItem;
import frontend.about:       About;
import frontend.preferences: Preferences;
import globals:              programName;

/**
 * Options button for the headerbar.
 */
final class Options : MenuButton {
    private Menu     popup;
    private MenuItem preferences;
    private MenuItem about;

    /**
     * Constructs the widget.
     */
    this() {
        // Initialize everything and signals.
        popup       = new Menu();
        preferences = new MenuItem("Preferences");
        about       = new MenuItem("About " ~ programName);    

        preferences.addOnActivate(toDelegate(&preferencesSignal));
        about.addOnActivate(toDelegate(&aboutSignal));

        // Wire widgets.
        popup.append(preferences);
        popup.append(about);
        popup.showAll();
        setPopup(popup);
    }

    // Called when the preferences item is deemed active.
    private void preferencesSignal(MenuItem) {
        new Preferences();
    }

    // Called when the about item is deemed active.
    private void aboutSignal(MenuItem) {
        new About();
    }
}
