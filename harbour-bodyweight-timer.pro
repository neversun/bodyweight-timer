# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-bodyweight-timer

CONFIG += sailfishapp

lupdate_only {
SOURCES =   qml/*.qml \
            qml/pages/*.qml
}

SOURCES += \
    src/harbour-bodyweight-timer.cpp

QT += network dbus

icons.path = /usr/share/icons/hicolor
icons.files = icons/*
INSTALLS += icons

OTHER_FILES += qml/*.qml \
    qml/cover/*.qml \
    qml/components/*.qml \
    qml/pages/*.qml \
    qml/js/*.js \
    rpm/*.spec \
    rpm/harbour-bodyweight-timer.yaml \
    qml/pages/sound/*.wav \
    harbour-bodyweight-timer.png \
    qml/cover/cover.png \
    harbour-bodyweight-timer.desktop \
    icons/86x86/apps/harbouy-bodyweight-timer.png \
    icons/108x108/apps/harbouy-bodyweight-timer.png \
    icons/128x128/apps/harbouy-bodyweight-timer.png \
    icons/256x256/apps/harbouy-bodyweight-timer.png \
    translations/*.ts

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += \
    translations/harbour-bodyweight-timer-de.ts
