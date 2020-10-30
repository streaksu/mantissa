module customview;

import gobject.ObjectG:    ObjectG;
import gobject.ParamSpec:  ParamSpec;
import webkit2.WebView:    WebView;
import webkit2.WebContext: WebContext;
import storage:            HistoryStore, UserSettings;

shared static this() {
    import std.file:              exists, mkdirRecurse, write;
    import glib.Util:             Util;
    import webkit2.CookieManager: CookieAcceptPolicy, CookiePersistentStorage;
    import globals:               programNameRaw;

    // Setup the default webcontext.
    auto cookies = WebContext.getDefault.getCookieManager();
    cookies.setAcceptPolicy(cast(CookieAcceptPolicy)UserSettings.cookiePolicy);
    if (UserSettings.cookieKeep) {
        auto storepath = Util.buildFilename([Util.getUserDataDir(), programNameRaw]);
        auto store     = Util.buildFilename([storepath, "cookies.sqlite"]);

        if (!exists(store)) {
            mkdirRecurse(storepath);
            write(store, "");
        }

        cookies.setPersistentStorage(store, CookiePersistentStorage.SQLITE);
        cookies.addOnChanged((CookieManager){});
    }
}

/**
 * A webview-derived class made with the specific needs of the browser
 * in mind, it's recommended to always use this version instead of the
 * default webview.
 */
class CustomView : WebView {
    /**
     * Construct the object.
     * It takes whether the new webview will use private browsing or not, or
     * a related webview.
     * A webview cannot be initialized as related and private at once.
     */
    this(WebView related = null, bool isPrivate = false) {
        assert(!(related !is null && isPrivate != false));

        // Initialize the object first and manage non-private settings.
        if (related !is null) {
            super(related);
        } else if (isPrivate) {
            super(WebContext.newEphemeral());
        } else {
            super();
        }

        // Wire the user settings.
        auto settings = getSettings();
        settings.setEnableSmoothScrolling(UserSettings.smoothScrolling);
        settings.setEnablePageCache(UserSettings.pageCache);
        settings.setEnableJavascript(UserSettings.javascript);
        settings.setEnableSiteSpecificQuirks(UserSettings.sitequirks);
    }
}
