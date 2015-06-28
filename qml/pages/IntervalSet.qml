import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import "../js/database.js" as DB

Page{
    id: exercisePage

    // property from lower stack page
    property variant    page
    property variant    title

    // parameters from DB
    property variant    value1ReturnFromDB
    property variant    value2ReturnFromDB
    property variant    value3ReturnFromDB
    property int        value1
    property int        value2
    property int        value3

    onStatusChanged: {
        if(status === PageStatus.Active)
        {
            value1ReturnFromDB = DB.getDatabaseValuesFor(page,"value1");
            onValue1ReturnFromDBchanged: value1 = value1ReturnFromDB[0];
            value2ReturnFromDB = DB.getDatabaseValuesFor(page,"value2");
            onValue2ReturnFromDBchanged: value2 = value2ReturnFromDB[0];
            value3ReturnFromDB = DB.getDatabaseValuesFor(page,"value3");
            onValue3ReturnFromDBchanged: value3 = value3ReturnFromDB[0];
        }
    }

    //  page internal properties
    //current time
    property int setDuration:value1;

    //save for reset. dont change
    property int setDurationPermanent:value1;

    //rounds per exercise
    property int setPerExercise: value2
    //save for reset. dont change
    property int setPerExercisePermanent:value2

    //current round from high to low
    property int exerciseValue:value3;

    //save for reset. dont change
    property int exerciseValuePermanent:value3;

    SilicaFlickable {
        id: flickerList
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: "Settings"
                onClicked: pageStack.push(Qt.resolvedUrl("Settings.qml"), {page: page, title: title})
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

        Label {
            id: timerAsNumber
            color: Theme.highlightColor
            anchors.centerIn: progressCircle.Center
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset : -(Theme.itemSizeMedium)
            text: {
                var displayMinutes = Math.floor(setDuration/60);
                var displaySeconds = setDuration-(displayMinutes*60)
                displayMinutes+"m "+displaySeconds+"s"
            }
            font.pixelSize: Theme.fontSizeHuge
        }

        ProgressCircle {
            id: progressCircle
            scale: 4
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset : -(Theme.itemSizeMedium)
            progressColor: Theme.highlightColor
            backgroundColor: Theme.highlightDimmerColor
            Timer {
                id: progressCircleTimer
                interval: 1000
                repeat: true
                running: false
                onTriggered: {
                    //init
                    if(exercisePage.setDuration === exercisePage.setDurationPermanent) {
                        var secondsOfCurrentTime = (exercisePage.setDurationPermanent % 60)
                        progressCircle.value = (100-(0.01666666667 * secondsOfCurrentTime))
                    }
                    //calc the current time
                    progressCircle.value = (progressCircle.value + 0.01666666667) % 1.0
                    exercisePage.setDuration = exercisePage.setDuration-1

                    //no more remaining sets for this exercise?
                    if(setPerExercise == 0) {
                        exerciseValue = exerciseValue - 1
                        if(exerciseValue == 0)
                        {
                            singleBell.play()
                            doubleBell.play() //IMPROVEMENT: Tripple Bell?
                            exercisePage.setDuration = exercisePage.setDurationPermanent
                            exercisePage.setPerExercise = exercisePage.setPerExercisePermanent
                            exercisePage.exerciseValue = exercisePage.exerciseValuePermanent
                            progressCircleTimer.restart()
                            progressCircleTimer.stop()
                        } else {
                            doubleBell.play()
                            exercisePage.setDuration = exercisePage.setDurationPermanent
                            exercisePage.setPerExercise = exercisePage.setPerExercisePermanent
                            progressCircleTimer.restart()
                        }
                    } else {
                        //reset timer and remove 1 of a set
                        if(exercisePage.setDuration === 0) {
                            exercisePage.setPerExercise = exercisePage.setPerExercise - 1
                            if(setPerExercise !== 0) {
                                singleBell.play()
                            }
                            progressCircleTimer.stop()
                            exercisePage.setDuration = exercisePage.setDurationPermanent
                            progressCircleTimer.restart()
                        }
                    }
                }
                triggeredOnStart: true
            }
        }

        Label {
            id:currentRoundDisplay
            color: Theme.highlightColor
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset : (Theme.itemSizeMedium)+progressCircle.height
            text: {
                var currentRoundFromLowToHigh = (exerciseValuePermanent-exerciseValue+1)
                if(currentRoundFromLowToHigh <= exerciseValuePermanent && progressCircleTimer.running) {
                    "current set: " + (setPerExercisePermanent-setPerExercise+1) + " of " + setPerExercisePermanent + "\n" +
                    "current excerise: " + currentRoundFromLowToHigh + " of " + exerciseValuePermanent
                }
                else { "Go for it!" }
            }
            font.pixelSize: Theme.fontSizeMedium
        }


        Button {
            anchors.top: currentRoundDisplay.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: Theme.paddingLarge
            text: {
                if(progressCircleTimer.running) {
                    "Pause"
                } else {
                    "Start"
                }
            }
            onClicked: progressCircleTimer.running = !progressCircleTimer.running
        }
    }
}
