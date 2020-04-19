module frontend.about;

import gtk.AboutDialog;
import globals;

class About : AboutDialog {
    this() {
        // Work with the logo and program info.
        setLogoIconName(iconName);
        setProgramName(programName);
        setVersion(programVersion);
        setComments(programDescription);
        setCopyright(programCopyright);
        setWebsite(programWebsite);

        // Authors, artists, license, etc.
        setAuthors(cast(string[])programAuthors);
        setArtists(cast(string[])programArtists);
        setLicense(
            "Distributed under the " ~ programLicense ~ " license.\n" ~
            "If a copy didn't come with your copy of the software you can\n" ~
            "grab one in " ~ programLicenseLink
        );

        // Add the thanks section in the credits.
        addCreditSection("Thanks to", [
            "The D Foundation https://dlang.org for such a great language",
            "The GtkD team https://gtkd.org for the useful framework"
        ]);

        // Show all.
        showAll();
    }
}
