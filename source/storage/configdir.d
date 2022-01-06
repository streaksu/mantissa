/// Opening, closing and modifingfiles in the config dir.
module storage.configdir;

import d2sqlite3: Database;
import glib.Util: Util;
import std.file:  exists, mkdirRecurse, write;

private shared string configPath;

shared static this() {
    import config: programDir;

    auto path = Util.buildFilename([Util.getUserDataDir(), programDir]);
    if (!exists(path)) {
        mkdirRecurse(path);
    }
    configPath = path;
}

/// Finds the path of a file in the configuration directory of the user.
/// Params:
///     path   = Name of the file to find.
///     create = Create the file or just build the path.
/// Returns: Path of the found file in the FS.
string findConfigFile(string path, bool create = false) {
    assert(path != null);
    auto store = Util.buildFilename([configPath, path]);
    if (create && !exists(store)) {
        write(store, "");
    }
    return store;
}

/// Open a database from the config directory of the user.
/// Params:
///     path = Name of the database to open, not null.
/// Returns: Database that was opened.
Database openDatabaseFromConfig(string path) {
    assert(path != null);
    return Database(findConfigFile(path));
}
