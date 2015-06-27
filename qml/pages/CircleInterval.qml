import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import "../js/database.js" as DB

Page{
    id: exercisePage

    // property from lower stack page
    property variant    page
    property variant    title

    //  parameters from DB
    property variant    value1ReturnFromDB;
    property int        value1;

    onStatusChanged: {
        if(status === PageStatus.Active)
        {
            value1ReturnFromDB = DB.getDatabaseValuesFor(page,"value1");
            value1 = value1ReturnFromDB[0];
        }
    }

    //  page internal properties
    //current time
    property int timerValue:value1;
    //save for reset. dont change
    property int timerValuePermanent:value1;

    //current round
    property int exerciseValue:1;
    //save for reset. dont change
    property int exerciseValuePermanent:1


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
                var displayMinutes = Math.floor(timerValue/60);
                var displaySeconds = timerValue-(displayMinutes*60)
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
            Timer {
                id: progressCircleTimer
                interval: 1000
                repeat: true
                running: false
                onTriggered: {
                    //init
                    if(exercisePage.timerValue === exercisePage.timerValuePermanent) {
                        var secondsOfCurrentTime = (exercisePage.value1 % 60)
                        progressCircle.value = (100-(0.01666666667 * secondsOfCurrentTime))
                    }
                    //calc the current time
                    progressCircle.value = (progressCircle.value + 0.01666666667) % 1.0
                    exercisePage.timerValue = exercisePage.timerValue-1

                    //no more remaining exercises?
                    if(exerciseValue == 0) {
                        doubleBell.play()
                        exercisePage.timerValue = exercisePage.timerValuePermanent
                        exercisePage.exerciseValue = exercisePage.exerciseValuePermanent
                        progressCircleTimer.restart()
                        progressCircleTimer.stop()
                    } else {
                        //reset timer and remove 1 of a exercise
                        if(exercisePage.timerValue === 0) {
                            exercisePage.exerciseValue = exercisePage.exerciseValue-1
                            if(exerciseValue !== 0) {
                                singleBell.play()
                            }
                            progressCircleTimer.stop()
                            exercisePage.timerValue = exercisePage.timerValuePermanent
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
                    " "
                }
                else { "Go for it!" }
            }
            font.pixelSize: Theme.fontSizeMedium
        }

        Button {
            anchors.top: currentRoundDisplay.bottom
            anchors.horizontalCenter: parent.horizontalCenter
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
