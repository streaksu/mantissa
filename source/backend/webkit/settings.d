module backend.webkit.settings;

alias WebkitSettings = void*;

private extern (C) {
    WebkitSettings webkit_settings_new();
    bool webkit_settings_get_enable_smooth_scrolling(WebkitSettings);
    void webkit_settings_set_enable_smooth_scrolling(WebkitSettings, bool);
    bool webkit_settings_get_enable_page_cache(WebkitSettings);
    void webkit_settings_set_enable_page_cache(WebkitSettings, bool);
    bool webkit_settings_get_enable_javascript(WebkitSettings);
    void webkit_settings_set_enable_javascript(WebkitSettings, bool);
    bool webkit_settings_get_enable_site_specific_quirks(WebkitSettings);
    void webkit_settings_set_enable_site_specific_quirks(WebkitSettings, bool);
}

/**
 * Control the behaviour of a Webview.
 */
class Settings {
    /// Inner webkit pointer.
    WebkitSettings webkitSettings;

    /**
     * Get whether smooth scrolling is enabled.
     */
    @property bool smoothScrolling() {
        return webkit_settings_get_enable_smooth_scrolling(webkitSettings);
    }

    /**
     * Enable smooth scrolling.
     */
    @property void smoothScrolling(bool set) {
        webkit_settings_set_enable_smooth_scrolling(webkitSettings, set);
    }

    /**
     * Get whether page caching is enabled.
     */
    @property bool pageCache() {
        return webkit_settings_get_enable_page_cache(webkitSettings);
    }

    /**
     * Enable page caching.
     */
    @property void pageCache(bool set) {
        webkit_settings_set_enable_page_cache(webkitSettings, set);
    }

    /**
     * Get whether javascript is enabled.
     */
    @property bool javascript() {
        return webkit_settings_get_enable_javascript(webkitSettings);
    }

    /**
     * Enable javascript support.
     */
    @property void javascript(bool set) {
        webkit_settings_set_enable_javascript(webkitSettings, set);
    }

    /**
     * Get whether site-specific quirks are enabled.
     */
    @property bool siteSpecificQuirks() {
        return webkit_settings_get_enable_site_specific_quirks(webkitSettings);
    }

    /**
     * Enable site-specific quirks.
     */
    @property void siteSpecificQuirks(bool set) {
        webkit_settings_set_enable_site_specific_quirks(webkitSettings, set);
    }

    /**
     * Create a new object.
     */
    this() {
        webkitSettings = webkit_settings_new();
    }

   /**
     * Create with an inner webkit pointer.
     */
    this(WebkitSettings s) {
        webkitSettings = s;
    }
}
