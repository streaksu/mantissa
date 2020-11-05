module findbar;

import gtk.SearchBar:  SearchBar;
import gtk.Entry:      Entry;
import gtk.EditableIF: EditableIF;

/**
 * Implements the "find on website" bar.
 */
class FindBar : SearchBar {
    private Entry entry;

    /**
     * Constructs the object.
     */
    this() {
        entry = new Entry();
        add(entry);
        connectEntry(entry);
        showAll();
    }

    /**
     * Add a callback for when the search changes.
     */
    void addOnChangedSearch(void delegate(Entry) func) {
        entry.addOnChanged((EditableIF e) { func(cast(Entry)e); });
    }

    /**
     * Add a callback for when the next item of the search is requested.
     */
    void addOnNextRequested(void delegate() func) {
        entry.addOnActivate((Entry) { func(); });
    }
}
