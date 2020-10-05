module frontend.searchbar;

import std.string:          fromStringz, indexOf;
import std.typecons:        No;
import std.functional:      toDelegate;
import gtk.c.types:         EntryIconPosition, DialogFlags, ResponseType;
import gobject.c.types:     GType;
import gtk.Entry:           Entry;
import gtk.EntryCompletion: GtkEntryCompletion, EntryCompletion;
import gtk.Window:          Window;
import gtk.EditableIF:      EditableIF;
import gtk.TreeModelIF:     TreeModelIF;
import gdk.Event:           Event;
import gtk.ListStore:       ListStore;
import gtk.TreeIter:        GtkTreeIter, TreeIter;
import gtk.Dialog:          Dialog;
import gtk.Label:           Label;
import gtk.Image:           Image, IconSize;
import backend.uri:         URIType, guessURIType, normalizeURI;
import storage:             HistoryStore;

private immutable SAFE_ICON   = "system-lock-screen-symbolic";
private immutable UNSAFE_ICON = "dialog-warning-symbolic";

/**
 * Search bar of the browser.
 * Text for webviews is requested using the same methods as a normal entry.
 * That is, `getText` and `addOnActivate`.
 */
final class SearchBar : Entry {
    private Window          parent;
    private EntryCompletion completion;
    private ListStore       completionList;
    private TreeIter        mainOption;

    /**
     * Create the search bar and process some triggers.
     */
    this(Window p) {
        parent         = p;
        completion     = new EntryCompletion();
        completionList = new ListStore([GType.STRING, GType.STRING, GType.STRING]);
        mainOption     = completionList.createIter();
        completion.setModel(completionList);
        completion.setTextColumn(0);
        completion.setMatchFunc(&match, cast(void*)this, null);

        const auto history = HistoryStore.history;
        foreach (item; history) {
            auto iter = completionList.createIter();
            completionList.setValue(iter, 0, item.title ~ " - " ~ item.uri);
            completionList.setValue(iter, 1, item.title);
            completionList.setValue(iter, 2, item.uri);
        }

        completion.addOnMatchSelected(toDelegate(&matchSelectedSignal));
        setCompletion(completion);
        addOnChanged(toDelegate(&preeditChangedSignal));
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

    private void preeditChangedSignal(EditableIF) {
        const auto uri            = getText();
        const auto mainOptionType = guessURIType(uri);

        string mainOptionMessage;
        final switch (mainOptionType) {
            case URIType.LocalFile:
                mainOptionMessage = uri ~ " - Open File";
                break;
            case URIType.WebResource:
                mainOptionMessage = uri ~ " - Visit";
                break;
            case URIType.Search:
                mainOptionMessage = uri ~ " - Search";
                break;
        }
        completionList.setValue(mainOption, 0, mainOptionMessage);
        completionList.setValue(mainOption, 1, "");
        completionList.setValue(mainOption, 2, uri);
    }

    private bool matchSelectedSignal(TreeModelIF, TreeIter iter, EntryCompletion) {
        // FIXME: For some reason comparing with `is` iter and mainOption returns
        // false even though they are the same. This is an ugly workaround for that.
        iter.setModel(completionList);
        mainOption.setModel(completionList);
        const auto itertitle = iter.getValueString(0);
        const auto expected  = mainOption.getValueString(0);

        if (itertitle == expected) {
            const auto uri = mainOption.getValueString(2);
            setText(normalizeURI(uri, guessURIType(uri)));
        } else {
            setText(iter.getValueString(2));
        }

        return true;
    }
}

// Called to match the entries of the completion, and see if they match.
// FIXME: Why is this prototype so foreign to GtkD?
private extern(C) int match(GtkEntryCompletion*, const(char)* k, GtkTreeIter* it, void* t) {
    // Netting the variables from C.
    auto searchbar = cast(SearchBar)t;
    auto key       = fromStringz(k);
    auto iter      = new TreeIter(it);

    // Modify the entry.
    iter.setModel(searchbar.completionList);
    searchbar.mainOption.setModel(searchbar.completionList);

    if (iter.getValueString(0) == searchbar.mainOption.getValueString(0)) {
        return 1;
    } else {
        const auto index = indexOf(iter.getValueString(1), key, No.caseSensitive);
        return index != -1 ? 1 : 0;
    }
}
