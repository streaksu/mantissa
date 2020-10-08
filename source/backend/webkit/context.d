module backend.webkit.context;

import std.string: toStringz;
import backend.webkit.cookiemanager: WebkitCookieManager, CookieManager;

alias WebkitWebContext = void*;

/// Possible cache models for a WebContext.
enum CacheModel {
    DocumentViewer, /// Disable the cache completely, which substantially reduces
                    /// memory usage. Useful for applications that only access
                    /// a single local file, with no navigation to other pages.
                    /// No remote resources will be cached.
    WebBrowser,     /// Improve document load speed substantially by caching a
                    /// very large number of resources and previously viewed
                    /// content.
    DocumentBrowser, /// A cache model optimized for viewing a series of
                     /// local files -- for example, a documentation viewer or
                     /// a website designer. WebKit will cache a moderate
                     /// number of resources.
}

private extern (C) {
    WebkitWebContext webkit_web_context_new();
    WebkitWebContext webkit_web_context_new_ephemeral();
    WebkitCookieManager webkit_web_context_get_cookie_manager(WebkitWebContext);
    bool webkit_web_context_is_ephemeral(WebkitWebContext);
    bool webkit_web_context_is_automation_allowed(WebkitWebContext);
    void webkit_web_context_set_automation_allowed(WebkitWebContext, bool);
    CacheModel webkit_web_context_get_cache_model(WebkitWebContext);
    void webkit_web_context_set_cache_model(WebkitWebContext, CacheModel);
    void webkit_web_context_clear_cache(WebkitWebContext);
    bool webkit_web_context_get_sandbox_enabled(WebkitWebContext);
    void webkit_web_context_set_sandbox_enabled(WebkitWebContext, bool);
    void webkit_web_context_add_path_to_sandbox(WebkitWebContext, immutable(char)*, bool);
    bool webkit_web_context_get_spell_checking_enabled(WebkitWebContext);
    void webkit_web_context_set_spell_checking_enabled(WebkitWebContext, bool);
}

/**
 * Manages aspects common to all Webviews.
 */
class WebContext {
    /// The inner webkit struct pointer.
    WebkitWebContext webkitWebContext;

    /**
     * Get the CookieManager of the context.
     */
    @property CookieManager cookieManager() {
        return new CookieManager(webkit_web_context_get_cookie_manager(webkitWebContext));
    }

    /**
     * Get whether the WebContext is ephemeral.
     */
    @property bool isEphemeral() {
        return webkit_web_context_is_ephemeral(webkitWebContext);
    }

    /**
     * Get whether automation is allowed in context.
     */
    @property bool automationAllowed() {
        return webkit_web_context_is_automation_allowed(webkitWebContext);
    }

    /**
     * Set whether automation is allowed in context.
     *
     * When automation is enabled the browser could be controlled by another
     * process by requesting an automation session. When a new automation
     * session is requested the signal “automation-started” is emitted.
     * Automation is disabled by default, so you need to explicitly call this
     * method passing TRUE to enable it.
     *
     * Note that only one WebContext can have automation enabled, so this will
     * do nothing if there's another WebContext with automation already enabled.
     */
    @property void automationAllowed(bool allow) {
        webkit_web_context_set_automation_allowed(webkitWebContext, allow);
    }

    /**
     * Get the current cache model.
     */
    @property CacheModel automationAllowed() {
        return webkit_web_context_get_cache_model(webkitWebContext);
    }

    /**
     * Specifies a usage model for Webviews, which Webkit will use to determine
     * its caching behavior.
     *
     * All web views follow the cache model. This cache model determines the RAM
     * and disk space to use for caching previously viewed content.
     *
     * Research indicates that users tend to browse within clusters of documents
     * that hold resources in common, and to revisit previously visited documents.
     * Webkit and the frameworks below it include built-in caches that take
     * advantage of these patterns, substantially improving document load speed
     * in browsing situations. The Webkit cache model controls the behaviors of
     * all of these caches, including various WebCore caches.
     */
    @property void automationAllowed(CacheModel model) {
        webkit_web_context_set_cache_model(webkitWebContext, model);
    }

    /**
     * Get whether sandboxing is currently enabled.
     */
    @property bool sandboxEnabled() {
        return webkit_web_context_get_sandbox_enabled(webkitWebContext);
    }

    /**
     * Set whether Webkit subprocesses will be sandboxed, limiting access to the
     * system.
     *
     * This method **must be called before any web process has been created**, as
     * early as possible in your application. Calling it later is a fatal error.
     *
     * This is only implemented on Linux and is a no-op otherwise.
     */
    @property void sandboxEnabled(bool enable) {
        webkit_web_context_set_sandbox_enabled(webkitWebContext, enable);
    }

    /**
     * Get whether spell checking feature is currently enabled.
     */
    @property bool spellCheckingEnabled() {
        return webkit_web_context_get_spell_checking_enabled(webkitWebContext);
    }

    /**
     * Enable or disable the spell checking feature.
     */
    @property void spellCheckingEnabled(bool enable) {
        webkit_web_context_set_spell_checking_enabled(webkitWebContext, enable);
    }

    /**
     * Creates a new context, ephemeral or not depending on the argument.
     *
     * An ephemeral Context is a context created with an ephemeral DataManager.
     * This is just a convenient method to create ephemeral contexts without
     * having to create your own DataManager. All Webviews associated with this
     * context will also be ephemeral. Websites will not store any data in the
     * client storage. This is normally used to implement private instances.
     */
    this(bool isEphemeral = false) {
        if (isEphemeral) {
            webkitWebContext = webkit_web_context_new_ephemeral();
        } else {
            webkitWebContext = webkit_web_context_new();
        }
    }

    /**
     * Creates a new object using an inner webkit pointer.
     */
    this(WebkitWebContext s) {
        webkitWebContext = s;
    }

    /**
     * Clears all resources currently cached.
     */
    void clearCache() {
        webkit_web_context_clear_cache(webkitWebContext);
    }

    /**
     * Adds a path to be mounted in the sandbox.
     *
     * Path must exist before any web process has been created, otherwise it
     * will be silently ignored. It is a fatal error to add paths after a web
     * process has been spawned.
     *
     * Paths in directories such as /sys, /proc, and /dev or all of / are not
     * valid.
     */
    void addPathToSandbox(string path, bool readonly) {
        webkit_web_context_add_path_to_sandbox(webkitWebContext, toStringz(path), readonly);
    }
}
