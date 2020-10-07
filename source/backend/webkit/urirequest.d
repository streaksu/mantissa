module backend.webkit.urirequest;

import std.string: fromStringz;

alias WebkitURIRequest = void*;

private extern (C) {
    immutable(char*) webkit_uri_request_get_uri(WebkitURIRequest);
}

class URIRequest {
    private WebkitURIRequest inner;

    @property string uri() {
        return fromStringz(webkit_uri_request_get_uri(inner));
    }

    this(WebkitURIRequest request) {
        inner = request;
    }
}
