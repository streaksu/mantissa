module preferences;

import gio.Settings;
import globals;

private immutable smoothScrollingKey = "smooth-scrolling";
private immutable pageCacheKey       = "page-cache";
private immutable javascriptKey      = "javascript";
private immutable sitequirksKey      = "site-quirks";
private immutable homepageKey        = "homepage";

class BrowserSettings {
    bool   smoothScrolling;
    bool   pageCache;
    bool   javascript;
    bool   sitequirks;
    string homepage;

    this() {
        auto s = new Settings(gschemaName);
        smoothScrolling = s.getBoolean(smoothScrollingKey);
        pageCache       = s.getBoolean(pageCacheKey);
        javascript      = s.getBoolean(javascriptKey);
        sitequirks      = s.getBoolean(sitequirksKey);
        homepage        = s.getString(homepageKey);
    }

    void save() {
        auto s = new Settings(gschemaName);
        s.setBoolean(smoothScrollingKey, smoothScrolling);
        s.setBoolean(pageCacheKey, pageCache);
        s.setBoolean(javascriptKey, javascript);
        s.setBoolean(sitequirksKey, sitequirks);
        s.setString(homepageKey, homepage);
    }
}
