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
    property variant    value3ReturnFromDB
    property variant    value4ReturnFromDB
    property int        value1
    property int        value2
    property int        value3
    property int        value4

    onStatusChanged: {
        if(status === PageStatus.Active)
        {
            value1ReturnFromDB = DB.getDatabaseValuesFor(page,"value1")
            onValue1ReturnFromDBchanged: value1 = value1ReturnFromDB[0]
            value2ReturnFromDB = DB.getDatabaseValuesFor(page,"value2")
            onValue2ReturnFromDBchanged: value2 = value2ReturnFromDB[0]
            value3ReturnFromDB = DB.getDatabaseValuesFor(page,"value3")
            onValue3ReturnFromDBchanged: value3 = value3ReturnFromDB[0]
            value4ReturnFromDB = DB.getDatabaseValuesFor(page,"value4")
            onValue4ReturnFromDBchanged: value4 = value4ReturnFromDB[0]

            appWindow.exerciseActive = true
            appWindow.exerciseActiveName = title
            AppFunctions.enableBlanking()
        }
        if (status === PageStatus.Deactivating) {
            AppFunctions.disableBlanking()
        }
    }

    //  page internal properties
    //duration of active time
    property int activeTimeDuration:value2
    //save for reset. dont change
    property int activeTimeDurationPermament:value2

    //duration of pause
    property int pauseDuration:value3
    //save for reset. dont change
    property int pauseDurationPermanent:value3

    //rounds per exercise
    property int roundsPerExercise:value1
    //save for reset. dont change
    property int roundsPerExercisePermanent:value1

    //number of exercises
    property int numberOfExercises: value4
    //save for reset. dont change
    property int numberOfExercisesPermanent: value4

    //sum of all active times + pauses
    property int sumAllDurations: (activeTimeDurationPermament+pauseDurationPermanent)*roundsPerExercisePermanent
    //save for reset. dont change
    property int sumAllDurationsPermanent: (activeTimeDurationPermament+pauseDurationPermanent)*roundsPerExercisePermanent

    //track the current mode (active or pause)
    property int activeTimeRemaining: activeTimeDurationPermament
    property int pauseTimeRemaining: pauseDurationPermanent
    property bool isActiveTime: true

    //ProgressCircle
    property string progressCircleColor: "lime"

    //duration of an exercise: per every exercise (this are rounds too) -> roundsPerExercise * (activeTimeDuration+pauseDuration)

    SilicaFlickable {
        id: flickerList
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: "Settings"
                onClicked: pageStack.push(Qt.resolvedUrl("ExerciseSettings.qml"), {page: page, title: title})
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
                var displayMinutes = Math.floor(sumAllDurations/60);
                var displaySeconds = sumAllDurations-(displayMinutes*60)
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
            progressColor: progressCircleColor
            backgroundColor: Theme.highlightDimmerColor
            Timer {
                id: progressCircleTimer
                interval: 1000
                repeat: true
                running: appWindow.timerRunning
                onTriggered: {
                    //init
                    if(exercisePage.sumAllDurations === exercisePage.sumAllDurationsPermanent) {
                        var secondsOfCurrentTime = (exercisePage.sumAllDurationsPermanent % 60)
                        progressCircle.value = (100-(0.0166666666766666667 * secondsOfCurrentTime))
                    }
                    //calc the current time
                    progressCircle.value = (progressCircle.value + 0.0166666666766666667) % 1.0
                    exercisePage.sumAllDurations = exercisePage.sumAllDurations-1

                    //no more remaining time in this exercise?
                    if(exercisePage.sumAllDurations === 0)
                    {
                        //no more remaining exercises?
                        if(numberOfExercises === 1)
                        {
                            //Improvement: TripleBell?
                            singleBell.play()
                            doubleBell.play()
                            exercisePage.sumAllDurations = exercisePage.sumAllDurationsPermanent
                            exercisePage.numberOfExercises = exercisePage.numberOfExercisesPermanent
                            progressCircleTimer.restart()
                            progressCircleTimer.stop()
                    } else {
                            //reset timer and remove 1 of a exercise
                            exercisePage.numberOfExercises = exercisePage.numberOfExercises-1
                            if(numberOfExercises !== 0)
                            {
                                singleBell.play()
                            }
                            progressCircleTimer.stop()
                            exercisePage.sumAllDurations = exercisePage.sumAllDurationsPermanent
                            progressCircleTimer.restart()
                        }
                    } else {
                        //count remaining time
                        if(isActiveTime)
                        {
                            console.log(activeTimeRemaining)
                            activeTimeRemaining = activeTimeRemaining-1
                            console.log(activeTimeRemaining)
                        } else {
                            console.log(pauseTimeRemaining)
                            pauseTimeRemaining = pauseTimeRemaining-1
                            console.log(pauseTimeRemaining)

                        }


                        if(activeTimeRemaining === 0) //Enter pause-mode
                        {
                            doubleBell.play()
                            isActiveTime = false
                            progressCircleColor = "red"
                            activeTimeRemaining = activeTimeDurationPermament
                        }
                        if(pauseTimeRemaining === 0) //Enter active-mode
                        {
                            singleBell.play()
                            isActiveTime = true
                            progressCircleColor = "lime"
                            pauseTimeRemaining = pauseDurationPermanent
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
                var currentRoundFromLowToHigh = (numberOfExercisesPermanent-numberOfExercises+1)
                if(currentRoundFromLowToHigh <= numberOfExercisesPermanent && progressCircleTimer.running) {
                    "current excerise: " + currentRoundFromLowToHigh
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
            onClicked: AppFunctions.timerTogglePause()
        }
    }
}
