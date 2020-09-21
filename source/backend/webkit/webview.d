module backend.webkit.webview;

import std.string;
import gtk.Widget;
import gobject.Signals;
import backend.webkit.context;
import backend.webkit.webviewsettings;

alias WebkitView = void*;

private extern (C) {
    WebkitView webkit_web_view_new();
    void webkit_web_view_load_uri(WebkitView, immutable(char)*);
    bool  webkit_web_view_get_tls_info(WebkitView, void**, void*);
    WebkitContext webkit_web_view_get_context(WebkitView);
    char* webkit_web_view_get_uri(WebkitView);
    char* webkit_web_view_get_title(WebkitView);
    void webkit_web_view_load_alternate_html(WebkitView, immutable(char)*, immutable(char)*, immutable(char)*);
    void webkit_web_view_try_close(WebkitView);
    bool webkit_web_view_can_go_back(WebkitView);
    bool webkit_web_view_can_go_forward(WebkitView);
    WebkitSettings webkit_web_view_get_settings(WebkitView);
    bool webkit_web_view_is_loading(WebkitView);
    void webkit_web_view_set_settings(WebkitView, WebkitSettings);
    void webkit_web_view_go_back(WebkitView);
    void webkit_web_view_go_forward(WebkitView);
    void webkit_web_view_reload(WebkitView);
    void webkit_web_view_stop_loading(WebkitView);
}

enum LoadEvent {
    Started,
    Redirected,
    Committed,
    Finished
}

enum InsecureContentEvent {
    Run,
    Displayed
}

class Webview : Widget {
    private WebkitView webview;

    @property string uri() {
        return cast(string)fromStringz(webkit_web_view_get_uri(webview));
    }

    @property Context context() {
        return new Context(webkit_web_view_get_context(webview));
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

    @property bool getTLSInfo() {
        return webkit_web_view_get_tls_info(webview, null, null);
    }

    this(WebkitView webv, bool ownedRef = false) {
        webview = webv;
        super(cast(GtkWidget*)webview, ownedRef);
    }

    this() {
        webview = webkit_web_view_new();
        super(cast(GtkWidget*)webview);
    }

    void tryClose() {
        webkit_web_view_try_close(webview);
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

    void loadAlternateHTML(string html, string uri, string baseURI) {
        webkit_web_view_load_alternate_html(webview, toStringz(html),
            toStringz(uri), toStringz(baseURI));
    }

    void addOnLoadChanged(void delegate(Webview, LoadEvent) dlg) {
        Signals.connect(this, "load-changed", dlg);
    }

    void addOnInsecureContent(void delegate(Webview, InsecureContentEvent) dlg) {
        Signals.connect(this, "insecure-content-detected", dlg);
    }
}
