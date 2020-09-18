module backend.webkit.context;

import std.string: toStringz;

alias WebkitContext       = void*;
alias WebkitCookieManager = void*;

enum CookiePolicy {
    AcceptAlways,
    AcceptNever,
    AcceptNoThirdParty
}

extern (C) {
    WebkitContext webkit_web_context_new();
    WebkitCookieManager webkit_web_context_get_cookie_manager(WebkitContext);
    void webkit_cookie_manager_set_accept_policy(WebkitCookieManager, CookiePolicy);
}

class Context {
    private WebkitContext inner;

    @property void acceptPolicy(CookiePolicy policy) {
        auto cop = webkit_web_context_get_cookie_manager(inner);
        webkit_cookie_manager_set_accept_policy(cop, policy); 
    }

    this(WebkitContext s) {
        inner = s;
    }

    this() {
        inner = webkit_web_context_new();
    }
}
