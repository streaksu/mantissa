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

/**
 * Static class that wraps the user settings.
 */
struct UserSettings {
    /// Does the user want smooth scrolling of windows?
    @property static bool smoothScrolling() {
        auto items = database.execute(
            "SELECT * FROM usersettings WHERE setting == 'smooth_scrolling'"
        );
        if (!items.empty) {
            return items.front()["enabled"].as!bool;
        }

        return true;
    }

    /// Save smooth scrolling settings.
    @property static void smoothScrolling(bool b) {
        auto statement = database.prepare(
            "REPLACE INTO usersettings (setting, enabled, extra)
            VALUES (:settings, :enabled, :extra)"
        );
        statement.inject("smooth_scrolling", b, "Placeholder");
    }

    /// Does the user want to cache pages?
    @property static bool pageCache() {
        auto items = database.execute(
            "SELECT * FROM usersettings WHERE setting == 'pagecache'"
        );
        if (!items.empty) {
            return items.front()["enabled"].as!bool;
        }

        return true;
    }

    /// Save page caching settings.
    @property static void pageCache(bool b) {
        auto statement = database.prepare(
            "REPLACE INTO usersettings (setting, enabled, extra)
            VALUES (:settings, :enabled, :extra)"
        );
        statement.inject("pagecache", b, "Placeholder");
    }

    /// Does the user want to enable javascript support?
    @property static bool javascript() {
        auto items = database.execute(
            "SELECT * FROM usersettings WHERE setting == 'javascript'"
        );
        if (!items.empty) {
            return items.front()["enabled"].as!bool;
        }

        return false;
    }

    /// Save javascript settings.
    @property static void javascript(bool b) {
        auto statement = database.prepare(
            "REPLACE INTO usersettings (setting, enabled, extra)
            VALUES (:settings, :enabled, :extra)"
        );
        statement.inject("javascript", b, "Placeholder");
    }

    /// Does the user want to enable engine site quirks?
    @property static bool sitequirks() {
        auto items = database.execute(
            "SELECT * FROM usersettings WHERE setting == 'sitequirks'"
        );
        if (!items.empty) {
            return items.front()["enabled"].as!bool;
        }

        return true;
    }

    /// Save site quirks.
    @property static void sitequirks(bool b) {
        auto statement = database.prepare(
            "REPLACE INTO usersettings (setting, enabled, extra)
            VALUES (:settings, :enabled, :extra)"
        );
        statement.inject("sitequirks", b, "Placeholder");
    }

    /// Which homepage did the user set to use?
    @property static string homepage() {
        auto items = database.execute(
            "SELECT * FROM usersettings WHERE setting == 'homepage'"
        );
        if (!items.empty) {
            return items.front()["extra"].as!string;
        }

        return "https://dlang.org";
    }

    /// Save the desired homepage.
    @property static void homepage(string d) {
        auto statement = database.prepare(
            "REPLACE INTO usersettings (setting, enabled, extra)
            VALUES (:settings, :enabled, :extra)"
        );
        statement.inject("homepage", false, d);
    }

    /// Which cookie policy did the user want? (values documented in the .xml)
    @property static int cookiePolicy() {
        auto items = database.execute(
            "SELECT * FROM usersettings WHERE setting == 'cookiepolicy'"
        );
        if (!items.empty) {
            return to!int(items.front()["extra"].as!string);
        }

        return 2;
    }

    /// Save the desired cookie policy.
    @property static void cookiePolicy(int a) {
        auto statement = database.prepare(
            "REPLACE INTO usersettings (setting, enabled, extra)
            VALUES (:settings, :enabled, :extra)"
        );
        statement.inject("cookiepolicy", false, to!string(a));
    }

    /// Which search engine did the user want?
    @property static string searchEngine() {
        auto items = database.execute(
            "SELECT * FROM usersettings WHERE setting == 'searchengine'"
        );
        if (!items.empty) {
            return items.front()["extra"].as!string;
        }

        return "https://duckduckgo.com/search?q=";
    }

    /// Save the desired search engine.
    @property static void searchEngine(string d) {
        auto statement = database.prepare(
            "REPLACE INTO usersettings (setting, enabled, extra)
            VALUES (:settings, :enabled, :extra)"
        );
        statement.inject("searchengine", false, d);
    }

    /// Does the user want to keep cookies?
    @property static bool cookieKeep() {
        auto items = database.execute(
            "SELECT * FROM usersettings WHERE setting == 'cookiekeep'"
        );
        if (!items.empty) {
            return items.front()["enabled"].as!bool;
        }

        return true;
    }

    /// Save cookie saving policy.
    @property static void cookieKeep(bool b) {
        auto statement = database.prepare(
            "REPLACE INTO usersettings (setting, enabled, extra)
            VALUES (:settings, :enabled, :extra)"
        );
        statement.inject("cookiekeep", b, "Placeholder");
    }

    /// Does the user want to force HTTPs?
    @property static bool forceHTTPS() {
        auto items = database.execute(
            "SELECT * FROM usersettings WHERE setting == 'forcehttps'"
        );
        if (!items.empty) {
            return items.front()["enabled"].as!bool;
        }

        return true;
    }

    /// Save HTTPs enforcing policy.
    @property static void forceHTTPS(bool b) {
        auto statement = database.prepare(
            "REPLACE INTO usersettings (setting, enabled, extra)
            VALUES (:settings, :enabled, :extra)"
        );
        statement.inject("forcehttps", b, "Placeholder");
    }

    /// Does the user want to allow insecure content on HTTPs sites?
    @property static bool insecureContent() {
        auto items = database.execute(
            "SELECT * FROM usersettings WHERE setting == 'insecurecontent'"
        );
        if (!items.empty) {
            return items.front()["enabled"].as!bool;
        }

        return true;
    }

    /// Save insecure content policy.
    @property static void insecureContent(bool b) {
        auto statement = database.prepare(
            "REPLACE INTO usersettings (setting, enabled, extra)
            VALUES (:settings, :enabled, :extra)"
        );
        statement.inject("insecurecontent", b, "Placeholder");
    }
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
}
