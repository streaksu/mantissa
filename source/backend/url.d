module backend.url;

import std.file: exists;

/**
 * Takes user input and tries to sanitize it into a real URL.
 */
string urlFromUserInput(string userURL) {
    if (exists(userURL)) {
        return "file://" ~ userURL;
    } else {
        return "http://" ~ userURL;
    }
}
