module preferences;

import gio.Settings;
import globals;

private immutable smoothScrollingKey = "smooth-scrolling";
private immutable pageCacheKey       = "page-cache";
private immutable javascriptKey      = "javascript";
private immutable sitequirksKey      = "site-quirks";
private immutable homepageKey        = "homepage";

class BrowserSettings {
    private Settings s;

    @property bool   smoothScrolling() { return s.getBoolean(smoothScrollingKey); }
    @property bool   pageCache()       { return s.getBoolean(pageCacheKey);       }
    @property bool   javascript()      { return s.getBoolean(javascriptKey);      }
    @property bool   sitequirks()      { return s.getBoolean(sitequirksKey);      }
    @property string homepage()        { return s.getString(homepageKey);         }

    @property void smoothScrolling(bool b) { s.setBoolean(smoothScrollingKey, b); }
    @property void pageCache(bool b)       { s.setBoolean(pageCacheKey, b);       }
    @property void javascript(bool b)      { s.setBoolean(javascriptKey, b);      }
    @property void sitequirks(bool b)      { s.setBoolean(sitequirksKey, b);      }
    @property void homepage(string d)      { s.setString(homepageKey, d);         }

    this() {
        s = new Settings(gschemaName);
    }
}
