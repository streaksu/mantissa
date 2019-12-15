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

# Configure header and desktop entry.
configure_file(
    ${PROJECT_SOURCE_DIR}/source/globals.h.in
    ${CMAKE_CURRENT_BINARY_DIR}/globals.h
)

# Executable and link targets.
include_directories(${PROJECT_SOURCE_DIR}/source)

add_executable(mantissa
    source/backend/webview.cpp
    source/backend/webview.h
    source/frontend/about.cpp
    source/frontend/about.h
    source/frontend/about.ui
    source/frontend/mainwindow.cpp
    source/frontend/mainwindow.h
    source/frontend/mainwindow.ui
    source/frontend/settings.cpp
    source/frontend/settings.h
    source/frontend/settings.ui
    source/globals.h.in
    source/main.cpp

    resources/resources.qrc
)

target_link_libraries(
    mantissa
    PRIVATE
    Qt5::Widgets
    Qt5::WebEngine
    Qt5::WebEngineWidgets
)

install(TARGETS mantissa)
