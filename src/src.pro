TEMPLATE = app

TARGET = harbour-bodyweight-timer

# App version
DEFINES += APP_VERSION=\"\\\"$${VERSION}\\\"\"

CONFIG += sailfishapp

QT += dbus
#declarative

SOURCES += $${TARGET}.cpp

CONFIG(release, debug|release) {
    DEFINES += QT_NO_DEBUG_OUTPUT
}
