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

enum WebkitLoadEvent {
    Started,
    Redirected,
    Committed,
    Finished
}

class Webview : Widget {
    private GtkWidget* webview;

    @property string uri() {
        return cast(string)fromStringz(webkit_web_view_get_uri(webview));
    }

    @property string title() {
        return cast(string)fromStringz(webkit_web_view_get_title(webview));
    }

    @property bool canGoBack() {
        return webkit_web_view_can_go_back(webview);
    }

    @property bool canGoForward() {
        return webkit_web_view_can_go_forward(webview);
    }

    @property WebviewSettings settings() {
        return new WebviewSettings(webkit_web_view_get_settings(webview));
    }

    @property double isLoading() {
        return webkit_web_view_is_loading(webview);
    }

    @property void uri(string uri) {
        webkit_web_view_load_uri(webview, toStringz(uri));
    }

    @property void settings(WebviewSettings s) {
        webkit_web_view_set_settings(webview, s.settings);
    }

    this(GtkWidget* webview, bool ownedRef = false) {
        webview = webview;
        super(webview, ownedRef);
    }

    this() {
        webview = webkit_web_view_new();
        super(webview);
    }

    void goBack() {
        webkit_web_view_go_back(webview);
    }

    void goForward() {
        webkit_web_view_go_forward(webview);
    }

    void reload() {
        webkit_web_view_reload(webview);
    }
    
    void stopLoading() {
        webkit_web_view_stop_loading(webview);
    }

    void addOnLoadChanged(void delegate(Webview, WebkitLoadEvent) dlg) {
        Signals.connect(this, "load-changed", dlg);
    }
}
