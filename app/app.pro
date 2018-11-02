TARGET = videoplayer
QT = quickcontrols2 multimedia

SOURCES = main.cpp

CONFIG += link_pkgconfig
PKGCONFIG += libhomescreen qlibwindowmanager

RESOURCES += \
    videoplayer.qrc \
    images/images.qrc

include(app.pri)

