project('mantissa', 'd', version: '1.1.0', license: 'BSL-1.0')

# Locations.
prefix = get_option('prefix')
datadir = join_paths(prefix, get_option('datadir'))
icon_install = join_paths(datadir, 'icons/hicolor/scalable/apps')
desktop_install = join_paths(datadir, 'applications')
schema_install = join_paths(datadir, 'glib-2.0/schemas')

# Dependencies.
gtkd = dependency('gtkd-3', version: '>=3.9.0')
webkit = dependency('webkit2gtk-4.0', version: '>=2.26.1')

# Source files to compile and include directories.
include = include_directories('source')

conf = configuration_data()
conf.set('name', meson.project_name())
conf.set('version', meson.project_version())
conf.set('description', 'A GTK based browser written in D and made with love.')
conf.set('copyright', 'Copyright  © 2020 Streaksu')
conf.set('website', 'https://github.com/streaksu/mantissa')
conf.set('authors', 'Streaksu https://github.com/streaksu')
conf.set('artists', 'Mintsuki https://github.com/mintsuki')
conf.set('license', meson.project_license()[0])
conf.set('license_link', 'https://opensource.org/licenses/BSL-1.0')
conf.set('icon', 'mantissa')
conf.set('gschema', 'org.streaksu.Mantissa')

configure_file(
    input: 'source/globals.d.in',
    output: 'globals.d',
    configuration: conf
)

source = [
    meson.current_build_dir() + '/globals.d',
    'source/backend/url.d',
    'source/backend/webview.d',
    'source/backend/webviewsettings.d',
    'source/frontend/about.d',
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
desktop = 'resources/entry.desktop'
icon = 'resources/icon.png'
schema = 'resources/schema.xml'

install_data(sources: desktop, rename: 'mantissa.desktop', install_dir: desktop_install)
install_data(sources: icon, rename: 'mantissa.png', install_dir: icon_install)
install_data(sources: schema, rename: 'org.streaksu.Mantissa.gschema.xml', install_dir: schema_install)

meson.add_install_script('postinstall.py')
