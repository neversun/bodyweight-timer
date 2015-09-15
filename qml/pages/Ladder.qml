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

    // parameters from DB
    property variant    value1ReturnFromDB
    property variant    value2ReturnFromDB
    property int        value1
    property int        value2

    onStatusChanged: {
        if(status === PageStatus.Activating)
        {
            value1ReturnFromDB = DB.getDatabaseValuesFor(page,"value1")
            onValue1ReturnFromDBchanged: value1 = value1ReturnFromDB[0]
            value2ReturnFromDB = DB.getDatabaseValuesFor(page,"value2")
            onValue2ReturnFromDBchanged: value2 = value2ReturnFromDB[0]

            appWindow.exerciseActive = true
            appWindow.exerciseActiveName = title
        }
    }

    //##    page internal properties
    // current time
    property int currentTime
    property int timePerSet:value1

    onTimePerSetChanged: {
        AppFunctions.resetCurrentTime();
        appWindow.maximalTime = timePerSet;
    }
    onCurrentTimeChanged: appWindow.currentTime = currentTime

    // current round from high to low
    property int currentRound
    property int roundsPerExercise:value2

    onRoundsPerExerciseChanged: {
        AppFunctions.resetCurrentRound();
        appWindow.maximalExerciseNumber = roundsPerExercise;
    }
    onCurrentRoundChanged: appWindow.currentExerciseNumber =  currentRound
    ////

    SilicaFlickable {
        id: flickerList
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: "Settings"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("ExerciseSettings.qml"), {page: page, title: title});
                    AppFunctions.resetTimerWithTimeRound();
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
                var displayMinutes = Math.floor(currentTime/60);
                var displaySeconds = currentTime-(displayMinutes*60)
                displayMinutes+"m "+displaySeconds+"s"
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
                        var secondsOfCurrentTime = (exercisePage.timePerSet % 60);
                        progressCircle.value = (100-(0.01666666667 * secondsOfCurrentTime));
                    }
                    //calc the current time
                    progressCircle.value = (progressCircle.value + 0.01666666667) % 1.0;
                    exercisePage.currentTime -= 1;

                    //no more remaining sets for this exercise?
                    if(currentRound > roundsPerExercise) {
                        trippleBell.play();
                        AppFunctions.resetTimerWithTimeRound();
                    } else {
                        //reset timer and remove 1 of a set
                        if(exercisePage.currentTime === 0) {
                            exercisePage.currentRound += 1;
                            if(currentRound <= roundsPerExercise) {
                                singleBell.play();
                                AppFunctions.restartTimer();
                                AppFunctions.timerTogglePause();
                            }
                        }
                    }
                }
            }
        }

        Label {
            id:currentRoundDisplay
            color: Theme.highlightColor
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset : (Theme.itemSizeMedium)+progressCircle.height
            font.pixelSize: Theme.fontSizeMedium
            text: {
                if(progressCircleTimer.running || appWindow.timerStartedOnce) {
                    if(currentRound <= roundsPerExercise) {
                        "current excerise: " + currentRound + " of " + roundsPerExercise
                    }
                    else {
                        "current excerise: " + roundsPerExercise + " of " + roundsPerExercise
                    }
                }
                else {
                    "Number of exercises: " + roundsPerExercise
                }
            }
        }

        Button {
            anchors.top: currentRoundDisplay.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: Theme.paddingLarge
            onClicked: AppFunctions.timerTogglePause()
            text: {
                if(progressCircleTimer.running) {
                    "Pause"
                }
                else {
                    if(appWindow.timerStartedOnce) {
                        "Resume"
                    }
                    else {
                        "Start"
                    }
                }
            }
        }
    }
}
