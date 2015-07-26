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
