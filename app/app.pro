TEMPLATE = app
TARGET = videoplayer
QT = quick multimedia

SOURCES = main.cpp

RESOURCES += \
    videoplayer.qrc \
    images/images.qrc

target.path = /usr/bin
target.files += $${OUT_PWD}/$${TARGET}
target.CONFIG = no_check_exist executable

INSTALLS += target
