module backend.webview;

import std.string;
import gtk.Widget;
import gobject.Signals;
import frontend.preferences;

alias WebkitSettings = void*;

extern (C) GtkWidget* webkit_web_view_new();
extern (C) void webkit_web_view_load_uri(GtkWidget* view, immutable(char)* uri);
extern (C) char* webkit_web_view_get_uri(GtkWidget* view);
extern (C) bool webkit_web_view_can_go_back(GtkWidget *view);
extern (C) bool webkit_web_view_can_go_forward(GtkWidget *view);
extern (C) void webkit_web_view_go_back(GtkWidget *view);
extern (C) void webkit_web_view_go_forward(GtkWidget *view);
extern (C) char* webkit_web_view_get_title(GtkWidget* view);
extern (C) WebkitSettings webkit_web_view_get_settings(GtkWidget* view);
extern (C) void webkit_web_view_set_settings(GtkWidget* view, WebkitSettings settings);
extern (C) void webkit_settings_set_enable_smooth_scrolling(WebkitSettings view, bool set);
extern (C) void webkit_settings_set_enable_page_cache(WebkitSettings view, bool set);
extern (C) void webkit_settings_set_enable_javascript(WebkitSettings view, bool set);

class Webview : Widget {
    GtkWidget* webview;

    this() {
        // Init the webview.
        this.webview = webkit_web_view_new();
        super(this.webview);

        // Enable settings depending on preferences.
        auto s = webkit_web_view_get_settings(this.webview);
        webkit_settings_set_enable_smooth_scrolling(s, SMOOTH_SCROLLING);
        webkit_settings_set_enable_page_cache(s, PAGE_CACHE);
        webkit_settings_set_enable_javascript(s, JAVASCRIPT);
        webkit_web_view_set_settings(this.webview, s);
    }

    this(GtkWidget* webview, bool ownedRef = false) {
        this.webview = webview;
        super(this.webview, ownedRef);
    }

    void loadUri(string uri) {
        webkit_web_view_load_uri(this.webview, toStringz(uri));
    }

    string getUri() {
        return cast(string)fromStringz(webkit_web_view_get_uri(this.webview));
    }

    bool canGoBack() {
        return webkit_web_view_can_go_back(this.webview);
    }

    bool canGoForward() {
        return webkit_web_view_can_go_forward(this.webview);
    }

    void goBack() {
        webkit_web_view_go_back(this.webview);
    }

    void goForward() {
        webkit_web_view_go_forward(this.webview);
    }

    string getTitle() {
        return cast(string)fromStringz(webkit_web_view_get_title(this.webview));
    }

    void addOnUriChange(void delegate(Webview) dlg) {
        Signals.connect(this, "load-changed", dlg);
    }
}
