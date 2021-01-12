/// Utilities for reading and modifying the global history.
module storage.history;

import std.conv:             to;
import std.array:            appender;
import std.file:             exists, mkdirRecurse;
import std.datetime.systime: Clock, SysTime;
import glib.Util:            Util;
import d2sqlite3:            Database, Statement, ResultRange, Row;

private Database database;

shared static this() {
    import storage.configdir: openDatabaseFromConfig;
    database = openDatabaseFromConfig("history.sqlite");
    database.run(
        "CREATE TABLE IF NOT EXISTS history (
            uri      TEXT NOT NULL UNIQUE,
            title    TEXT NOT NULL,
            bookmark INTEGER NOT NULL,
            time     TEXT NOT NULL
        )"
    );
}

shared static ~this() {
    database.close();
}

/// Retrieves the stored history of the browser. The returned array is not
/// ensured to be sorted by any scheme. The contents will change on the course
/// of the application as modifications to the history are done.
/// Returns: Memory allocated history array.
auto getHistory() {
    struct HistoryURI {
        string  uri;
        string  title;
        bool    isBookmark;
        SysTime time;
    }

    auto result = appender!(HistoryURI[]);
    auto items  = database.execute("SELECT * FROM history");

    foreach (Row row; items) {
        const auto uri      = row["uri"].as!string;
        const auto title    = row["title"].as!string;
        const auto bookmark = row["bookmark"].as!bool;
        const auto time     = SysTime.fromSimpleString(row["time"].as!string);
        result.put(HistoryURI(uri, title, bookmark, time));
    }

    return result.data;
}

/// Adds or updates a URI and its field on the history.
/// Params:
///     uri        = URI to add to the history.
///     title      = Title exposed by the website pointed to by the URI.
///     isBookmark = `true` if the user marked the URI as a bookmark.
///     time       = Time of last access, by default `Clock.currTime`.
void addToHistory(string uri, string title, bool isBookmark, SysTime time = Clock.currTime) {
    auto stmt = database.prepare(
        "REPLACE INTO history (uri, title, bookmark, time)
        VALUES (:uri, :title, :bookmark, :time)"
    );
    stmt.inject(uri, title, isBookmark, time.toSimpleString());
    stmt.finalize();
}

/// Removes an individual item addressed by URI from the history, or does
/// nothing if it is not registered.
/// Params:
///     uri = URI used to address the data to be deleted.
void removeFromHistory(string uri) {
    auto stmt = database.prepare(
        "DELETE FROM history (uri, title, bookmark, time)
        WHERE uri = :uri"
    );
    stmt.inject(uri);
    stmt.finalize();
}

/// Removes an interval of URIs accessed in the passed time interval. This
/// deletion is done going forwards in time.
/// Params:
///     start = Start of the interval.
///     end   = End of the interval.
void removeIntervalFromHistory(SysTime start, SysTime end) {
    assert(start.toUnixTime() <= end.toUnixTime());

    const auto unixS = start.toUnixTime();
    const auto unixE = end.toUnixTime();

    auto result = appender!(ulong[]);
    auto items  = database.execute("SELECT rowid, * FROM history");

    foreach (Row row; items) {
        const auto rowid = row["rowid"].as!ulong;
        const auto time  = SysTime.fromSimpleString(row["time"].as!string);
        const auto unixt = time.toUnixTime();
        if (unixt >= unixS && unixt <= unixE) {
            result.put(rowid);
        }
    }

    const auto data = result.data;
    auto stmt = database.prepare("DELETE FROM history WHERE rowid = :rowid");
    foreach (item; data) {
        stmt.inject(item);
    }
    stmt.finalize();
}

/// Remove all history, ever, enough said.
void removeAllHistory() {
    database.execute("DELETE FROM history");
}
