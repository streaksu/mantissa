# Mantissa

![forthebadge](https://forthebadge.com/images/badges/contains-cat-gifs.svg)

A GTK based browser written in D and made with love.

## Manifesto

Mantissa aims to be a simple, fast browser featuring simplicity in the
code, UI, and functionality, while remaining powerful, adaptable to all
kinds of environments, from POSIX to Windows, and secure, by having
features like javascript switches and HTTPS enforcing integrated on the
browser.

## Building and dependencies

The dependencies of the project are:

- `gtk3`.
- `gtkd`.
- `webkit2gtk`.
- Optional: Codecs for video like `gst-libav` for youtube.

Aditionally, for building one will need a D compiler, like `ldc` or `dmd`, and
`meson`.

One can install them in an OS like void linux with:

```bash
sudo xbps-install -S gtk3-devel gtkd-devel webkit2gtk-devel dmd meson
```

The project uses meson as build system, instructions on how to build meson
projects can be found in [here](https://mesonbuild.com/Running-Meson.html).

A quick sumary would be:

```bash
meson build --buildtype=release
cd build
ninja
sudo ninja install
```
