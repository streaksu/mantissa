module backend.webkit.urirequest;

import std.string: fromStringz, toStringz;

/// Inner type for a webkit pointer.
alias WebkitURIRequest = void*;

private extern (C) {
    WebkitURIRequest webkit_uri_request_new(immutable(char)*);
    immutable(char)* webkit_uri_request_get_uri(WebkitURIRequest);
    void webkit_uri_request_set_uri(WebkitURIRequest, immutable(char)*);
}

/**
 * Represents a URI request.
 */
class URIRequest {
    /// The inner webkit struct pointer.
    WebkitURIRequest webkitURIRequest;

    /**
     * Get the URI of the request.
     */
    @property string uri() {
        return fromStringz(webkit_uri_request_get_uri(webkitURIRequest));
    }

    /**
     * Set the URI of the request.
     */
    @property void uri(string toSet) {
        webkit_uri_request_set_uri(webkitURIRequest, toStringz(toSet));
    }

    /**
     * Creates a new object for the given uri.
     */
    this(string givenURI) {
        webkitURIRequest = webkit_uri_request_new(toStringz(givenURI));
    }

    /**
     * Creates a new object using an inner webkit pointer.
     */
    this(WebkitURIRequest request) {
        webkitURIRequest = request;
    }
}
