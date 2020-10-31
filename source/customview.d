module customview;

import gobject.ObjectG:                ObjectG;
import gobject.ParamSpec:              ParamSpec;
import gobject.ObjectG:                GObject;
import gio.SimpleAsyncResult:          GAsyncResult, GSimpleAsyncResult, SimpleAsyncResult;
import webkit2.WebView:                WebView;
import webkit2.WebContext:             WebContext;
import webkit2.UserContentFilter:      UserContentFilter;
import webkit2.UserContentFilterStore: UserContentFilterStore, WebKitUserContentFilterStore;
import storage:                        HistoryStore, UserSettings;

shared static this() {
    import core.atomic:           atomicLoad;
    import std.file:              exists, mkdirRecurse, write;
    import glib.Util:             Util;
    import glib.Bytes:            Bytes;
    import webkit2.CookieManager: CookieAcceptPolicy, CookiePersistentStorage;
    import globals:               programNameRaw;

    // Path for data storage of the browser.
    auto storepath = Util.buildFilename([Util.getUserDataDir(), programNameRaw]);

    // Setup the default webcontext.
    auto cookies = WebContext.getDefault.getCookieManager();
    cookies.setAcceptPolicy(cast(CookieAcceptPolicy)UserSettings.cookiePolicy);
    if (UserSettings.cookieKeep) {
        auto store = Util.buildFilename([storepath, "cookies.sqlite"]);

        if (!exists(store)) {
            mkdirRecurse(storepath);
            write(store, "");
        }

        cookies.setPersistentStorage(store, CookiePersistentStorage.SQLITE);
        cookies.addOnChanged((CookieManager){}); // If not added, it wont work.
    }

    // Create the user filters.
    auto filterpath = Util.buildFilename([storepath, "filters"]);
    auto filters    = new UserContentFilterStore(filterpath);
    filters.save("insecureContent", new Bytes(cast(ubyte[])`[{
        "trigger": {
            "url-filter": "http\\:",
            "resource-type": ["image", "style-sheet", "script", "media"]
        },
        "action": {
            "type": "css-display-none",
            "selector": "img, script"
        }
    }]`), null, &saveFilter1, null);
    filters.save("forceHTTPS", new Bytes(cast(ubyte[])`[{
        "trigger": {
            "url-filter": "http\\:"
        },
        "action": {
            "type": "block"
        }
    }]`), null, &saveFilter2, null);
}

private extern(C) void saveFilter1(GObject* obj, GAsyncResult* res, void*) {
    import core.atomic: atomicStore;

    auto store  = new UserContentFilterStore(cast(WebKitUserContentFilterStore*)obj, false);
    auto result = new SimpleAsyncResult(cast(GSimpleAsyncResult*)res, false);
    atomicStore(insecureContentFilter, cast(shared)store.saveFinish(result));
}

private extern(C) void saveFilter2(GObject* obj, GAsyncResult* res, void*) {
    import core.atomic: atomicStore;

    auto store  = new UserContentFilterStore(cast(WebKitUserContentFilterStore*)obj, false);
    auto result = new SimpleAsyncResult(cast(GSimpleAsyncResult*)res, false);
    atomicStore(forceHTTPSFilter, cast(shared)store.saveFinish(result));
}

private shared UserContentFilter insecureContentFilter;
private shared UserContentFilter forceHTTPSFilter;

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
        auto content  = getUserContentManager();
        settings.setEnableSmoothScrolling(UserSettings.smoothScrolling);
        settings.setEnablePageCache(UserSettings.pageCache);
        settings.setEnableJavascript(UserSettings.javascript);
        settings.setEnableSiteSpecificQuirks(UserSettings.sitequirks);
        if (!UserSettings.insecureContent) {
            content.addFilter(cast()insecureContentFilter);
        }
        if (UserSettings.forceHTTPS) {
            content.addFilter(cast()forceHTTPSFilter);
        }
    }
}
