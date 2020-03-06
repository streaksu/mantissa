project('mantissa', 'd', version: '0.0.1', license: 'BSL-1.0')

conf = configuration_data()
conf.set('NAME',    meson.project_name())
conf.set('VERSION', meson.project_version())
conf.set('LICENSE', meson.project_license()[0])

configure_file(
    input: 'source/globals.d.in',
    output: 'globals.d',
    configuration: conf
)

gtkd = dependency('gtkd-3')
webkit = dependency('webkit2gtk-4.0')

source = files(
    'source/backend/webview.d',
    'source/frontend/browser.d',
    'source/frontend/icons.d',
    'source/frontend/settingsmenu.d',
    meson.current_build_dir() + '/globals.d',
    'source/main.d'
)

e = executable(
    meson.project_name(),
    source,
    include_directories: include_directories('source'),
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
