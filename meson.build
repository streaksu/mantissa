project('mantissa', 'd', version: '0.0.1', license: 'BSL-1.0')

gtkd = dependency('gtkd-3')
webkit = dependency('webkit2gtk-4.0')

source = files(
    'source/backend/webview.d',
    'source/backend/webviewsettings.d',
    'source/frontend/browser.d',
    'source/frontend/preferences.d',
    'source/main.d'
)

include = include_directories('source')

e = executable(
    meson.project_name(),
    source,
    include_directories: include,
    dependencies: [gtkd, webkit],
    install: true
)

install_data(
    sources: 'resources/logo.png',
    rename: 'mantissa.icon',
    install_dir : '/usr/local/share/icons'
)

install_data(
    sources: 'resources/mantissa.desktop',
    rename: 'mantissa.desktop',
    install_dir : '/usr/local/share/applications'
)

install_data(
    sources: 'resources/schema.xml',
    rename: 'org.streaksu.Mantissa.gschema.xml',
    install_dir: '/usr/local/share/glib-2.0/schemas'
)

meson.add_install_script('resources/install.sh')
