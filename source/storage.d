module storage;

import std.conv:             to;
import std.array:            appender;
import std.file:             exists, mkdirRecurse;
import std.datetime.systime: Clock, SysTime;
import glib.Util:            Util;
import d2sqlite3:            Database, Statement, ResultRange, Row;
import globals:              programDir;

/// Struct representing item of the history.
struct HistoryURI {
    string  title;      /// Title of the resource.
    string  uri;        /// URI of the resource.
    bool    isBookmark; /// Whether the resource is bookmarked.
    SysTime time;       /// Time of visit (given by SysTime.toSimpleString).
}

shared bool   smoothScrolling;  /// Whether the user wants smooth scrolling.
shared bool   pageCache;        /// Whether the user wants page caching.
shared bool   useJavaScript;    /// Whether the user wants to enable js.
shared bool   useSiteQuirks;    /// Whether the user enables sitequirks.
shared string homepage;         /// URI of the homepage.
shared int    cookiePolicy;     /// Cookie policy of the browser.
shared string searchEngine;     /// URI of the search engine to use.
shared bool   keepCookies;      /// Whether the user wants to keep cookies.
shared bool   forceHTTPS;       /// Force HTTPs or not.
shared bool   insecureContent;  /// Allow insecure content or not.
shared bool   useHeaderBar;     /// Use the GTK header bar for the UI.
shared int    mainWindowWidth;  /// Expected width of the main window.
shared int    mainWindowHeight; /// Expected height of the main window.

__gshared HistoryURI[] history; /// History of the browser.

private Database database; // Holds all the settings and data.

shared static this() {
    // Open database and prepare it.
    auto storepath = Util.buildFilename([Util.getUserDataDir(), programDir]);
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

    // Fill the properties.
    ResultRange items;
    items = database.execute("SELECT * FROM usersettings WHERE setting == 'smoothScrolling'");
    smoothScrolling = !items.empty ? items.front()["enabled"].as!bool : true;
    items = database.execute("SELECT * FROM usersettings WHERE setting == 'pageCache'");
    pageCache = !items.empty ? items.front()["enabled"].as!bool : true;
    items = database.execute("SELECT * FROM usersettings WHERE setting == 'javascript'");
    useJavaScript = !items.empty ? items.front()["enabled"].as!bool : true;
    items = database.execute("SELECT * FROM usersettings WHERE setting == 'sitequirks'");
    useSiteQuirks = !items.empty ? items.front()["enabled"].as!bool : true;
    items = database.execute("SELECT * FROM usersettings WHERE setting == 'homepage'");
    homepage = !items.empty ? items.front()["extra"].as!string : "https://dlang.org";
    items = database.execute("SELECT * FROM usersettings WHERE setting == 'cookiePolicy'");
    cookiePolicy = !items.empty ? to!int(items.front()["extra"].as!string) : 2;
    items = database.execute("SELECT * FROM usersettings WHERE setting == 'searchEngine'");
    searchEngine = !items.empty ? items.front()["extra"].as!string : "https://duckduckgo.com/search?q=";
    items = database.execute("SELECT * FROM usersettings WHERE setting == 'cookieKeep'");
    keepCookies = !items.empty ? items.front()["enabled"].as!bool : true;
    items = database.execute("SELECT * FROM usersettings WHERE setting == 'forceHTTPS'");
    forceHTTPS = !items.empty ? items.front()["enabled"].as!bool : true;
    items = database.execute("SELECT * FROM usersettings WHERE setting == 'insecureContent'");
    insecureContent = !items.empty ? items.front()["enabled"].as!bool : false;
    items = database.execute("SELECT * FROM usersettings WHERE setting == 'useHeaderBar'");
    useHeaderBar = !items.empty ? items.front()["enabled"].as!bool : true;
    items = database.execute("SELECT * FROM usersettings WHERE setting == 'mainWindowWidth'");
    mainWindowWidth = !items.empty ? to!int(items.front()["extra"].as!string) : 1366;
    items = database.execute("SELECT * FROM usersettings WHERE setting == 'mainWindowHeight'");
    mainWindowHeight = !items.empty ? to!int(items.front()["extra"].as!string) : 768;

    auto result = appender!(HistoryURI[]);
    items = database.execute("SELECT * FROM history");

    foreach (Row row; items) {
        const auto title    = row["title"].as!string;
        const auto uri      = row["uri"].as!string;
        const auto bookmark = row["bookmark"].as!bool;
        const auto time     = SysTime.fromSimpleString(row["time"].as!string);
        result.put(HistoryURI(title, uri, bookmark, time));
    }

    history = result.data;
}

shared static ~this() {
    // Save user settings and history.
    Statement stmt;
    stmt = database.prepare(
        "REPLACE INTO usersettings (setting, enabled, extra)
        VALUES (:settings, :enabled, :extra)"
    );
    stmt.inject("smoothScrolling",  smoothScrolling, "Placeholder");
    stmt.inject("pageCache",        pageCache,       "Placeholder");
    stmt.inject("javascript",       useJavaScript,   "Placeholder");
    stmt.inject("sitequirks",       useSiteQuirks,   "Placeholder");
    stmt.inject("homepage",         false,           homepage);
    stmt.inject("cookiePolicy",     false,           to!string(cookiePolicy));
    stmt.inject("searchEngine",     false,           searchEngine);
    stmt.inject("cookieKeep",       keepCookies,     "Placeholder");
    stmt.inject("forceHTTPS",       forceHTTPS,      "Placeholder");
    stmt.inject("insecureContent",  insecureContent, "Placeholder");
    stmt.inject("useHeaderBar",     useHeaderBar,    "Placeholder");
    stmt.inject("mainWindowWidth",  false,           to!string(mainWindowWidth));
    stmt.inject("mainWindowHeight", false,           to!string(mainWindowHeight));

    database.execute("DELETE FROM history");
    stmt = database.prepare(
        "INSERT INTO history (title, uri, bookmark, time)
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
