# Mantissa

![forthebadge](https://forthebadge.com/images/badges/contains-cat-gifs.svg)

A Qt based browser made with love.

## Dependencies:
### Debian & Ubuntu
On Debian and Ubuntu, mantissa depends on the following packages:

`sudo apt install build-essential cmake qtbase5-dev qt5-default qtwebengine5-dev`

#### Void Linux
Install the following:

`sudo xbps-install -S gcc make cmake qt5-webengine-devel qt5-webchannel-devel qt5-declarative-devel qt5-location-devel`

#### FreeBSD
Install the following:

`pkg install cmake qt5-buildtools qt5-webengine`

## Build instructions.
Inside the cloned git repository for a release build:

```bash
mkdir build && cd build              # Make build dir.
cmake -DCMAKE_BUILD_TYPE=Release ../ # Configure,
make -jN                             # Number of threads wanted to use.
sudo make install/strip              # Install the stripped version.
```

To install the desktop entries on a POSIX system:

```bash
sudo ./install-desktop-entry.sh
```

Such a solution for a windows or another non POSIX systems does not exist yet.