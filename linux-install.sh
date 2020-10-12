#!/bin/sh

set -e
set -x

# Defaults
if [ -z "$PREFIX" ]; then
    PREFIX="/usr/local"
fi

if [ -z "$DESTDIR" ]; then
    DESTDIR=""
fi

install -d "${DESTDIR}${PREFIX}/bin"
install -d "${DESTDIR}${PREFIX}/share/applications"
install -d "${DESTDIR}${PREFIX}/share/icons"

install mantissa "${DESTDIR}${PREFIX}/bin"
install -m 644 resources/entry.desktop "${DESTDIR}${PREFIX}/share/applications/org.streaksu.mantissa.desktop"
install -m 644 resources/icon.png      "${DESTDIR}${PREFIX}/share/icons/mantissa.png"
