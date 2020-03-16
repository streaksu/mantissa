module preferences;

import gio.Settings;

private immutable SCHEMA_ID = "org.streaksu.Mantissa";

private immutable SMOOTH_SCROLLING_KEY = "smooth-scrolling";
private immutable PAGE_CACHE_KEY = "page-cache";
private immutable JAVASCRIPT_KEY = "javascript";
private immutable MEDIASOURCE_KEY = "mediasource";
private immutable HOMEPAGE_KEY = "homepage";

shared bool SMOOTH_SCROLLING;
shared bool PAGE_CACHE;
shared bool JAVASCRIPT;
shared bool MEDIASOURCE;
shared string HOMEPAGE;

shared static this() {
    auto s = new Settings(SCHEMA_ID);

    SMOOTH_SCROLLING = s.getBoolean(SMOOTH_SCROLLING_KEY);
    PAGE_CACHE = s.getBoolean(PAGE_CACHE_KEY);
    JAVASCRIPT = s.getBoolean(JAVASCRIPT_KEY);
    MEDIASOURCE = s.getBoolean(MEDIASOURCE_KEY);
    HOMEPAGE = s.getString(HOMEPAGE_KEY);
}

void saveSettings() {
    auto s = new Settings(SCHEMA_ID);

    s.setBoolean(SMOOTH_SCROLLING_KEY, SMOOTH_SCROLLING);
    s.setBoolean(PAGE_CACHE_KEY, PAGE_CACHE);
    s.setBoolean(JAVASCRIPT_KEY, JAVASCRIPT);
    s.setBoolean(MEDIASOURCE_KEY, MEDIASOURCE);
    s.setString(HOMEPAGE_KEY, HOMEPAGE);
}
