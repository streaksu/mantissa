module frontend.settingsmenu;

import gtk.MenuButton;
import gtk.PopoverMenu;
import gtk.VBox;
import gtk.Label;
import gtk.ModelButton;
import gtk.Separator;
import globals;

private ModelButton createModelButton(string name) {
    auto button = new ModelButton();
    button.setLabel(name);
    button.setAlignment(0.0, 1.0);
    return button;
}

class SettingsMenu : MenuButton {
    Label name;
    Label license;
    ModelButton history;
    ModelButton preferences;
    
    this() {
        // Initialize ourselves first.
        super();
        this.setRelief(GtkReliefStyle.NONE);

        // Initialize the popup items.
        this.name = new Label(PROJECTNAME ~ " - " ~ PROJECTVERSION);
        this.license = new Label("Distributed under the " ~ PROJECTLICENSE);
        this.history = createModelButton("History");
        this.preferences = createModelButton("Preferences");

        // Initialise the stack that will hold the items and pack them.
        auto contents = new VBox(true, 0);
        contents.add(this.name);
        contents.add(this.license);
        contents.add(new Separator(GtkOrientation.HORIZONTAL));
        contents.add(this.history);
        contents.add(this.preferences);
        contents.showAll();

        // Create the popup and assign the contents.
        auto popup = new PopoverMenu();
        popup.add(contents);
        this.setPopover(popup);
    }
}
