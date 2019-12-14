# Project setup.
cmake_minimum_required(VERSION 3.5)
project(mantissa LANGUAGES CXX VERSION 0.0.1)
set(CMAKE_PROJECT_LICENSE BSL-1.0)

# Several settings.
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Dependencies.
find_package(Qt5 REQUIRED COMPONENTS Widgets WebEngine WebEngineWidgets)

# Configure header.
configure_file(
    ${PROJECT_SOURCE_DIR}/globals.h.in
    ${CMAKE_CURRENT_BINARY_DIR}/globals.h
)

add_executable(mantissa
    backend/webview.cpp
    backend/webview.h

    frontend/about.cpp
    frontend/about.h
    frontend/about.ui
    frontend/mainwindow.cpp
    frontend/mainwindow.h
    frontend/mainwindow.ui
    frontend/settings.cpp
    frontend/settings.h
    frontend/settings.ui

    resources/resources.qrc

    globals.h.in
    main.cpp
)

target_link_libraries(
    mantissa
    PRIVATE
    Qt5::Widgets
    Qt5::WebEngine
    Qt5::WebEngineWidgets
)

install(TARGETS mantissa)
