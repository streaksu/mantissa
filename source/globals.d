/**
 * Globals deemed important all around the application, and used several places.
 * If any of this is to be displayed to the user in the UI, it must be
 * translated, like any other string.
 */
module globals;

immutable programID      = "org.streaksu.mantissa"; /// ID of the program for GTK.
immutable programDir     = "mantissa"; /// Raw name of the program's data dir.
immutable programIcon    = "mantissa"; /// Name of the program icon.
immutable programName    = "Mantissa"; /// Name of the application the user will see on display.
immutable programVersion = "1.3.0";    /// Version of the application. // @suppress(dscanner.style.undocumented_declaration)
