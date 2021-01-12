module storage.history;

import std.conv:             to;
import std.array:            appender;
import std.file:             exists, mkdirRecurse;
import std.datetime.systime: Clock, SysTime;
import glib.Util:            Util;
import d2sqlite3:            Database, Statement, ResultRange, Row;
import globals:              programDir;
import storage.configdir:    openDatabaseFromConfig;

/// Struct representing item of the history.
struct HistoryURI {
    string  title;      /// Title of the resource.
    string  uri;        /// URI of the resource.
    bool    isBookmark; /// Whether the resource is bookmarked.
    SysTime time;       /// Time of visit (given by SysTime.toSimpleString).
}

shared HistoryURI[] history; /// History of the browser.

private Database database; // Holds all the settings and data.

shared static this() {
    // Open database and prepare it.
    database = openDatabaseFromConfig("history.sqlite");

    database.run(
        "CREATE TABLE IF NOT EXISTS history (
            title    TEXT NOT NULL,
            uri      TEXT NOT NULL UNIQUE,
            bookmark INTEGER NOT NULL,
            time     TEXT NOT NULL
        )"
    );

    auto result = appender!(HistoryURI[]);
    auto items  = database.execute("SELECT * FROM history");

    foreach (Row row; items) {
        const auto title    = row["title"].as!string;
        const auto uri      = row["uri"].as!string;
        const auto bookmark = row["bookmark"].as!bool;
        const auto time     = SysTime.fromSimpleString(row["time"].as!string);
        result.put(HistoryURI(title, uri, bookmark, time));
    }

    history = cast(shared)result.data;
}

shared static ~this() {
    database.execute("DELETE FROM history");
    auto stmt = database.prepare(
        "REPLACE INTO history (title, uri, bookmark, time)
        VALUES (:title, :uri, :bookmark, :time)"
    );
    foreach (item; history) {
        auto time = (cast()item.time).toSimpleString();
        stmt.inject(item.title, item.uri, item.isBookmark, time);
    }

    // Close database.
    stmt.finalize();
    database.close();
}
