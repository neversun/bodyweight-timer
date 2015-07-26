.import "database.js" as DB

function timerTogglePause() {
    appWindow.timerRunning = !appWindow.timerRunning;
    appWindow.timerStartedOnce = true;
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
}

function resetTimerWithTimeSet() {
    resetTimerWithTime();
    resetCurrentSet();
}

function resetTimerWithTimeRound(){
    resetTimerWithTime();
    resetCurrentRound();
}

function resetTimerWithTimeSetRound() {
    resetTimerWithTimeSet();
    resetCurrentRound();
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
