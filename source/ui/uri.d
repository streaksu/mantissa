/// Classify and analyze URIs.
module ui.uri;

import std.string: startsWith, indexOf;

/// Types a URI can be.
enum URIType {
    LocalFile,   /// A local file or directory.
    XDGOpen,     /// External apps and links to be opened with xdgopen.
    WebResource, /// Points to an online site.
    Search       /// Phrase for search using a search engine.
}

/// Guess the nature of a URI.
///
/// The guessed type can be guessed upon a malformed URI, or things that simply
/// wont work when passed to webkit, therefore, this guessed type is meant
/// to be used as an indicative for further refinement, using for example
/// `normalizeURI`.
URIType guessURIType(string uri) {
    import std.file: exists;

    if (exists(uri) || startsWith(uri, "file://")) {
        return URIType.LocalFile;
    } else if (startsWith(uri, "magnet:")) {
        return URIType.XDGOpen;
    } else if (startsWith(uri, "http://") || startsWith(uri, "https://") ||
               startsWith(uri, "ftp://")  || indexOf(uri, '.') != -1) {
        return URIType.WebResource;
    } else {
        return URIType.Search;
    }
}

unittest {
    assert(guessURIType("https://google.com") == URIType.WebResource);
    assert(guessURIType("how to cook pasta")  == URIType.Search);
    assert(guessURIType("youtube.com")        == URIType.WebResource);
    assert(guessURIType("ftp://example.org")  == URIType.WebResource);
    assert(guessURIType("https what is")      == URIType.Search);
}

/// Take a URI and try to adjust it for standard compliance with the passed
/// type.
string normalizeURI(string uri, URIType type) {
    import storage.usersettings: getSearchEngineURL;

    final switch (type) {
        case URIType.LocalFile:
            return "file://" ~ uri;
        case URIType.XDGOpen:
            return uri;
        case URIType.WebResource:
            return startsWith(uri, "http") ? uri : "https://" ~ uri;
        case URIType.Search:
            return getSearchEngineURL() ~ uri;
    }
}

unittest {
    assert(normalizeURI("/home/robert", URIType.LocalFile)  == "file:///home/robert");
    assert(normalizeURI("youtube.com", URIType.WebResource) == "https://youtube.com");
}
