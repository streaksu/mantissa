module frontend.history;

import std.array:  appender;
import std.stdio:  File;
import std.string: chop;
import glib.Util:  Util;
import globals:    programNameRaw;

private File* historyFile;

private void openHistory() {
    auto userdata  = Util.getUserDataDir();
    auto storepath = Util.buildFilename([userdata, programNameRaw]);
    auto store     = Util.buildFilename([storepath, "history.txt"]);
    historyFile    = new File(store, "ab+");
}

/// Get history of the browser.
string[] getHistory() {
    if (historyFile == null) {
        openHistory();
    }

    auto result = appender!(string[]);
    char[] buffer;
    while (historyFile.readln(buffer)) {
        result.put(buffer[0..buffer.length - 1].idup); // @suppress(dscanner.suspicious.length_subtraction)
    }
    historyFile.rewind();
    return result.data;
}

/// Add a string to the browser's history.
void addToHistory(string uri) {
    if (historyFile == null) {
        openHistory();
    }

    char[] buffer;
    while (historyFile.readln(buffer)) {
        if (uri == chop(buffer)) {
            return;
        }
    }
    historyFile.writeln(uri);
    historyFile.rewind();
}
