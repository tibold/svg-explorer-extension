#-------------------------------------------------
#
# Project created by QtCreator 2012-03-18T17:01:34
#
#-------------------------------------------------

QT       += svg
QT       += winextras

TARGET = SvgSee
TEMPLATE = lib
CONFIG += c++1z

CONFIG(release, debug|release):DEFINES += NDEBUG

win32:LIBS += \
    shlwapi.lib \
    advapi32.lib

DEFINES += SVGTHUMBNAILEXTENSION_LIBRARY

SOURCES += \
    Registry.cpp \
    ThumbnailProvider.cpp \
    Main.cpp \
    ClassFactory.cpp

HEADERS +=\
    Logging.h \
    Registry.h \
    ThumbnailProvider.h \
    ClassFactory.h \
    Common.h

DEF_FILE += \
    ThumbnailProvider.def

OTHER_FILES += \
    ThumbnailProvider.def
