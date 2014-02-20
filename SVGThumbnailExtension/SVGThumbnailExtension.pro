#-------------------------------------------------
#
# Project created by QtCreator 2012-03-18T17:01:34
#
#-------------------------------------------------

QT       += svg

TARGET = SVGThumbnailExtension
TEMPLATE = lib

CONFIG(release, debug|release):DEFINES += NDEBUG

win32:LIBS += \
    shlwapi.lib \
    advapi32.lib \
    gdiplus.lib

DEFINES += SVGTHUMBNAILEXTENSION_LIBRARY

SOURCES += \
    ThumbnailProvider.cpp \
    Main.cpp \
    ClassFactory.cpp

HEADERS +=\
    ThumbnailProvider.h \
    ClassFactory.h \
    Common.h

symbian {
    MMP_RULES += EXPORTUNFROZEN
    TARGET.UID3 = 0xE6F54BF5
    TARGET.CAPABILITY = 
    TARGET.EPOCALLOWDLLDATA = 1
    addFiles.sources = SVGThumbnailExtension.dll
    addFiles.path = !:/sys/bin
    DEPLOYMENT += addFiles
}

unix:!symbian {
    maemo5 {
        target.path = /opt/usr/lib
    } else {
        target.path = /usr/lib
    }
    INSTALLS += target
}

DEF_FILE += \
    ThumbnailProvider.def

OTHER_FILES += \
    ThumbnailProvider.def
