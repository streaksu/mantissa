module backend.webview;

import std.string;
import gtk.Widget;
import gobject.Signals;
import backend.webviewsettings;

private extern (C) GtkWidget* webkit_web_view_new();
private extern (C) void webkit_web_view_load_uri(GtkWidget*, immutable(char)*);
private extern (C) char* webkit_web_view_get_uri(GtkWidget*);
private extern (C) char* webkit_web_view_get_title(GtkWidget*);
private extern (C) bool webkit_web_view_can_go_back(GtkWidget*);
private extern (C) bool webkit_web_view_can_go_forward(GtkWidget*);
private extern (C) WebkitSettings webkit_web_view_get_settings(GtkWidget*);
private extern (C) void webkit_web_view_set_settings(GtkWidget*, WebkitSettings);

private extern (C) void webkit_web_view_go_back(GtkWidget*);
private extern (C) void webkit_web_view_go_forward(GtkWidget*);
private extern (C) void webkit_web_view_reload(GtkWidget*);

class Webview : Widget {
    private GtkWidget* webview;

    @property auto uri() { return cast(string)fromStringz(webkit_web_view_get_uri(this.webview)); }
    @property auto title() { return cast(string)fromStringz(webkit_web_view_get_title(this.webview)); }
    @property auto canGoBack() { return webkit_web_view_can_go_back(this.webview); }
    @property auto canGoForward() { return webkit_web_view_can_go_forward(this.webview); }
    @property auto settings() { return new WebviewSettings(webkit_web_view_get_settings(this.webview)); }

    @property void uri(string uri) { webkit_web_view_load_uri(this.webview, toStringz(uri)); }
    @property void settings(WebviewSettings s) { webkit_web_view_set_settings(this.webview, s.settings); }

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

    void addOnUriChange(void delegate(Webview) dlg) {
        Signals.connect(this, "load-changed", dlg);
    }
}
