module backend.url;

import std.regex;
import std.file;

private immutable NO_PROTOCOL = ctRegex!(r"^[a-zA-Z0-9\.]+[\.][a-zA-Z0-9]+$");

string urlFromUserInput(string userURL) {
    if (exists(userURL)) {
        return "file://" ~ userURL;
    } else if (matchAll(userURL, NO_PROTOCOL)) {
        return "https://" ~ userURL;
    } else {
        return userURL;
    }
}
