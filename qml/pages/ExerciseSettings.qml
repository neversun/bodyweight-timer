import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/database.js" as DB

Page {
    id: settingsPage
    property variant    page
    property variant    title

    function capitaliseFirstLetter(string) {
        return string.charAt(0).toUpperCase() + string.slice(1);
    }
    
    ListModel {
        id: settingButtonModel
    }

    ListModel {
        id: settingSliderModel
    }

    Component.onCompleted: {
        appWindow.timerRunning = false
        appWindow.exerciseActive = false
        appWindow.timerStartedOnce = false
        
        var exerciseValueDescriptions = {
            CircleInterval: {
                value1: qsTr("duration")
            },
            IntervalSet: {
                value1: qsTr("duration per set"),
                value2: qsTr("sets per exercise"),
                value3: qsTr("number exercises")
            },
            SuperSet: {
                value1: qsTr("duration per set"),
                value2: qsTr("sets per exercise"),
                value3: qsTr("number exercises")
            },
            Ladder: {
                value1: qsTr("duration per exercise"),
                value2: qsTr("number exercises")
            },
            Tabata: {
                value1: qsTr("rounds per exercise"),
                value2: qsTr("duration of active time"),
                value3: qsTr("duration of pause"),
                value4: qsTr("number exercises")
            }
        }

        DB.getDatabaseValuesFor(page, function (columnValues) {
            var keys = Object.keys(columnValues)
            for (var i = 0; i < keys.length; i++) {
                var value = columnValues[keys[i]]
                var modelEntry = {
                    value: value.value,
                    valueDesc: exerciseValueDescriptions[page][value.name],
                    valueName: value.name
                }

                if (value.isTime) {
                    settingButtonModel.append(modelEntry)
                } else {
                    settingSliderModel.append(modelEntry)
                }
            }
       })
    }

    SilicaFlickable {
        id: settingsFlickable
        anchors.fill: parent
        contentHeight: header.height+explanation.height+listViewButtons.height+listViewSliders.height+Theme.paddingLarge
        width: settingsPage.width

        VerticalScrollDecorator {}

        PullDownMenu {
            MenuItem {
                id: menuOne
                text: qsTr("reset to default")
                onClicked: {
                    DB.defaultDatabaseValuesFor(page)
                    pageStack.replace(Qt.resolvedUrl("ExerciseSettings.qml"),{ page:page,title:title }, false )
                }
            }
        }

        PageHeader {
            id: header
            title: qsTr("settings: %1").arg(settingsPage.title.toString())
        }

        TextArea {
            id: explanation
            height: text.height
            color: Theme.highlightColor
            anchors.top: header.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            readOnly: true
            text: {
                if (page === 'CircleInterval') {
                    return qsTr('Do as much as you can for the duration of the exercise.\n\nReduce pauses to a minimum.\n\nTripple bell = end"')
                } else if (page === 'SuperSet') {
                    return qsTr('In a 4 minute set do the first superset (a pair of 2 exercises).\nDo at repetition 1 to 5 the first pair-exercise, and at repetition 6 to 12 the second pair-exercise. \nFirst pair-exercise should not cause you musle malfunction.\n\nSingle bell = next set\nDouble bell = next exercise pair\nTripple bell = end')
                } else if (page === 'IntervalSet') {
                    return qsTr('In a 3 minute set do 6 to 12 repetitions (stop on muscle malfunction). Pause rest of the set.\n\n1 of 3 sets should cause you to muscle malfunction. Do harder/another exercise if not.\n\nSingle bell = next set\nDouble bell = next exercise\nTripple bell = end')
                } else if (page === 'Ladder') {
                    return qsTr('Do 1 repetition of an exercise and pause the time it took you do to so. Then do 2 repetitions and pause the time it took you to do these 2. And so forth.\nOn muscle malfunction reduce the repetitions by 1, then by another and so forth.\n\nAlready at 1 repetition again and time is not over? Start a new ladder!\n\nSingle bell = next exercise\nTripple bell = end')
                } else if (page === 'Tabata') {
                    return qsTr('During active time (green) move on. During pause time (red) pause.\n\nTry to find your ideal tempo (consistent repetitions).\n\nSingle bell = active time begins\nDouble bell = pause time begins\nTripple bell = next exercise or end.')
                }
            }
            wrapMode: TextEdit.WordWrap
            label: qsTr("instruction")
        }

        //Display all possible buttons
        SilicaListView {
            id: listViewButtons
            anchors.top: explanation.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            height: Theme.itemSizeMedium*settingButtonModel.count
            width: parent.width

            model: settingButtonModel
            delegate: Button {
                property int selectedMinute:  { Math.floor(model.value/60); }
                property int selectedSecond:  { model.value-(selectedMinute*60) }

                function openTimeDialog() {
                    var dialog = pageStack.push(Qt.resolvedUrl("TimerPickerDialogMinutesSeconds.qml"), {"minute":selectedMinute,"second":selectedSecond})

                    dialog.accepted.connect(function() {
                        selectedMinute = dialog.minute
                        selectedSecond = dialog.second
                        DB.setDatabaseValuesFor(page,model.valueName,selectedMinute*60+selectedSecond)
                    })
                }

                anchors.horizontalCenter: parent.horizontalCenter
                height: Theme.itemSizeMedium
                color: Theme.primaryColor
                text: { 
                    //: m = minute, s = second
                    model.valueDesc+": " + qsTr("%1m %2s").arg(selectedMinute).arg(selectedSecond)
                }
                onClicked: openTimeDialog()
            }
        }

        //Display all possible sliders
        SilicaListView {
            id: listViewSliders
            anchors.top: listViewButtons.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            height: Theme.itemSizeMedium*settingSliderModel.count
            width: parent.width

            model: settingSliderModel            
            delegate: Slider {
                anchors.horizontalCenter: parent.horizontalCenter
                height: Theme.itemSizeMedium
                width: ListView.view.width
                minimumValue: 1
                maximumValue: 20
                stepSize: 1
                value: model.value
                valueText: value
                label: model.valueDesc
                onValueChanged: { DB.setDatabaseValuesFor(page,model.valueName,value);}
            }
        }
    }
}
