/// Globals deemed important all around, and used several places.
/// If any of this is to be displayed to the user in the UI, it must be
/// translated, like any other string.
module config;

/// ID of the program for GTK.
immutable programID = "org.streaksu.mantissa";

/// Raw name of the program's data dir.
immutable programDir = "mantissa";

/// Name of the program icon.
immutable programIcon = "mantissa";

/// Name of the application the user will see on display.
immutable programName = "mantissa";

/// Version of the application.
immutable programVersion = "1.4.0";

/// Website of the application for bug report.
immutable programSite = "https://github.com/streaksu/mantissa/issues";
