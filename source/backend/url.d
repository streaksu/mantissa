module backend.url;

import std.file:   exists;
import std.string: startsWith;

/**
 * Takes user input and tries to sanitize it into a real URL.
 */
string urlFromUserInput(string userURL) {
    if (exists(userURL)) {
        return "file://" ~ userURL;
    } else if (startsWith(userURL, "http") || startsWith(userURL, "ftp")
            || startsWith(userURL, "file")) {
        return userURL;
    } else {
        return "http://" ~ userURL;
    }
}
