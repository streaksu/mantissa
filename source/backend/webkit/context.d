module backend.webkit.context;

import backend.webkit.cookiemanager: WebkitCookieManager, CookieManager;

alias WebkitContext = void*;

private extern (C) {
    WebkitContext webkit_web_context_new();
    WebkitCookieManager webkit_web_context_get_cookie_manager(WebkitContext);
}

class Context {
    private WebkitContext inner;

    @property CookieManager cookieManager() {
        return new CookieManager(webkit_web_context_get_cookie_manager(inner));
    }

    this(WebkitContext s) {
        inner = s;
    }

    this() {
        inner = webkit_web_context_new();
    }
}
