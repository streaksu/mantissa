module backend.webkit.navigationaction;

import backend.webkit.urirequest: WebkitURIRequest, URIRequest;

alias WebkitNavigationAction = void*;

private extern (C) {
    void webkit_navigation_action_free(WebkitNavigationAction);
    WebkitURIRequest webkit_navigation_action_get_request(WebkitNavigationAction);
}

final class NavigationAction {
    private WebkitNavigationAction inner;
    private bool                   ownedRef;

    @property URIRequest request() {
        return new URIRequest(webkit_navigation_action_get_request(inner));
    }

    this(WebkitNavigationAction manager, bool ow = false) {
        inner    = manager;
        ownedRef = ow;
    }

    ~this() {
        webkit_navigation_action_free(inner);
    }
}
