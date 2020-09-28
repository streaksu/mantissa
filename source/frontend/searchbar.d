module frontend.searchbar;

import gtk.c.types: GtkEntryIconPosition;
import gtk.Entry:   Entry;

/**
 * Search bar of the browser.
 * Text for webviews is requested using the same methods as a normal entry.
 * That is, `getText` and `addOnActivate`.
 */
class SearchBar : Entry {
    /**
     * Set the icon to mark a secure or not secure website.
     */
    void setSecureIcon(bool isSecure) {
        auto icon = isSecure ? "system-lock-screen-symbolic" : "dialog-warning-symbolic";
        setIconFromIconName(GtkEntryIconPosition.PRIMARY, icon);
    }

    /**
     * Removes the resource security icon.
     */
    void removeIcon() {
        setIconFromIconName(GtkEntryIconPosition.PRIMARY, null);
    }
}
