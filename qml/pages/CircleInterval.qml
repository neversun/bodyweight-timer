import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import "../js/database.js" as DB
import "../js/global_functions.js" as AppFunctions

Page{
    id: exercisePage

    // property from lower stack page
    property variant    page
    property variant    title

    // initialize page properties once page is fully loaded
    onStatusChanged: {
        if(status === PageStatus.Activating) {
            DB.getDatabaseValuesFor(page, function (columValues) {
                exercisePage.timePerSet = columValues.value1.value
                appWindow.exerciseActive = true
                appWindow.exerciseActiveName = title
            })
        }
    }

    //##    page internal properties
    // current time
    property int currentTime
    property int timePerSet

    onTimePerSetChanged: {
        AppFunctions.resetCurrentTime();
        appWindow.maximalTime = timePerSet;
    }
    onCurrentTimeChanged: appWindow.currentTime = currentTime

    // current set of an exercise
    property int currentSet:1
    property int setsPerExercise:1

    onSetsPerExerciseChanged: {
        AppFunctions.resetCurrentSet();
        appWindow.maximalExerciseNumber = setsPerExercise;
    }
    onCurrentSetChanged: appWindow.currentExerciseNumber = currentSet
    ////

    SilicaFlickable {
        id: flickerList
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr('settings')
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("ExerciseSettings.qml"), {page: page, title: title})
                    AppFunctions.resetTimerWithTimeSet();
                }
            }
        }

        PageHeader {
            id: header
            title: exercisePage.title
        }

        Audio {
            id: singleBell
            source: "sound/single_boxing-bell.wav"
        }
        Audio {
            id: doubleBell
            source: "sound/double_boxing-bell.wav"
        }
        Audio {
            id: trippleBell
            source: "sound/tripple_boxing-bell.wav"
        }


        Label {
            id: timerAsNumber
            color: Theme.highlightColor
            anchors.centerIn: progressCircle.Center
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset : -(Theme.itemSizeMedium)
            text: {
                var displayMinutes = Math.floor(currentTime/60)
                var displaySeconds = currentTime-(displayMinutes*60)
                //: m = minute, s = second
                qsTr("%1m %2s").arg(displayMinutes).arg(displaySeconds)
            }
            font.pixelSize: Theme.fontSizeHuge
        }

        ProgressCircle {
            id: progressCircle
            scale: 4.5
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset : -(Theme.itemSizeMedium)
            progressColor: Theme.highlightColor
            backgroundColor: Theme.highlightDimmerColor
            Timer {
                id: progressCircleTimer
                interval: 1000
                repeat: true
                running: appWindow.timerRunning
                triggeredOnStart: true
                onTriggered: {
                    //init
                    if(exercisePage.currentTime === exercisePage.timePerSet) {
                        var secondsOfCurrentTime = (exercisePage.value1 % 60);
                        progressCircle.value = (100-(0.01666666667 * secondsOfCurrentTime));
                    }
                    //calc the current time
                    progressCircle.value = (progressCircle.value + 0.01666666667) % 1.0;
                    exercisePage.currentTime -= 1;

                    //no more remaining sets for this exercise?
                    if(exercisePage.currentTime === 0) {
                        trippleBell.play();
                        AppFunctions.resetTimerWithTimeSet();
                    }
                }
            }
        }

        Button {
            anchors.top: progressCircle.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset : (Theme.itemSizeMedium)+progressCircle.height
            onClicked: AppFunctions.timerTogglePause()
            text: {
                if(progressCircleTimer.running) {
                    qsTr("pause")
                } else {
                    if(appWindow.timerStartedOnce) {
                        qsTr("resume")
                    }
                    else {
                        qsTr("start")
                    }
                }
            }
        }
    }
}
