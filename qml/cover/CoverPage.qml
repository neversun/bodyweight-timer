/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/global_functions.js" as AppFunctions

CoverBackground {

    property bool exerciseActiveTime: appWindow.exerciseActiveTime

    property string activeTimeColor: "lime"
    property string pauseTimeColor: "red"

    function formatSecondsToMinuteSeconds(seconds) {
        var displayMinutes = Math.floor(seconds/60);
        var displaySeconds = seconds-(displayMinutes*60);

        if(displaySeconds.toString().length === 1) {
            displaySeconds = "0"+ displaySeconds;
        }
        if(displayMinutes.toString().length === 1) {
            displayMinutes = "0"+ displayMinutes;
        }
        return displayMinutes+":"+displaySeconds;
    }

    function showPlaceholder() {
        coverPause.enabled = false
        coverTitle.visible = false
        coverTime.visible = false
        coverExerciseNumber.visible = false
        coverSetNumber.visible = false
        coverTimeLabel.visible = false
        coverSetLabel.visible = false
        coverExerciseLabel.visible = false

        coverTime.color = Theme.primaryColor

        placeholder.visible = true
    }

    function setColorActiveTime(isActiveTime) {
        if(appWindow.exerciseActiveName === "Tabata") {
            if(exerciseActiveTime) {
                coverTime.color = activeTimeColor
            } else {
                coverTime.color = pauseTimeColor
            }
        }
    }

    // TODO: Peeking shows, if changed, old status
    onStatusChanged: {
        if(status !== Cover.Inactive && appWindow.exerciseActiveName === "Circle interval") {
            showPlaceholder();
            coverPause.enabled = true
            coverTitle.visible = true
            coverTime.visible = true
            coverTimeLabel.visible = true

            placeholder.visible = false
        }
        if(status !== Cover.Inactive && appWindow.exerciseActiveName === "Interval set") {
            showPlaceholder();
            coverPause.enabled = true
            coverTitle.visible = true
            coverTime.visible = true
            coverExerciseNumber.visible = true
            coverSetNumber.visible = true
            coverTimeLabel.visible = true
            coverSetLabel.visible = true
            coverExerciseLabel.visible = true

            placeholder.visible = false
        }
        if(status !== Cover.Inactive && appWindow.exerciseActiveName === "Ladder") {
            showPlaceholder();
            coverPause.enabled = true
            coverTitle.visible = true
            coverTime.visible = true
            coverExerciseNumber.visible = true
            coverTimeLabel.visible = true
            coverExerciseLabel.visible = true

            placeholder.visible = false
        }
        if(status !== Cover.Inactive && appWindow.exerciseActiveName === "Super set") {
            showPlaceholder();
            coverPause.enabled = true
            coverTitle.visible = true
            coverTime.visible = true
            coverExerciseNumber.visible = true
            coverSetNumber.visible = true
            coverTimeLabel.visible = true
            coverSetLabel.visible = true
            coverExerciseLabel.visible = true

            placeholder.visible = false
        }
        if(status !== Cover.Inactive && appWindow.exerciseActiveName === "Tabata") {
            showPlaceholder();
            coverPause.enabled = true
            coverTitle.visible = true
            coverTime.visible = true
            coverExerciseNumber.visible = true
            coverTimeLabel.visible = true
            coverExerciseLabel.visible = true

            coverTime.color = activeTimeColor

            placeholder.visible = false
        }
        if(!appWindow.exerciseActive) {
            showPlaceholder();
        }

        setColorActiveTime(exerciseActiveTime)
    }

    onExerciseActiveTimeChanged: setColorActiveTime(exerciseActiveTime)

    CoverPlaceholder {
                id: placeholder
                visible: true
                Image {
                    anchors.centerIn: parent
                    source: "cover.png"
                }
            }

    Column {
        width: parent.width
        spacing: Theme.paddingSmall
        anchors {
           left: parent.left
           right: parent.right
           margins: Theme.paddingLarge
        }

        Label {
            id: coverTitle
            font.pixelSize: Theme.fontSizeTiny
            visible: false
            horizontalAlignment: Text.AlignLeft
            anchors {
               left: parent.left
               right: parent.right
            }
            color: Theme.primaryColor
            text: appWindow.exerciseActiveName
        }

        Label {
            id: coverTimeLabel
            text: qsTrId('time')
            visible: false
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeSmall
            horizontalAlignment: Text.AlignLeft
            anchors {
               left: parent.left
               right: parent.right
            }
        }

        Label {
            id: coverTime
            visible: false
            text: formatSecondsToMinuteSeconds(appWindow.currentTime) + "/" + formatSecondsToMinuteSeconds(appWindow.maximalTime)
            horizontalAlignment: Text.AlignHCenter
            anchors {
               left: parent.left
               right: parent.right
            }
        }

        Label {
            id: coverSetLabel
            text: qsTrId('set')
            visible: false
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeSmall
            horizontalAlignment: Text.AlignLeft
            anchors {
               left: parent.left
               right: parent.right
            }
        }

        Label {
            id: coverSetNumber
            visible: false
            color: Theme.primaryColor
            text: {
                var currentSet;
                if(appWindow.currentSetNumber > appWindow.maximalSetNumber) {
                    currentSet = appWindow.maximalSetNumber;
                } else {
                    currentSet = appWindow.currentSetNumber;
                }

                currentSet+ "/" + appWindow.maximalSetNumber
            }
            horizontalAlignment: Text.AlignHCenter
            anchors {
               left: parent.left
               right: parent.right
            }
        }

        Label {
            id: coverExerciseLabel
            text: qsTrId('exercise')
            visible: false
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeSmall
            horizontalAlignment: Text.AlignLeft
            anchors {
               left: parent.left
               right: parent.right
            }
        }

        Label {
            id: coverExerciseNumber
            visible: false
            color: Theme.primaryColor
            text: {
                var currentExercise;
                if(appWindow.currentExerciseNumber > appWindow.maximalExerciseNumber) {
                    currentExercise = appWindow.maximalExerciseNumber;
                } else {
                    currentExercise = appWindow.currentExerciseNumber;
                }

                currentExercise+ "/" + appWindow.maximalExerciseNumber
            }
            horizontalAlignment: Text.AlignHCenter
            anchors {
               left: parent.left
               right: parent.right
            }
        }

        CoverActionList {
            id: coverPause
            enabled: false

            CoverAction {
                iconSource: appWindow.timerRunning ? "image://theme/icon-cover-pause" : "image://theme/icon-cover-play"
                onTriggered: appWindow.timerRunning = !appWindow.timerRunning
            }
        }
    }
}


