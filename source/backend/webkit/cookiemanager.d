module webkit.cookiemanager;

import std.string:      toStringz;
import gtk.Widget:      GtkWidget, Widget;
import gobject.Signals: Signals;

alias WebkitCookieManager = void*;

enum CookiePolicy {
    AcceptAlways,
    AcceptNever,
    AcceptNoThirdParty
}

enum PersistentStorage {
    Text,
    SQLite
}

private extern (C) {
    void webkit_cookie_manager_set_accept_policy(WebkitCookieManager, CookiePolicy);
    void webkit_cookie_manager_set_persistent_storage(WebkitCookieManager, immutable(char*), PersistentStorage);
}

class CookieManager : Widget {
    private WebkitCookieManager inner;

    @property void acceptPolicy(CookiePolicy policy) {
        webkit_cookie_manager_set_accept_policy(inner, policy);
    }

    this(WebkitCookieManager manager, bool ownedRef = false) {
        inner = manager;
        super(cast(GtkWidget*)inner, ownedRef);
    }

    void setPersistentStorage(string file, PersistentStorage type) {
        webkit_cookie_manager_set_persistent_storage(inner, toStringz(file), type);
    }

    void addOnChanged(void delegate(CookieManager) dlg) {
        Signals.connect(this, "changed", dlg);
    }
}
