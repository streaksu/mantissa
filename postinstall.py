#!/usr/bin/env python3
from os import environ, path
from subprocess import call

if not environ.get('DESTDIR', ''):
    PREFIX = environ.get('MESON_INSTALL_PREFIX', '/usr/local')
    DATA_DIR = path.join(PREFIX, 'share')
    print('Updating icon cache...')
    call(['gtk-update-icon-cache', '-qtf', path.join(DATA_DIR, 'icons/hicolor')])
    print("Updating desktop database...")
    call(["update-desktop-database", path.join(DATA_DIR, 'applications')])
