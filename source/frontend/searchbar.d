module frontend.searchbar;

import std.functional: toDelegate;
import gtk.c.types:    EntryIconPosition, DialogFlags, ResponseType;
import gtk.Entry:      Entry;
import gtk.Window:     Window;
import gdk.Event:      Event;
import gtk.Dialog:     Dialog;
import gtk.Label:      Label;
import gtk.Image:      Image, IconSize;

private immutable SAFE_ICON   = "system-lock-screen-symbolic";
private immutable UNSAFE_ICON = "dialog-warning-symbolic";

/**
 * Search bar of the browser.
 * Text for webviews is requested using the same methods as a normal entry.
 * That is, `getText` and `addOnActivate`.
 */
final class SearchBar : Entry {
    private Window parent;

    /**
     * Create the search bar and process some triggers.
     */
    this(Window p) {
        parent = p;
        addOnIconPress(toDelegate(&iconPressSignal));
    }

    /**
     * Set the icon to mark a secure or not secure website.
     */
    void setSecureIcon(bool isSecure) {
        auto icon = isSecure ? SAFE_ICON : UNSAFE_ICON;
        setIconFromIconName(EntryIconPosition.PRIMARY, icon);
    }

    /**
     * Removes the resource security icon.
     */
    void removeIcon() {
        setIconFromIconName(EntryIconPosition.PRIMARY, null);
    }

    // Called when the icon of the search bar is pressed.
    private void iconPressSignal(EntryIconPosition pos, Event, Entry e) {
        const auto icon = e.getIconName(pos);
        auto dialog = new Dialog(
            "Security info",
            parent,
            DialogFlags.DESTROY_WITH_PARENT,
            ["Close"],
            [ResponseType.CLOSE]
        );
        auto cont = dialog.getContentArea();

        cont.packStart(new Image(icon, IconSize.DIALOG), true, true, 10);
        if (icon == SAFE_ICON) {
            cont.add(new Label("This resource is safe!"));
            cont.add(new Label("Your connection with this resource is secured, your data cannot be stolen"));
        } else {
            cont.add(new Label("This resource is not safe!"));
            cont.add(new Label("Your connection with this resource is unsecured, your data could be stolen!"));
            cont.add(new Label("Please search for secure alternatives, or contact the resource admins"));
        }

        dialog.showAll();
        dialog.run();
        dialog.destroy();
    }
}
