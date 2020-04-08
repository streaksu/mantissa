module preferences;

import gio.Settings;
import globals;

private immutable SMOOTH_SCROLLING_KEY = "smooth-scrolling";
private immutable PAGE_CACHE_KEY       = "page-cache";
private immutable JAVASCRIPT_KEY       = "javascript";
private immutable SITEQUIRKS_KEY       = "site-quirks";
private immutable HOMEPAGE_KEY         = "homepage";
private immutable HEADERBAR_KEY        = "headerbar";

shared bool   SMOOTH_SCROLLING;
shared bool   PAGE_CACHE;
shared bool   JAVASCRIPT;
shared bool   SITEQUIRKS;
shared string HOMEPAGE;
shared bool   HEADERBAR;

shared static this() {
    auto s = new Settings(GSCHEMA_NAME);

    SMOOTH_SCROLLING = s.getBoolean(SMOOTH_SCROLLING_KEY);
    PAGE_CACHE       = s.getBoolean(PAGE_CACHE_KEY);
    JAVASCRIPT       = s.getBoolean(JAVASCRIPT_KEY);
    SITEQUIRKS       = s.getBoolean(SITEQUIRKS_KEY);
    HOMEPAGE         = s.getString(HOMEPAGE_KEY);
    HEADERBAR        = s.getBoolean(HEADERBAR_KEY);
}

void saveSettings() {
    auto s = new Settings(GSCHEMA_NAME);

    s.setBoolean(SMOOTH_SCROLLING_KEY, SMOOTH_SCROLLING);
    s.setBoolean(PAGE_CACHE_KEY, PAGE_CACHE);
    s.setBoolean(JAVASCRIPT_KEY, JAVASCRIPT);
    s.setBoolean(SITEQUIRKS_KEY, SITEQUIRKS);
    s.setString(HOMEPAGE_KEY, HOMEPAGE);
    s.setBoolean(HEADERBAR_KEY, HEADERBAR);
}
