module backend.url;

import std.regex;
import std.file;

private immutable noProtocol = ctRegex!(r"^[a-zA-Z0-9\.]+[\.][a-zA-Z0-9]+$");

string urlFromUserInput(string userURL) {
    if (exists(userURL)) {
        return "file://" ~ userURL;
    } else if (matchAll(userURL, noProtocol)) {
        return "https://" ~ userURL;
    } else {
        return userURL;
    }
}
