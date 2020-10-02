module preferences;

import gio.Settings: Settings;
import globals:      gschemaName;

private immutable smoothScrollingKey = "smooth-scrolling";
private immutable pageCacheKey       = "page-cache";
private immutable javascriptKey      = "javascript";
private immutable sitequirksKey      = "site-quirks";
private immutable homepageKey        = "homepage";
private immutable searchEngineKey    = "search-engine";
private immutable cookiePolicyKey    = "cookie-policy";
private immutable cookieKeepKey      = "cookie-keep";
private immutable forceHTTPSKey      = "force-https";
private immutable insecureContentKey = "insecure-content";

/**
 * Browser settings.
 * These correspond 1:1 to the fields on the GSchema XML file that the browser
 * was bundled with.
 */
class BrowserSettings : Settings {
    /// Does the user want smooth scrolling of windows?
    @property bool smoothScrolling() { return getBoolean(smoothScrollingKey); }
    /// Does the user want to cache pages?
    @property bool pageCache() { return getBoolean(pageCacheKey); }
    /// Does the user want to enable javascript support?
    @property bool javascript() { return getBoolean(javascriptKey); }
    /// Does the user want to enable engine site quirks?
    @property bool sitequirks() { return getBoolean(sitequirksKey); }
    /// Which homepage did the user set to use?
    @property string homepage() { return getString(homepageKey); }
    /// Which cookie policy did the user want? (values documented in the .xml)
    @property int cookiePolicy() { return getInt(cookiePolicyKey); }
    /// Which search engine did the user want?
    @property string searchEngine() { return getString(searchEngineKey); }
    /// Does the user want to keep cookies?
    @property bool cookieKeep() { return getBoolean(cookieKeepKey); }
    /// Does the user want to force HTTPs?
    @property bool forceHTTPS() { return getBoolean(forceHTTPSKey); }
    /// Does the user want to allow insecure content on HTTPs sites?
    @property bool insecureContent() { return getBoolean(insecureContentKey); }

    /// Save smooth scrolling settings.
    @property void smoothScrolling(bool b) { setBoolean(smoothScrollingKey, b); }
    /// Save page caching settings.
    @property void pageCache(bool b) { setBoolean(pageCacheKey, b); }
    /// Save javascript settings.
    @property void javascript(bool b) { setBoolean(javascriptKey, b); }
    /// Save site quirks.
    @property void sitequirks(bool b) { setBoolean(sitequirksKey, b); }
    /// Save the desired homepage.
    @property void homepage(string d) { setString(homepageKey, d); }
    /// Save the desired search engine.
    @property void searchEngine(string a) { setString(searchEngineKey, a); }
    /// Save the desired cookie policy.
    @property void cookiePolicy(int a) { setInt(cookiePolicyKey, a); }
    /// Save cookie saving policy.
    @property void cookieKeep(bool b) { setBoolean(cookieKeepKey, b); }
    /// Save HTTPs enforcing policy.
    @property void forceHTTPS(bool b) { setBoolean(forceHTTPSKey, b); }
    /// Save insecure content policy.
    @property void insecureContent(bool b) { setBoolean(insecureContentKey, b); }

    /**
     * Builds a GSettings instance tailored to what we want in the browser
     * using gschemaName
     */
    this() {
        super(gschemaName);
    }
}
