# Mantissa

![forthebadge](https://forthebadge.com/images/badges/contains-cat-gifs.svg)

A GTK+ based browser written in D and made with love.

## Dependencies

Mantissa needs in order to run the following:

- GTK+ 3 and the gtkd library.
- The webkit2gtk library.

In order to build from source, development versions of those packages are
needed, the meson build system and a D compiler.

## Building

The project uses meson as build system, instructions on how to build meson
projects can be found in [here](https://mesonbuild.com/Running-Meson.html).

A flatpak configuration is also available, the commands go as such:
```bash
flatpak install flathub org.gnome.Sdk//3.30
flatpak install flathub org.gnome.Platform//3.30
flatpak-builder --install flatpak-builder flatpak.yaml
```

Then, to run the application one can do `flatpak run com.streaksu.Mantissa`.