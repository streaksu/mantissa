module storage;

import std.conv:             to;
import std.array:            appender;
import std.file:             exists;
import std.datetime.systime: Clock, SysTime;
import glib.Util:            Util;
import d2sqlite3:            Database, Statement, ResultRange, Row;
import globals:              programNameRaw;

// Database that holds all the settings and data.
private Database db;

shared static this() {
    auto userdata  = Util.getUserDataDir();
    auto storepath = Util.buildFilename([userdata, programNameRaw]);
    auto store     = Util.buildFilename([storepath, "globaldata.sqlite"]);
    db             = Database(store);

    db.run(
        "CREATE TABLE IF NOT EXISTS usersettings (
            setting TEXT NOT NULL UNIQUE,
            enabled INTEGER NOT NULL,
            extra   TEXT NOT NULL
        )"
    );

    db.run(
        "CREATE TABLE IF NOT EXISTS history (
            title    TEXT NOT NULL,
            uri      TEXT NOT NULL UNIQUE,
            bookmark INTEGER NOT NULL,
            time     TEXT NOT NULL
        )"
    );
}

shared static ~this() {
    db.close();
}

/**
 * Static class that wraps the user settings.
 */
struct UserSettings {
    /// Does the user want smooth scrolling of windows?
    @property static bool smoothScrolling() {
        auto items = db.execute(
            "SELECT * FROM usersettings WHERE setting == 'smooth_scrolling'"
        );
        if (!items.empty) {
            return items.front()["enabled"].as!bool;
        }

        return true;
    }

    /// Save smooth scrolling settings.
    @property static void smoothScrolling(bool b) {
        db.run(
            "REPLACE INTO usersettings (setting, enabled, extra)
            VALUES ('smooth_scrolling', " ~ (b ? "1" : "0") ~ ", 'Placeholder')"
        );
    }

    /// Does the user want to cache pages?
    @property static bool pageCache() {
        auto items = db.execute(
            "SELECT * FROM usersettings WHERE setting == 'pagecache'"
        );
        if (!items.empty) {
            return items.front()["enabled"].as!bool;
        }

        return true;
    }

    /// Save page caching settings.
    @property static void pageCache(bool b) {
        db.run(
            "REPLACE INTO usersettings (setting, enabled, extra)
            VALUES ('pagecache', " ~ (b ? "1" : "0") ~ ", 'Placeholder')"
        );
    }

    /// Does the user want to enable javascript support?
    @property static bool javascript() {
        auto items = db.execute(
            "SELECT * FROM usersettings WHERE setting == 'javascript'"
        );
        if (!items.empty) {
            return items.front()["enabled"].as!bool;
        }

        return false;
    }

    /// Save javascript settings.
    @property static void javascript(bool b) {
        db.run(
            "REPLACE INTO usersettings (setting, enabled, extra)
            VALUES ('javascript', " ~ (b ? "1" : "0") ~ ", 'Placeholder')"
        );
    }

    /// Does the user want to enable engine site quirks?
    @property static bool sitequirks() {
        auto items = db.execute(
            "SELECT * FROM usersettings WHERE setting == 'sitequirks'"
        );
        if (!items.empty) {
            return items.front()["enabled"].as!bool;
        }

        return true;
    }

    /// Save site quirks.
    @property static void sitequirks(bool b) {
        db.run(
            "REPLACE INTO usersettings (setting, enabled, extra)
            VALUES ('sitequirks', " ~ (b ? "1" : "0") ~ ", 'Placeholder')"
        );
    }

    /// Which homepage did the user set to use?
    @property static string homepage() {
        auto items = db.execute(
            "SELECT * FROM usersettings WHERE setting == 'homepage'"
        );
        if (!items.empty) {
            return items.front()["extra"].as!string;
        }

        return "https://dlang.org";
    }

    /// Save the desired homepage.
    @property static void homepage(string d) {
        db.run(
            "REPLACE INTO usersettings (setting, enabled, extra)
            VALUES ('homepage', 0, '" ~ d ~ "')"
        );
    }

    /// Which cookie policy did the user want? (values documented in the .xml)
    @property static int cookiePolicy() {
        auto items = db.execute(
            "SELECT * FROM usersettings WHERE setting == 'cookiepolicy'"
        );
        if (!items.empty) {
            return to!int(items.front()["extra"].as!string);
        }

        return 2;
    }

    /// Save the desired cookie policy.
    @property static void cookiePolicy(int a) {
        db.run(
            "REPLACE INTO usersettings (setting, enabled, extra)
            VALUES ('cookiepolicy', 0, '" ~ to!string(a) ~ "')"
        );
    }

    /// Which search engine did the user want?
    @property static string searchEngine() {
        auto items = db.execute(
            "SELECT * FROM usersettings WHERE setting == 'searchengine'"
        );
        if (!items.empty) {
            return items.front()["extra"].as!string;
        }

        return "https://duckduckgo.com/search?q=";
    }

    /// Save the desired search engine.
    @property static void searchEngine(string d) {
        db.run(
            "REPLACE INTO usersettings (setting, enabled, extra)
            VALUES ('searchengine', 0, '" ~ d ~ "')"
        );
    }

    /// Does the user want to keep cookies?
    @property static bool cookieKeep() {
        auto items = db.execute(
            "SELECT * FROM usersettings WHERE setting == 'cookiekeep'"
        );
        if (!items.empty) {
            return items.front()["enabled"].as!bool;
        }

        return true;
    }

    /// Save cookie saving policy.
    @property static void cookieKeep(bool b) {
        db.run(
            "REPLACE INTO usersettings (setting, enabled, extra)
            VALUES ('cookiekeep', " ~ (b ? "1" : "0") ~ ", 'Placeholder')"
        );
    }

    /// Does the user want to force HTTPs?
    @property static bool forceHTTPS() {
        auto items = db.execute(
            "SELECT * FROM usersettings WHERE setting == 'forcehttps'"
        );
        if (!items.empty) {
            return items.front()["enabled"].as!bool;
        }

        return true;
    }

    /// Save HTTPs enforcing policy.
    @property static void forceHTTPS(bool b) {
        db.run(
            "REPLACE INTO usersettings (setting, enabled, extra)
            VALUES ('forcehttps', " ~ (b ? "1" : "0") ~ ", 'Placeholder')"
        );
    }

    /// Does the user want to allow insecure content on HTTPs sites?
    @property static bool insecureContent() {
        auto items = db.execute(
            "SELECT * FROM usersettings WHERE setting == 'insecurecontent'"
        );
        if (!items.empty) {
            return items.front()["enabled"].as!bool;
        }

        return true;
    }

    /// Save insecure content policy.
    @property static void insecureContent(bool b) {
        db.run(
            "REPLACE INTO usersettings (setting, enabled, extra)
            VALUES ('insecurecontent', " ~ (b ? "1" : "0") ~ ", 'Placeholder')"
        );
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
        auto items  = db.execute("SELECT * FROM history");

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
    @property static void updateOrAdd(string title, string uri) {
        updateOrAdd(HistoryURI(title, uri, false, Clock.currTime));
    }

    /**
     * Update the contents of a given history element.
     * If not present, the element will be added.
     */
    @property static void updateOrAdd(HistoryURI item) {
        // TODO: Actually update.

        // Check if there is a single item with the same URI and update.
        // If not, add.
        const auto count = db.execute(
            "SELECT count(*) FROM history WHERE uri == '" ~ item.uri ~ "'"
        ).oneValue!long;
        if (count == 0) {
            auto statement = db.prepare(
                "INSERT INTO history (title, uri, bookmark, time)
                VALUES (:title, :uri, :bookmark, :time)"
            );

            statement.inject(item.title, item.uri, item.isBookmark,
                item.time.toSimpleString());
        }
    }
}
