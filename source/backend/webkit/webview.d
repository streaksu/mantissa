module backend.webkit.inner;

import std.string;
import gtk.Widget;
import gobject.Signals;
import backend.webkit.context;
import backend.webkit.navigationaction: NavigationAction;
import backend.webkit.webviewsettings;

alias WebkitView = void*;

private extern (C) {
    WebkitView webkit_web_view_new();
    WebkitView webkit_web_view_new_with_related_view(WebkitView);
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
    WebkitView inner;

    @property string uri() {
        return cast(string)fromStringz(webkit_web_view_get_uri(inner));
    }

    @property Context context() {
        return new Context(webkit_web_view_get_context(inner));
    }

    @property string title() {
        return cast(string)fromStringz(webkit_web_view_get_title(inner));
    }

    @property bool canGoBack() {
        return webkit_web_view_can_go_back(inner);
    }

    @property bool canGoForward() {
        return webkit_web_view_can_go_forward(inner);
    }

    @property WebviewSettings settings() {
        return new WebviewSettings(webkit_web_view_get_settings(inner));
    }

    @property double isLoading() {
        return webkit_web_view_is_loading(inner);
    }

    @property void uri(string uri) {
        webkit_web_view_load_uri(inner, toStringz(uri));
    }

    @property void settings(WebviewSettings s) {
        webkit_web_view_set_settings(inner, s.settings);
    }

    @property bool getTLSInfo() {
        return webkit_web_view_get_tls_info(inner, null, null);
    }

    this(WebkitView webv, bool ownedRef = false) {
        inner = webv;
        super(cast(GtkWidget*)inner, ownedRef);
    }

    this() {
        inner = webkit_web_view_new();
        super(cast(GtkWidget*)inner);
    }

    this(Webview view) {
        inner = webkit_web_view_new_with_related_view(view.inner);
        super(cast(GtkWidget*)inner);
    }

    ~this() {

    }

    void tryClose() {
        webkit_web_view_try_close(inner);
    }

    void goBack() {
        webkit_web_view_go_back(inner);
    }

    void goForward() {
        webkit_web_view_go_forward(inner);
    }

    void reload() {
        webkit_web_view_reload(inner);
    }
    
    void stopLoading() {
        webkit_web_view_stop_loading(inner);
    }

    void loadAlternateHTML(string html, string uri, string baseURI) {
        webkit_web_view_load_alternate_html(inner, toStringz(html),
            toStringz(uri), toStringz(baseURI));
    }

    void addOnLoadChanged(void delegate(Webview, LoadEvent) dlg) {
        Signals.connect(this, "load-changed", dlg);
    }

    void addOnLoadFailed(bool delegate(Webview, LoadEvent, string, void*) dlg) {
        Signals.connect(this, "load-failed", dlg);
    }

    void addOnInsecureContent(void delegate(Webview, InsecureContentEvent) dlg) {
        Signals.connect(this, "insecure-content-detected", dlg);
    }

    void addOnCreate(Webview delegate(Webview, NavigationAction) dlg) {
        Signals.connect(this, "create", dlg);
    }
}
