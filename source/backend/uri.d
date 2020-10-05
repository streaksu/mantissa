module backend.uri;

import std.file:   exists;
import std.string: startsWith, indexOf;
import storage:    UserSettings;

/// Types a URI can be.
enum URIType {
    LocalFile,   /// A local file or directory.
    WebResource, /// Points to an online site.
    Search,      /// Phrase for search using a search engine.
}

/**
 * Guess the nature of a URI.
 *
 * The guessed type can be guessed upon a malformed URI, or things that simply
 * wont work when passed to webkit, therefore, this guessed type is meant
 * to be used as an indicative for further refinement, using for example
 * `normalizeURI`.
 */
URIType guessURIType(string uri) {
    if (exists(uri) || startsWith(uri, "file://")) {
        return URIType.LocalFile;
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

/**
 * Take a URI and try to adjust it for standard compliance with the passed
 * type.
 */
string normalizeURI(string uri, URIType type) {
    final switch (type) {
        case URIType.LocalFile:
            return "file://" ~ uri;
        case URIType.WebResource:
            return startsWith(uri, "http") ? uri : "https://" ~ uri;
        case URIType.Search:
            return UserSettings.searchEngine ~ uri;
    }
}

unittest {
    assert(normalizeURI("/home/robert", URIType.LocalFile)  == "file:///home/robert");
    assert(normalizeURI("youtube.com", URIType.WebResource) == "https://youtube.com");
}
