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

install -d "${DESDIR}${PREFIX}/bin"
install -d "${DESDIR}${PREFIX}/share/applications"
install -d "${DESDIR}${PREFIX}/share/icons"

install mantissa "${DESDIR}${PREFIX}/bin"
install -m 644 resources/entry.desktop "${DESDIR}${PREFIX}/share/applications/org.streaksu.mantissa.desktop"
install -m 644 resources/icon.png      "${DESDIR}${PREFIX}/share/icons/mantissa.icon"
