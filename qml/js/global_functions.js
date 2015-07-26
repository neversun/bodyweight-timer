.import "database.js" as DB

function timerTogglePause() {
    appWindow.timerRunning = !appWindow.timerRunning;
    appWindow.timerStartedOnce = true;
}

function enableBlanking() {
    appLibrary.setBlankingMode(DB.isBlankingDisabled())
}

function disableBlanking() {
    console.log("disableBlanking");
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

function resetTimerWithTimeSet() {
    resetCurrentTime();
    resetCurrentSet();
    progressCircleTimer.restart();
    progressCircleTimer.stop();
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
