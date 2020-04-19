module backend.webkit.webviewsettings;

alias WebkitSettings = void*;

extern (C) WebkitSettings webkit_settings_new();
extern (C) void webkit_settings_set_enable_smooth_scrolling(WebkitSettings, bool);
extern (C) void webkit_settings_set_enable_page_cache(WebkitSettings, bool);
extern (C) void webkit_settings_set_enable_javascript(WebkitSettings, bool);
extern (C) void webkit_settings_set_enable_site_specific_quirks(WebkitSettings, bool);

class WebviewSettings {
    private WebkitSettings backend;

    @property WebkitSettings settings() {
        return backend;
    }

    @property void smoothScrolling(bool set) {
        webkit_settings_set_enable_smooth_scrolling(backend, set);
    }

    @property void pageCache(bool set) {
        webkit_settings_set_enable_page_cache(backend, set);
    }

    @property void javascript(bool set) {
        webkit_settings_set_enable_javascript(backend, set);
    }

    @property void siteSpecificQuirks(bool set) {
        webkit_settings_set_enable_site_specific_quirks(backend, set);
    }

    this(WebkitSettings s) {
        backend = s;
    }

    this() {
        backend = webkit_settings_new();
    }
}
