QT += quick core sql network widgets

SOURCES += \
        main.cpp \
        projectmanager.cpp \
        settingsfilemanager.cpp \
        smtp.cpp \
        variantmaptablemodel.cpp

RESOURCES += qml.qrc

QML_IMPORT_PATH =

QML_DESIGNER_IMPORT_PATH =

RC_FILE = resources.rc
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target


HEADERS += \
    projectmanager.h \
    settingsfilemanager.h \
    smtp.h \
    variantmaptablemodel.h

DISTFILES += \
    icon.ico \
    resources.rc

STATECHARTS +=
