module frontend.searchbar;

import std.string:          fromStringz;
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
import backend.url:         URIGuessedType, guessURIType;
import frontend.history:    getHistory;
import settings:            BrowserSettings;

private immutable SAFE_ICON   = "system-lock-screen-symbolic";
private immutable UNSAFE_ICON = "dialog-warning-symbolic";

/**
 * Search bar of the browser.
 * Text for webviews is requested using the same methods as a normal entry.
 * That is, `getText` and `addOnActivate`.
 */
final class SearchBar : Entry {
    private BrowserSettings settings;
    private Window          parent;
    private EntryCompletion completion;
    private ListStore       completionList;
    private TreeIter        mainOption;
    private URIGuessedType  mainOptionType;
    private string          mainOptionURI;

    /**
     * Create the search bar and process some triggers.
     */
    this(Window p) {
        settings       = new BrowserSettings();
        parent         = p;
        completion     = new EntryCompletion();
        completionList = new ListStore([GType.STRING]);
        mainOption     = completionList.createIter();
        completionList.setValue(mainOption, 0, "Placeholder");
        completion.setModel(completionList);
        completion.setTextColumn(0);
        completion.setMatchFunc(&match, cast(void*)this, null);

        const auto history = getHistory();
        foreach (uri; history) {
            auto iter = completionList.createIter();
            completionList.setValue(iter, 0, uri);
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
        mainOptionURI  = getText();
        mainOptionType = guessURIType(mainOptionURI);

        string mainOptionMessage;
        final switch (mainOptionType) {
            case URIGuessedType.LocalFile:
                mainOptionMessage = mainOptionURI ~ " - Open File";
                break;
            case URIGuessedType.WebResource:
                mainOptionMessage = mainOptionURI ~ " - Visit";
                break;
            case URIGuessedType.Search:
                mainOptionMessage = mainOptionURI ~ " - Search";
                break;
        }
        completionList.setValue(mainOption, 0, mainOptionMessage);
    }

    private bool matchSelectedSignal(TreeModelIF, TreeIter iter, EntryCompletion) {
        // FIXME: For some reason comparing with `is` iter and mainOption returns
        // false even though they are the same. This is an ugly workaround for that.
        iter.setModel(completionList);
        mainOption.setModel(completionList);
        const auto uri      = iter.getValueString(0);
        const auto expected = mainOption.getValueString(0);

        if (uri == expected) {
            final switch (mainOptionType) {
                case URIGuessedType.LocalFile:
                    setText("file://" ~ mainOptionURI);
                    break;
                case URIGuessedType.WebResource:
                    setText(mainOptionURI);
                    break;
                case URIGuessedType.Search:
                    setText(settings.searchEngine ~ mainOptionURI);
                    break;
            }
        } else {
            setText(uri);
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
    if (iter is searchbar.mainOption) {
        return 1;
    } else {
        import std.string:   indexOf;
        import std.typecons: No;
        iter.setModel(searchbar.completionList);
        const auto index = indexOf(iter.getValueString(0), key, No.caseSensitive);
        return index != -1 ? 1 : 0;
    }
}
