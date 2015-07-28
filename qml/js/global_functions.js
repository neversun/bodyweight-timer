.import "database.js" as DB

function timerTogglePause() {
    if(appWindow.timerRunning === true) {
        appWindow.timerRunning = false;
    }
    if(appWindow.timerRunning === false) {
        appWindow.timerRunning = true;
    }
//    appWindow.timerRunning = !appWindow.timerRunning;
}

function enableBlanking() {
    appLibrary.setBlankingMode(DB.isBlankingDisabled())
}

function disableBlanking() {
    appLibrary.setBlankingMode(false);
}

function resetCurrentSet() {
    currentSet = 1;
}

function resetCurrentRound() {
    currentRound = 1;
}

function resetCurrentTime() {
    currentTime = timePerSet;
}

function resetTimerWithTime(){
    resetCurrentTime();
    progressCircleTimer.restart();
    progressCircleTimer.stop();
    appWindow.timerStartedOnce = false;
}

function resetTimerWithTimeSet() {
    resetTimerWithTime();
    resetCurrentSet();
    appWindow.timerStartedOnce = false;
}

function resetTimerWithTimeRound(){
    resetTimerWithTime();
    resetCurrentRound();
    appWindow.timerStartedOnce = false;
}

function resetTimerWithTimeSetRound() {
    resetTimerWithTimeSet();
    resetCurrentRound();
    appWindow.timerStartedOnce = false;
}

function restartTimerAndSet() {
    resetCurrentTime();
    resetCurrentSet();
    progressCircleTimer.restart()
}

function restartTimer() {
    progressCircleTimer.stop()
    resetCurrentTime();
    progressCircleTimer.restart()
}
