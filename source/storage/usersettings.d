/// Options for managing general user settings.
module storage.usersettings;

import d2sqlite3: Database;

private Database database;

shared static this() {
    import storage.configdir: openDatabaseFromConfig;
    database = openDatabaseFromConfig("usersettings.sqlite");
    database.run(
        "CREATE TABLE IF NOT EXISTS usersettings (
            setting TEXT NOT NULL UNIQUE,
            value   TEXT NOT NULL
        )"
    );
}

shared static ~this() {
    database.close();
}

private mixin template UserOption(T, string name, T defaultValue) {
    import std.conv: to;
    // Im sorry. There was no way, please, understand.
    mixin(
        T.stringof ~ " get" ~ name ~ "() {" ~
        "auto items = database.execute(\"SELECT * FROM usersettings WHERE setting == '" ~ name ~ "'\");" ~
        "return !items.empty ? items.front()[\"value\"].as!" ~ T.stringof ~ ":" ~
        (is(T == string) ? "\"" ~ to!string(defaultValue) ~ "\"" : to!string(defaultValue)) ~ ";" ~
        "}" ~
        "void set" ~ name ~ "(" ~ T.stringof ~ " value) {" ~
        "auto stmt = database.prepare(" ~
        "\"REPLACE INTO usersettings (setting, value)" ~
        "VALUES (:settings, :value)\"" ~
        ");" ~
        "stmt.inject(\"" ~ name ~ "\", " ~ (is(T == string) ? "value" : "to!string(value)") ~ ");" ~
        "stmt.finalize();" ~
        "}"
    );
}

mixin UserOption!(bool,   "UseSmoothScrolling",   true);
mixin UserOption!(bool,   "UsePageCache",         true);
mixin UserOption!(bool,   "UseJavascript",        true);
mixin UserOption!(bool,   "UseSiteQuirks",        true);
mixin UserOption!(string, "Homepage",             "https://dlang.org");
mixin UserOption!(int,    "IncomingCookiePolicy", 2);
mixin UserOption!(string, "SearchEngineURL",      "https://duckduckgo.com/?q=");
mixin UserOption!(string, "UserAgent",            "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0 Safari/605.1.15"); // @suppress(dscanner.style.long_line)
mixin UserOption!(bool,   "KeepSessionCookies",   true);
mixin UserOption!(bool,   "ForceHTTPS",           true);
mixin UserOption!(bool,   "AllowInsecureContent", false);
mixin UserOption!(bool,   "UseUIHeaderBar",       true);
mixin UserOption!(int,    "MainWindowHeight",     1366);
mixin UserOption!(int,    "MainWindowWidth",      768);
