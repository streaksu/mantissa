module frontend.about;

import gtk.AboutDialog;
import globals;

class About : AboutDialog {
    this() {
        // Work with the logo and program info.
        this.setLogoIconName(ICON_NAME);
        this.setProgramName(PROGRAM_NAME);
        this.setVersion(PROGRAM_VERSION);
        this.setComments(PROGRAM_DESCRIPTION);
        this.setCopyright(PROGRAM_COPYRIGHT);
        this.setWebsite(PROGRAM_WEBSITE);

        // Authors, artists, license, etc.
        this.setAuthors(cast(string[])PROGRAM_AUTHORS);
        this.setArtists(cast(string[])PROGRAM_ARTISTS);
        this.setLicense(
            "Distributed under the " ~ PROGRAM_LICENSE ~ " license.\n" ~
            "If a copy didn't come with your copy of the software you can\n" ~
            "grab one in " ~ PROGRAM_LICENSE_LINK
        );

        // Add the thanks section in the credits.
        this.addCreditSection("Thanks to", [
            "The D Foundation https://dlang.org for such a great language",
            "The GtkD team https://gtkd.org for the useful framework"
        ]);

        // Show all.
        this.showAll();
    }
}
