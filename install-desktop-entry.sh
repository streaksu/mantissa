#!/bin/sh

set -e
set -x

# Defaults
PREFIX="/usr/local"

install -d "${PREFIX}/share/applications"
cat << EOF >"${PREFIX}/share/applications/mantissa.desktop"
[Desktop Entry]
Name=Mantissa
Comment=A minimalistic, simple Qt based browser.
GenericName=Web Browser
Exec=$PREFIX/bin/mantissa
Icon=$PREFIX/share/icons/mantissa.icon
Terminal=false
Type=Application
Categories=Network;WebBrowser;
EOF
chmod 644 "${PREFIX}/share/applications/mantissa.desktop"

install -d "${PREFIX}/share/icons"
install -m 644 resources/logo.png "${PREFIX}/share/icons/mantissa.icon"
