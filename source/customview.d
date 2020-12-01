module customview;

import gobject.ObjectG:                ObjectG;
import gobject.ParamSpec:              ParamSpec;
import gobject.ObjectG:                GObject;
import gio.SimpleAsyncResult:          GAsyncResult, GSimpleAsyncResult, SimpleAsyncResult;
import webkit2.WebView:                WebView;
import webkit2.WebContext:             WebContext;
import webkit2.UserContentFilter:      UserContentFilter;
import webkit2.UserContentFilterStore: UserContentFilterStore, WebKitUserContentFilterStore;
import storage;

shared static this() {
    import std.file:              exists, mkdirRecurse, write;
    import glib.Util:             Util;
    import glib.Bytes:            Bytes;
    import webkit2.CookieManager: CookieAcceptPolicy, CookiePersistentStorage;
    import globals:               programDir;

    // Path for data storage of the browser.
    auto storepath = Util.buildFilename([Util.getUserDataDir(), programDir]);

    // Setup the default webcontext.
    auto cookies = WebContext.getDefault.getCookieManager();
    cookies.setAcceptPolicy(cast(CookieAcceptPolicy)storage.cookiePolicy);
    if (storage.keepCookies) {
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
    }]`), null, &saveFilter, cast(void*)&insecureContentFilter);
    filters.save("forceHTTPS", new Bytes(cast(ubyte[])`[{
        "trigger": {
            "url-filter": "http\\:"
        },
        "action": {
            "type": "block"
        }
    }]`), null, &saveFilter, cast(void*)&forceHTTPSFilter);
}

private extern (C) void saveFilter(GObject* obj, GAsyncResult* res, void* data) {
    import core.atomic: atomicStore;

    auto filter = cast(shared(UserContentFilter)*)data;
    auto store  = new UserContentFilterStore(cast(WebKitUserContentFilterStore*)obj, false);
    auto result = new SimpleAsyncResult(cast(GSimpleAsyncResult*)res, false);
    atomicStore(*filter, cast(shared)store.saveFinish(result));
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
        settings.setEnableSmoothScrolling(storage.smoothScrolling);
        settings.setEnablePageCache(storage.pageCache);
        settings.setEnableJavascript(storage.useJavaScript);
        settings.setEnableSiteSpecificQuirks(storage.useSiteQuirks);
        if (!storage.insecureContent) {
            content.addFilter(cast()insecureContentFilter);
        }
        if (storage.forceHTTPS) {
            content.addFilter(cast()forceHTTPSFilter);
        }
    }
}
