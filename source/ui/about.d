/// Functions and utilities for the About dialog.
/// Supposed to display information about the application
/// in a user-readable UI item.
module ui.about;

import gtk.AboutDialog: AboutDialog;

/// About window of the application, meant to show credits, website of the
/// project, all that stuff.
final class About : AboutDialog {
    /// Creates a filled about window.
    this() {
        import globals:         programIcon, programName, programVersion;
        import ui.translations: _, translator;

        setLogoIconName(programIcon);
        setProgramName(_(programName));
        setVersion(programVersion);
        setComments(_("A lightweight web browser made with GTK, D and love"));
        setCopyright(_("Copyright © 2020 Streaksu"));
        setWebsite("https://github.com/streaksu/mantissa");
        setAuthors(["Streaksu https://github.com/streaksu"]);
        setArtists(["Mintsuki https://github.com/mintsuki"]);
        setTranslatorCredits(translator);

        addCreditSection(_("Thanks to"), [
            _("The D Foundation https://dlang.org for such a great language"),
            _("The GtkD team https://gtkd.org for the useful framework"),
            _("The d2sqlite3 team https://github.com/dlang-community/d2sqlite3 for the superb library")
        ]);

        showAll();
    }
}
