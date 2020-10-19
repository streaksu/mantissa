module storage;

import std.conv:             to;
import std.array:            appender;
import std.file:             exists, mkdirRecurse;
import std.datetime.systime: Clock, SysTime;
import glib.Util:            Util;
import d2sqlite3:            Database, Statement, ResultRange, Row;
import globals:              programNameRaw;

// Database that holds all the settings and data.
private Database database;

shared static this() {
    auto userdata  = Util.getUserDataDir();
    auto storepath = Util.buildFilename([userdata, programNameRaw]);
    auto store     = Util.buildFilename([storepath, "globaldata.sqlite"]);
    if (!exists(storepath)) {
        mkdirRecurse(storepath);
    }

    database = Database(store);

    database.run(
        "CREATE TABLE IF NOT EXISTS usersettings (
            setting TEXT NOT NULL UNIQUE,
            enabled INTEGER NOT NULL,
            extra   TEXT NOT NULL
        )"
    );

    database.run(
        "CREATE TABLE IF NOT EXISTS history (
            title    TEXT NOT NULL,
            uri      TEXT NOT NULL UNIQUE,
            bookmark INTEGER NOT NULL,
            time     TEXT NOT NULL
        )"
    );
}

shared static ~this() {
    database.close();
}

// Creates a field for UserSettings with a getter and setter.
private mixin template UserSetting(string setting, T, string defaultValue) {
    static if (is(T == bool)) {
        mixin("static @property bool " ~ setting ~ "() {
            auto items = database.execute(
                \"SELECT * FROM usersettings WHERE setting == '" ~ setting ~ "'\"
            );
            if (!items.empty) {
                return items.front()[\"enabled\"].as!bool;
            }

            return " ~ defaultValue ~ ";
        }");
        mixin("static @property void " ~ setting ~ "(bool value) {
            auto statement = database.prepare(
                \"REPLACE INTO usersettings (setting, enabled, extra)
                VALUES (:settings, :enabled, :extra)\"
            );
            statement.inject(\"" ~ setting ~ "\", value, \"Placeholder\");
        }");
    } else static if (is(T == string)) {
        mixin("static @property string " ~ setting ~ "() {
            auto items = database.execute(
                \"SELECT * FROM usersettings WHERE setting == '" ~ setting ~ "'\"
            );
            if (!items.empty) {
                return items.front()[\"extra\"].as!string;
            }

            return \"" ~ defaultValue ~ "\";
        }");
        mixin("static @property void " ~ setting ~ "(string value) {
            auto statement = database.prepare(
                \"REPLACE INTO usersettings (setting, enabled, extra)
                VALUES (:settings, :enabled, :extra)\"
            );
            statement.inject(\"" ~ setting ~ "\", false, value);
        }");
    } else static if (is(T == int)) {
        mixin("static @property int " ~ setting ~ "() {
            auto items = database.execute(
                \"SELECT * FROM usersettings WHERE setting == '" ~ setting ~ "'\"
            );
            if (!items.empty) {
                return to!int(items.front()[\"extra\"].as!string);
            }

            return " ~ defaultValue ~ ";
        }");
        mixin("static @property void " ~ setting ~ "(int value) {
            auto statement = database.prepare(
                \"REPLACE INTO usersettings (setting, enabled, extra)
                VALUES (:settings, :enabled, :extra)\"
            );
            statement.inject(\"" ~ setting ~ "\", false, to!string(value));
        }");
    } else {
        static assert (0, "Invalid UserSetting type");
    }
}

/**
 * Static class that wraps the user settings.
 */
struct UserSettings {
    mixin UserSetting!("smoothScrolling", bool,   "true");
    mixin UserSetting!("pageCache",       bool,   "true");
    mixin UserSetting!("javascript",      bool,   "true");
    mixin UserSetting!("sitequirks",      bool,   "true");
    mixin UserSetting!("homepage",        string, "https://dlang.org");
    mixin UserSetting!("cookiePolicy",    int,    "2");
    mixin UserSetting!("searchEngine",    string, "https://duckduckgo.com/search?q=");
    mixin UserSetting!("cookieKeep",      bool,   "true");
    mixin UserSetting!("forceHTTPS",      bool,   "true");
    mixin UserSetting!("insecureContent", bool,   "true");
    mixin UserSetting!("useHeaderBar",    bool,   "true");
}

/**
 * Methods to retrieve and manipulate history data.
 */
struct HistoryStore {
    /// Data that represents a URI in the history.
    struct HistoryURI {
        string  title;      /// Title of the resource.
        string  uri;        /// URI of the resource.
        bool    isBookmark; /// Whether the resource is bookmarked.
        SysTime time;       /// Time of visit (given by SysTime.toSimpleString).
    }

    /**
     * Retrieves the history stored by the browser.
     */
    @property static HistoryURI[] history() {
        auto result = appender!(HistoryURI[]);
        auto items  = database.execute("SELECT * FROM history");

        foreach (Row row; items) {
            const auto title    = row["title"].as!string;
            const auto uri      = row["uri"].as!string;
            const auto bookmark = row["bookmark"].as!bool;
            const auto time     = SysTime.fromSimpleString(row["time"].as!string);
            result.put(HistoryURI(title, uri, bookmark, time));
        }

        return result.data;
    }

    /**
     * Update the contents of a given history element.
     * If not present, the element will be added.
     *
     * This call assumes the access time of the resource to be Clock.currTime.
     */
    static void updateOrAdd(string title, string uri) {
        updateOrAdd(HistoryURI(title, uri, false, Clock.currTime));
    }

    /**
     * Update the contents of a given history element.
     * If not present, the element will be added.
     */
    static void updateOrAdd(HistoryURI item) {
        auto statement = database.prepare(
            "REPLACE INTO history (title, uri, bookmark, time)
            VALUES (:title, :uri, :bookmark, :time)"
        );
        auto time = item.time.toSimpleString();
        statement.inject(item.title, item.uri, item.isBookmark, time);
    }

    /**
     * Remove the requested entry.
     */
    static void deleteEntry(HistoryURI item) {
        auto statement = database.prepare(
            "DELETE FROM history
            WHERE uri = :uri"
        );
        statement.inject(item.uri);
    }
}
