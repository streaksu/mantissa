module backend.webkit.inner;

import std.string:                      fromStringz, toStringz;
import gtk.Widget:                      Widget, GtkWidget;
import gobject.Signals:                 Signals;
import backend.webkit.context:          WebkitWebContext, WebContext;
import backend.webkit.settings:         WebkitSettings, Settings;
import backend.webkit.navigationaction: NavigationAction;

alias WebkitWebview = void*;

private extern (C) {
    WebkitWebview webkit_web_view_new();
    WebkitWebview webkit_web_view_new_with_related_view(WebkitWebview);
    void webkit_web_view_load_uri(WebkitWebview, immutable(char)*);
    bool  webkit_web_view_get_tls_info(WebkitWebview, void**, void*);
    WebkitWebContext webkit_web_view_get_context(WebkitWebview);
    char* webkit_web_view_get_uri(WebkitWebview);
    char* webkit_web_view_get_title(WebkitWebview);
    void webkit_web_view_load_alternate_html(WebkitWebview, immutable(char)*, immutable(char)*, immutable(char)*);
    void webkit_web_view_try_close(WebkitWebview);
    bool webkit_web_view_can_go_back(WebkitWebview);
    bool webkit_web_view_can_go_forward(WebkitWebview);
    WebkitSettings webkit_web_view_get_settings(WebkitWebview);
    bool webkit_web_view_is_loading(WebkitWebview);
    void webkit_web_view_set_settings(WebkitWebview, WebkitSettings);
    void webkit_web_view_go_back(WebkitWebview);
    void webkit_web_view_go_forward(WebkitWebview);
    void webkit_web_view_reload(WebkitWebview);
    void webkit_web_view_stop_loading(WebkitWebview);
}

/// The different events that happen during a Webview load operation.
enum LoadEvent {
    Started,    /// A new load request has been made. No data has been received yet.
    Redirected, /// A provisional data source received a server redirect.
    Committed,  /// The content started arriving for a page load. The load is being performed.
    Finished    /// Load completed.
}

/// Different events which can trigger the detection of insecure content.
enum InsecureContentEvent {
    Run,      /// Detected by trying to run logic (e.g. a script).
    Displayed /// Detected by trying to display a resource (e.g. an image).
}

/**
 * The central class of the WPE Webkit and WebkitGTK APIs
 */
class Webview : Widget {
    /// The inner webkit struct pointer.
    WebkitWebview webkitWebview;

    /**
     * Returns the current URI of the view. The URI might change during a load:
     * 1. If nothing has been loaded yet, it could be null.
     *
     * 2. When a new load starts:
     *      - If the load was started by loadURI, it will be the given one.
     *      - If the load was started by loadHTML, it will be "about:blank".
     *      - If the load was started by loadAlternateHTML, it will be the content.
     *      - If the load was started by goBack or goForward, it will be the original URI of the previous/next item.
     *
     * 3. If there is a server redirection during the load operation, the active
     * URI is the redirected URI. When the signal “load-changed” is emitted with
     * Redirected event, the active URI is already updated to the redirected URI.
     *
     * 4. When the signal “load-changed” is emitted with Commited event, the active
     * URI is the final one and it will not change unless a new load operation
     * is started or a navigation action within the same page is performed.
     *
     * You can monitor the active URI by connecting to the signal.
     */
    @property string uri() {
        return cast(string)fromStringz(webkit_web_view_get_uri(webkitWebview));
    }

    /**
     * Set the navigation URI using loadURI for the view.
     */
    @property void uri(string uri) {
        webkit_web_view_load_uri(webkitWebview, toStringz(uri));
    }

    /**
     * Return the WebContext that rules this Webview.
     */
    @property WebContext context() {
        return new WebContext(webkit_web_view_get_context(webkitWebview));
    }

    /**
     * Gets the value of the “title” property. You can connect to the signal of
     * to be notified when the title has been received.
     */
    @property string title() {
        return cast(string)fromStringz(webkit_web_view_get_title(webkitWebview));
    }

    /**
     * Determines whether web_view has a previous history item.
     */
    @property bool canGoBack() {
        return webkit_web_view_can_go_back(webkitWebview);
    }

    /**
     * Determines whether web_view has a next history item.
     */
    @property bool canGoForward() {
        return webkit_web_view_can_go_forward(webkitWebview);
    }

    /**
     * Return whether the view is loading a resource.
     */
    @property double isLoading() {
        return webkit_web_view_is_loading(webkitWebview);
    }

    /**
     * Returns the settings the webview is using.
     */
    @property Settings settings() {
        return new Settings(webkit_web_view_get_settings(webkitWebview));
    }

    /**
     * Sets settings for the view.
     */
    @property void settings(Settings s) {
        webkit_web_view_set_settings(webkitWebview, s.webkitSettings);
    }

    /**
     * Returns true if the connection is HTTPS, else, false.
     */
    @property bool getTLSInfo() {
        return webkit_web_view_get_tls_info(webkitWebview, null, null);
    }

    /**
     * Create a new webview.
     */
    this() {
        webkitWebview = webkit_web_view_new();
        super(cast(GtkWidget*)webkitWebview);
    }

    /**
     * Creates a new related view with the passed view.
     *
     * A related view is a view sharing the same web process.
     *
     * The newly created WebKitWebView will also have the same ContentManager,
     * Settings, and WebsitePolicies as the passed one.
     */
    this(Webview view) {
        webkitWebview = webkit_web_view_new_with_related_view(view.webkitWebview);
        super(cast(GtkWidget*)webkitWebview);
    }

    /**
     * Creates a new object using an inner webkit pointer.
     */
    this(WebkitWebview webv, bool ownedRef = false) {
        webkitWebview = webv;
        super(cast(GtkWidget*)webkitWebview, ownedRef);
    }

    /**
     * Tries to close the view. This will fire the onbeforeunload
     * event to ask the user for confirmation to close the page. If there isn't
     * an onbeforeunload event handler or the user confirms to close the page,
     * the “close” signal is emitted, otherwise nothing happens.
     */
    void tryClose() {
        webkit_web_view_try_close(webkitWebview);
    }

    /**
     * Loads the previous history item. You can monitor the load operation by
     * connecting to “load-changed” signal.
     */
    void goBack() {
        webkit_web_view_go_back(webkitWebview);
    }

    /**
     * Loads the next history item. You can monitor the load operation by
     * connecting to “load-changed” signal.
     */
    void goForward() {
        webkit_web_view_go_forward(webkitWebview);
    }

    /**
     * Reloads the current contents of Webview.
     */
    void reload() {
        webkit_web_view_reload(webkitWebview);
    }

    /**
     * Stops any ongoing loading operation. This method does nothing if no
     * content is being loaded. If there is a loading operation in progress, it
     * will be cancelled and “load-failed” signal will be emitted.
     */
    void stopLoading() {
        webkit_web_view_stop_loading(webkitWebview);
    }

    /**
     * Load the given content string for the URI. This allows clients to
     * display page-loading errors in the Webview itself. When this method is called
     * from “load-failed” signal to show an error page, then the back-forward
     * list is maintained appropriately. For everything else this method works
     * the same way as loadHTML().
     */
    void loadAlternateHTML(string html, string uri, string baseURI) {
        webkit_web_view_load_alternate_html(webkitWebview, toStringz(html),
            toStringz(uri), toStringz(baseURI));
    }

    /**
     * Add on load-changed.
     */
    void addOnLoadChanged(void delegate(Webview, LoadEvent) dlg) {
        Signals.connect(this, "load-changed", dlg);
    }

    /**
     * Add on load-failed.
     */
    void addOnLoadFailed(bool delegate(Webview, LoadEvent, string, void*) dlg) {
        Signals.connect(this, "load-failed", dlg);
    }

    /**
     * Add on insecure-content.
     */
    void addOnInsecureContent(void delegate(Webview, InsecureContentEvent) dlg) {
        Signals.connect(this, "insecure-content-detected", dlg);
    }

    /**
     * Add on create.
     */
    void addOnCreate(Webview delegate(Webview, NavigationAction) dlg) {
        Signals.connect(this, "create", dlg);
    }

    /**
     * Add on close.
     */
    void addOnClose(void delegate(Webview) dlg) {
        Signals.connect(this, "close", dlg);
    }

    /**
     * Add on notify::title.
     */
    void addOnTitleChanged(void delegate(Webview) dlg) {
        Signals.connect(this, "notify::title", dlg);
    }
}
