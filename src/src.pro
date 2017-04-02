TEMPLATE = app

TARGET = harbour-bodyweighttimer

# App version
DEFINES += APP_VERSION=\"\\\"$${VERSION}\\\"\"

CONFIG += sailfishapp

QT += dbus
#declarative

SOURCES += $${TARGET}.cpp

CONFIG(release, debug|release) {
    DEFINES += QT_NO_DEBUG_OUTPUT
}
