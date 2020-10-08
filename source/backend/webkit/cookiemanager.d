module webkit.cookiemanager;

import std.string:      toStringz;
import gtk.Widget:      GtkWidget, Widget;
import gobject.Signals: Signals;

alias WebkitCookieManager = void*;

/// Cookie acceptance policies.
enum CookieAcceptPolicy {
    AcceptAlways,      /// Accept all cookies unconditionally.
    AcceptNever,       /// Reject all cookies unconditionally.
    AcceptNoThirdParty /// Accept only cookies set by the main document loaded.
}

/// Cookie persistent storage types.
enum PersistentStorage {
    Text,  /// Text file in the Mozilla "cookies.txt" format.
    SQLite /// SQLite file in the current Mozilla format.
}

private extern (C) {
    void webkit_cookie_manager_set_persistent_storage(WebkitCookieManager, immutable(char*), PersistentStorage);
    void webkit_cookie_manager_set_accept_policy(WebkitCookieManager, CookieAcceptPolicy);
}

/**
 * Defines how to handle cookies in a WebContext
 */
class CookieManager : Widget {
    /// The inner webkit struct pointer.
    WebkitCookieManager webkitCookieManager;

    /**
     * Set the cookie acceptance policy.
     */
    @property void acceptPolicy(CookieAcceptPolicy policy) {
        webkit_cookie_manager_set_accept_policy(webkitCookieManager, policy);
    }

    /**
     * Creates a new object using an inner webkit pointer.
     */
    this(WebkitCookieManager manager, bool ownedRef = false) {
        webkitCookieManager = manager;
        super(cast(GtkWidget*)webkitCookieManager, ownedRef);
    }

    /**
     * Set the file where non-session cookies are stored persistently using
     * storage as the format to read/write the cookies.
     *
     * Cookies are initially
     * read from filename to create an initial set of cookies. Then, non-session
     * cookies will be written to filename when the changed signal is emitted.
     *
     * By default, CookieManager doesn't store the cookies persistently, so you
     * need to call this method to keep cookies saved across sessions.
     */
    void setPersistentStorage(string file, PersistentStorage type) {
        webkit_cookie_manager_set_persistent_storage(webkitCookieManager, toStringz(file), type);
    }

    /**
     * Add on the changed signal.
     */
    void addOnChanged(void delegate(CookieManager) dlg) {
        Signals.connect(this, "changed", dlg);
    }
}
