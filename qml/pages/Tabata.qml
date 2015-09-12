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
        if(status === PageStatus.Activating)
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

        if(status === PageStatus.Active) {
            AppFunctions.enableBlanking()
        }

        if (status === PageStatus.Deactivating) {
            AppFunctions.disableBlanking()
        }
    }

    //##    page internal properties
    // duration of active time
    property int remainingActiveTime
    property int activeTimeDuration:value2

    onActiveTimeDurationChanged: resetRemainingActiveTime()

    //duration of pause
    property int remainingPauseTime
    property int pauseTimeDuration:value3

    onPauseTimeDurationChanged: resetRemainingPauseTime()

    //rounds per exercise
    property int roundsPerExercise:value1

    //number of exercises
    property int currentExercise
    property int numberOfExercises: value4

    onNumberOfExercisesChanged: {
        resetCurrentExercise();
        appWindow.maximalExerciseNumber = numberOfExercises;
    }
    onCurrentExerciseChanged: appWindow.currentExerciseNumber = currentExercise

    //sum of all active times + pauses
    property int remainingSumAllDurations
    property int sumAllDurations: (activeTimeDuration+pauseTimeDuration)*roundsPerExercise

    onSumAllDurationsChanged: {
        resetRemainingSumAllDurations();
        appWindow.maximalTime = sumAllDurations;
    }
    onRemainingSumAllDurationsChanged: appWindow.currentTime = remainingSumAllDurations

    //track the current mode (active or pause)
    property bool isActiveTime: true

    onIsActiveTimeChanged: {
        appWindow.exerciseActiveTime = isActiveTime;
    }

    // color of ProgressCircle based current mode (active or pause time)
    property string progressCircleColor: "lime"
    ////

    //##    page internal JS functions
    function resetRemainingActiveTime() {
        remainingActiveTime = activeTimeDuration;
    }

    function resetRemainingPauseTime() {
        remainingPauseTime = pauseTimeDuration;
    }

    function resetCurrentExercise() {
        currentExercise = 1
    }

    function resetRemainingSumAllDurations() {
        remainingSumAllDurations = sumAllDurations
    }

    function resetTimerWithActivePauseExerciseSum() {
        resetRemainingActiveTime();
        resetRemainingPauseTime();
        resetCurrentExercise();
        resetRemainingSumAllDurations();
        progressCircleTimer.restart();
        progressCircleTimer.stop();
    }
    ////


    SilicaFlickable {
        id: flickerList
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: "Settings"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("ExerciseSettings.qml"), {page: page, title: title});
                    resetTimerWithActivePauseExerciseSum();
                }
            }
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

        PageHeader {
            id: header
            title: exercisePage.title
        }

        Label {
            id: timerAsNumber
            color: Theme.highlightColor
            anchors.centerIn: progressCircle.Center
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset : -(Theme.itemSizeMedium)
            text: {
                var displayMinutes = Math.floor(remainingSumAllDurations/60);
                var displaySeconds = remainingSumAllDurations-(displayMinutes*60)
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
            progressColor: progressCircleColor
            backgroundColor: Theme.highlightDimmerColor
            Timer {
                id: progressCircleTimer
                interval: 1000
                repeat: true
                running: appWindow.timerRunning
                triggeredOnStart: true
                onTriggered: {
                    //init
                    if(exercisePage.remainingSumAllDurations === exercisePage.sumAllDurations) {
                        var secondsOfCurrentTime = (exercisePage.sumAllDurations % 60)
                        progressCircle.value = (100-(0.0166666666766666667 * secondsOfCurrentTime))
                    }
                    //calc the current time
                    progressCircle.value = (progressCircle.value + 0.0166666666766666667) % 1.0
                    exercisePage.remainingSumAllDurations -= 1

                    //no more remaining time in this exercise?
                    if(exercisePage.remainingSumAllDurations === 0)
                    {
                        //no more remaining exercises?
                        if(currentExercise >= numberOfExercises)
                        {
                            trippleBell.play();
                            resetTimerWithActivePauseExerciseSum();
                        } else {
                            //reset timer and add 1 to current exercise
                            exercisePage.currentExercise += 1
                            if(currentExercise <= numberOfExercises)
                            {
                                trippleBell.play();
                            }
                            progressCircleTimer.stop()
                            resetRemainingSumAllDurations();
                            progressCircleTimer.restart()
                            AppFunctions.timerTogglePause()
                        }
                    } else {
                        //count remaining time
                        if(isActiveTime)
                        {
                            remainingActiveTime -= 1
                        } else {
                            remainingPauseTime -= 1
                        }

                        if(remainingActiveTime === 0) //Enter pause-mode
                        {
                            doubleBell.play();
                            isActiveTime = false;
                            progressCircleColor = "red";
                            resetRemainingActiveTime();
                        }
                        if(remainingPauseTime === 0) //Enter active-mode
                        {
                            singleBell.play();
                            isActiveTime = true;
                            progressCircleColor = "lime";
                            resetRemainingPauseTime();
                        }
                    }
                }
            }
        }

        Label {
            id:currentExerciseDisplay
            color: Theme.highlightColor
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset : (Theme.itemSizeMedium)+progressCircle.height
            font.pixelSize: Theme.fontSizeMedium
            text: {
                if(progressCircleTimer.running || appWindow.timerStartedOnce) {
                    "current excerise: " + currentExercise + " of " + numberOfExercises
                }
                else { "Number of exercises: " + numberOfExercises}
            }
        }



        Button {
            anchors.top: currentExerciseDisplay.bottom
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
