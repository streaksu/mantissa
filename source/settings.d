module preferences;

import gio.Settings: Settings;
import globals:      gschemaName;

private immutable smoothScrollingKey = "smooth-scrolling";
private immutable pageCacheKey       = "page-cache";
private immutable javascriptKey      = "javascript";
private immutable sitequirksKey      = "site-quirks";
private immutable homepageKey        = "homepage";
private immutable cookiePolicyKey    = "cookie-policy";
private immutable forceHTTPSKey      = "force-https";
private immutable insecureContentKey = "insecure-content";

class BrowserSettings : Settings {
    @property bool   smoothScrolling() { return getBoolean(smoothScrollingKey); }
    @property bool   pageCache()       { return getBoolean(pageCacheKey);       }
    @property bool   javascript()      { return getBoolean(javascriptKey);      }
    @property bool   sitequirks()      { return getBoolean(sitequirksKey);      }
    @property string homepage()        { return getString(homepageKey);         }
    @property int    cookiePolicy()    { return getInt(cookiePolicyKey);        }
    @property bool   forceHTTPS()      { return getBoolean(forceHTTPSKey);      }
    @property bool   insecureContent() { return getBoolean(insecureContentKey); }

    @property void smoothScrolling(bool b) { setBoolean(smoothScrollingKey, b); }
    @property void pageCache(bool b)       { setBoolean(pageCacheKey, b);       }
    @property void javascript(bool b)      { setBoolean(javascriptKey, b);      }
    @property void sitequirks(bool b)      { setBoolean(sitequirksKey, b);      }
    @property void homepage(string d)      { setString(homepageKey, d);         }
    @property void cookiePolicy(int a)     { setInt(cookiePolicyKey, a);        }
    @property void forceHTTPS(bool b)      { setBoolean(forceHTTPSKey, b);      }
    @property void insecureContent(bool b) { setBoolean(insecureContentKey, b); }

    this() {
        super(gschemaName);
    }
}
