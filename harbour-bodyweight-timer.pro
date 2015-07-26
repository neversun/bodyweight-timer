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
CONFIG += c++11

QT += network dbus

SOURCES += src/harbour-bodyweight-timer.cpp \
    src/applibrary.cpp

OTHER_FILES += qml/harbour-bodyweight-timer.qml \
    qml/cover/CoverPage.qml \
    rpm/harbour-bodyweight-timer.changes.in \
    rpm/harbour-bodyweight-timer.spec \
    rpm/harbour-bodyweight-timer.yaml \
    translations/*.ts \
    harbour-bodyweight-timer.desktop \
    qml/components/TimePickerMinutesSeconds.qml \
    qml/js/database.js \
    qml/pages/sound/double_boxing-bell.wav \
    qml/pages/sound/single_boxing-bell.wav \
    qml/pages/About.qml \
    qml/pages/CircleInterval.qml \
    qml/pages/Home.qml \
    qml/pages/IntervalSet.qml \
    qml/pages/Ladder.qml \
    qml/pages/SuperSet.qml \
    qml/pages/Tabata.qml \
    qml/pages/TimerPickerDialogMinutesSeconds.qml \
    qml/js/global_functions.js \
    harbour-bodyweight-timer.png \
    qml/cover/cover.png \
    qml/pages/ExerciseSettings.qml \
    qml/pages/AppSettings.qml

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-bodyweight-timer-de.ts

HEADERS += \
    src/applibrary.h

