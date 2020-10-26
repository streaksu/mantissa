module about;

import gtk.AboutDialog: AboutDialog;
import globals; // Everything really.

/**
 * About window of the application, meant to show credits, website of the
 * project, all that stuff.
 */
final class About : AboutDialog {
    /// Creates a filled about window.
    this() {
        setLogoIconName(programNameRaw);
        setProgramName(programName);
        setVersion(programVersion);
        setComments(programDescription);
        setCopyright(programCopyright);
        setWebsite(programWebsite);
        setAuthors(programAuthors.dup);
        setArtists(programArtists.dup);

        setLicense(
            "Distributed under the " ~ programLicense ~ " license.\n" ~
            "If a copy didn't come with your copy of the software you can\n" ~
            "grab one at " ~ programLicenseLink
        );

        addCreditSection("Thanks to", [
            "The D Foundation https://dlang.org for such a great language",
            "The GtkD team https://gtkd.org for the useful framework",
            "The d2sqlite3 team https://github.com/dlang-community/d2sqlite3 for the superb library"
        ]);

        showAll();
    }
}
