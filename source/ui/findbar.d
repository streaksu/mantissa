module ui.findbar;

import gtk.SearchBar:  SearchBar;
import gtk.Entry:      Entry, EntryIconPosition;
import gtk.Button:     Button, IconSize;
import gtk.EditableIF: EditableIF;

/**
 * Implements the "find on website" bar.
 */
class FindBar : SearchBar {
    private Entry  entry;
    private Button previousButton;
    private Button nextButton;
    private Button closeButton;

    /**
     * Constructs the object.
     */
    this() {
        import gtk.HBox: HBox;
        auto box       = new HBox(false, 0);
        entry          = new Entry();
        previousButton = new Button("go-up-symbolic",        IconSize.MENU);
        nextButton     = new Button("go-down-symbolic",      IconSize.MENU);
        closeButton    = new Button("window-close-symbolic", IconSize.MENU);
        box.packStart(entry,          true,  true,  0);
        box.packStart(previousButton, false, false, 0);
        box.packStart(nextButton,     false, false, 0);
        box.packEnd(closeButton,      false, false, 0);
        entry.setIconFromIconName(EntryIconPosition.PRIMARY, "edit-find-symbolic");
        closeButton.addOnPressed((Button) { setSearchMode(false); });
        add(box);
        connectEntry(entry);
        showAll();
    }

    /**
     * Add a callback for when the search of a string is requested.
     * The callback will be called
     */
    void addOnSearchRequest(void delegate(string) callback) {
        entry.addOnChanged((EditableIF e) {
            auto text = (cast(Entry)e).getText;
            if (text != null) {
                callback(text);
            }
        });
    }

    /**
     * Add a callback for when the previous item of the search is requested.
     */
    void addOnPreviousRequested(void delegate() callback) {
        previousButton.addOnPressed((Button) { callback(); });
    }

    /**
     * Add a callback for when the next item of the search is requested.
     */
    void addOnNextRequested(void delegate() callback) {
        entry.addOnActivate((Entry)      { callback(); });
        nextButton.addOnPressed((Button) { callback(); });
    }
}
