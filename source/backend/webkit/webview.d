module backend.webkit.webview;

import std.string;
import gtk.Widget;
import gobject.Signals;
import backend.webkit.webviewsettings;

extern (C) GtkWidget* webkit_web_view_new();
extern (C) void webkit_web_view_load_uri(GtkWidget*, immutable(char)*);
extern (C) char* webkit_web_view_get_uri(GtkWidget*);
extern (C) char* webkit_web_view_get_title(GtkWidget*);
extern (C) bool webkit_web_view_can_go_back(GtkWidget*);
extern (C) bool webkit_web_view_can_go_forward(GtkWidget*);
extern (C) WebkitSettings webkit_web_view_get_settings(GtkWidget*);
extern (C) bool webkit_web_view_is_loading(GtkWidget*);
extern (C) void webkit_web_view_set_settings(GtkWidget*, WebkitSettings);
extern (C) void webkit_web_view_go_back(GtkWidget*);
extern (C) void webkit_web_view_go_forward(GtkWidget*);
extern (C) void webkit_web_view_reload(GtkWidget*);
extern (C) void webkit_web_view_stop_loading(GtkWidget*);

class Webview : Widget {
    private GtkWidget* webview;

    @property string uri() {
        return cast(string)fromStringz(webkit_web_view_get_uri(this.webview));
    }

    @property string title() {
        return cast(string)fromStringz(webkit_web_view_get_title(this.webview));
    }

    @property bool canGoBack() {
        return webkit_web_view_can_go_back(this.webview);
    }

    @property bool canGoForward() {
        return webkit_web_view_can_go_forward(this.webview);
    }

    @property WebviewSettings settings() {
        return new WebviewSettings(webkit_web_view_get_settings(this.webview));
    }

    @property double isLoading() {
        return webkit_web_view_is_loading(this.webview);
    }

    @property void uri(string uri) {
        webkit_web_view_load_uri(this.webview, toStringz(uri));
    }

    @property void settings(WebviewSettings s) {
        webkit_web_view_set_settings(this.webview, s.settings);
    }

    this(GtkWidget* webview, bool ownedRef = false) {
        this.webview = webview;
        super(this.webview, ownedRef);
    }

    this() {
        this.webview = webkit_web_view_new();
        super(this.webview);
    }

    void goBack() {
        webkit_web_view_go_back(this.webview);
    }

    void goForward() {
        webkit_web_view_go_forward(this.webview);
    }

    void reload() {
        webkit_web_view_reload(this.webview);
    }
    
    void stopLoading() {
        webkit_web_view_stop_loading(this.webview);
    }

    void addOnLoadChanged(void delegate(Webview) dlg) {
        Signals.connect(this, "load-changed", dlg);
    }
}
