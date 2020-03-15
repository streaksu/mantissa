module backend.webviewsettings;

alias WebkitSettings = void*;

extern (C) WebkitSettings webkit_settings_new();
extern (C) void webkit_settings_set_enable_smooth_scrolling(WebkitSettings view, bool set);
extern (C) void webkit_settings_set_enable_page_cache(WebkitSettings view, bool set);
extern (C) void webkit_settings_set_enable_javascript(WebkitSettings view, bool set);
extern (C) void webkit_settings_set_enable_mediasource(WebkitSettings view, bool set);

class WebviewSettings {
    private WebkitSettings backend;

    @property WebkitSettings settings() { return this.backend; }

    @property void smoothScrolling(bool set) { webkit_settings_set_enable_smooth_scrolling(this.backend, set); }
    @property void pageCache(bool set) { webkit_settings_set_enable_page_cache(this.backend, set); }
    @property void javascript(bool set) { webkit_settings_set_enable_javascript(this.backend, set); }
    @property void mediasource(bool set) { webkit_settings_set_enable_javascript(this.backend, set); }

    this(WebkitSettings s) {
        this.backend = s;
    }

    this() {
        this.backend = webkit_settings_new();
    }
}
