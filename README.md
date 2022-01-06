Mantissa aims to be a simple, memory-efficient browser featuring a simple UI but
with no shortage of features and adaptable to all environments.
It is made to be secure, featuring only HTTPs and Javascript switches built-in.

## Building and dependencies

The dependencies of the project are:

- `autoconf` for configuring.
- `dub` and a D compiler for building.
- `gtk3` (Development version if available).
- `webkit2gtk` (Development version if available).
- `sqlite3` (Development version if available).
- Optional: Codecs for video like `gst-libav` for youtube.

This materializes into the following packages:

| System              | Packages                                                                              |
| ------------------- | ------------------------------------------------------------------------------------- |
| Ubuntu 20.04        | `build-essential dub pkgconfig ldc libwebkit2gtk-4.0-dev libsvrg2-dev libsqlite3-dev` |
| OpenSUSE Tumbleweed | `dub ldc gtk3-devel webkit2gtk3-devel sqlite3-devel pkgconfig autoconf`               |
| Fedora 32           | `dub pkgconfig cmake ldc webkit2gtk3-devel sqlite3-devel autoconf`                    |
| Arch Linux          | `gcc dub ldc webkit2gtk pkgconfig sqlite3 autoconf`                                   |

The project uses `dub` as its build system, all wrapped in a makefile, the
recommended procedure to build Mantissa in a linux system would be:

```bash
./configure # Including all the flags and options you might want to use.
make
make install # Might need root permissions.
```
