project('mantissa', 'd', version: '0.0.1', license: 'BSL-1.0')

# Locations.
prefix = get_option('prefix')
datadir = join_paths(prefix, get_option('datadir'))
icon_install = join_paths(datadir, 'icons')
desktop_install = join_paths(datadir, 'applications')
schema_install = join_paths(datadir, 'glib-2.0/schemas')

# Dependencies.
gtkd = dependency('gtkd-3')
webkit = dependency('webkit2gtk-4.0')

# Source files to compile and include directories.
include = include_directories('source')
source = [
    'source/backend/webview.d',
    'source/backend/webviewsettings.d',
    'source/frontend/browser.d',
    'source/frontend/preferences.d',
    'source/main.d',
    'source/settings.d'
]

# Executable.
e = executable(
    meson.project_name(),
    source,
    include_directories: include,
    dependencies: [gtkd, webkit],
    install: true
)

# Auxiliary files and their installation (logo, desktop, etc).
icon = 'resources/logo.png'
desktop = 'resources/mantissa.desktop'
schema = 'resources/schema.xml'

install_data(sources: icon, install_dir: icon_install)
install_data(sources: desktop, install_dir: desktop_install)
install_data(sources: schema, rename: 'org.streaksu.Mantissa.gschema.xml', install_dir: schema_install)

meson.add_install_script('postinstall.py')
