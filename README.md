# Mantissa

![forthebadge](https://forthebadge.com/images/badges/contains-cat-gifs.svg)

A GTK-based and WebKit-based browser written in D and made with love.

## What is Mantissa?

Mantissa aims to be a simple, memory-efficient browser featuring a simple UI but
with no shortage of features and adaptable to all environments.
It is made to be secure, featuring only HTTPs and Javascript switches built-in.

## Building and dependencies

The dependencies of the project are:

- `meson` and a D compiler for building.
- `cmake` or `pkgconfig` may be used by `meson` to search for dependencies.
- `gtk3` (Development version if available).
- `gtkd` (Development version if available).
- `webkit2gtk` (Development version if available).
- `d2sqlite3` and `sqlite3`.
- Optional: Codecs for video like `gst-libav` for youtube.

This materializes into the following packages:

| System              | Packages                                                                                                  |
| ------------------- | --------------------------------------------------------------------------------------------------------- |
| Ubuntu 20.04        | `build-essential meson ldc pkgconf cmake libgtkd-3-dev libwebkit2gtk-4.0-dev libsvrg2-dev libsqlite3-dev` |
| OpenSUSE Tumbleweed | `meson ldc webkit2gtk3-devel gtkd-devel sqlite3-devel cmake pkgconfig`                                    |
| Fedora 32           | `meson pkgconfig cmake ldc gtkd-devel webkit2gtk3-devel sqlite3-devel`                                    |
| Arch Linux          | `gcc meson ldc webkit2gtk gtkd cmake pkgconfig sqlite3`                                                   |

The project uses meson as build system, generic instructions on how to build
meson projects can be found [here](https://mesonbuild.com/Running-Meson.html).

The recommended procedure to build Mantissa would be:

```bash
dub fetch d2sqlite3
dub build d2sqlite3

meson build --buildtype=release
cd build
ninja
sudo ninja install
```
