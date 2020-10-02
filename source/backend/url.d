module backend.url;

import std.file:   exists;
import std.string: startsWith;

/// Types a URI can be guessed as.
enum URIGuessedType {
    LocalFile,   /// A local file or directory.
    WebResource, /// Points to an online site.
    Search,      /// Phrase for search using a search engine.
}

/**
 * Guesses the nature of a URI.
 */
URIGuessedType guessURIType(string uri) {
    if (exists(uri)) {
        return URIGuessedType.LocalFile;
    } else if (startsWith(uri, "http") || startsWith(uri, "ftp")) {
        return URIGuessedType.WebResource;
    } else {
        return URIGuessedType.Search;
    }
}
