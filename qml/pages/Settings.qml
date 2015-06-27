import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/database.js" as DB

Page {
    id: settingsPage
    property variant    page
    property variant    title

    property variant    value1ReturnFromDB:     DB.getDatabaseValuesFor(page,"value1")
    property variant    value2ReturnFromDB:     DB.getDatabaseValuesFor(page,"value2")
    property variant    value3ReturnFromDB:     DB.getDatabaseValuesFor(page,"value3")
    property variant    value4ReturnFromDB:     DB.getDatabaseValuesFor(page,"value4")
    property variant    value1DescFromDB:       DB.getDatabaseValuesFor(page,"value1Desc")
    property variant    value2DescFromDB:       DB.getDatabaseValuesFor(page,"value2Desc")
    property variant    value3DescFromDB:       DB.getDatabaseValuesFor(page,"value3Desc")
    property variant    value4DescFromDB:       DB.getDatabaseValuesFor(page,"value4Desc")
    property string     value1Desc:             value1DescFromDB[0]
    property string     value2Desc:             value2DescFromDB[0]
    property string     value3Desc:             value3DescFromDB[0]
    property string     value4Desc:             value4DescFromDB[0]
    property int        value1:                 value1ReturnFromDB[0]
    property int        value2:                 value2ReturnFromDB[0]
    property int        value3:                 value3ReturnFromDB[0]
    property int        value4:                 value4ReturnFromDB[0]
    property bool       value1Display:          value1ReturnFromDB[1]
    property bool       value2Display:          value2ReturnFromDB[1]
    property bool       value3Display:          value3ReturnFromDB[1]
    property bool       value4Display:          value4ReturnFromDB[1]
    property bool       value1IsTime:           value1DescFromDB[2]
    property bool       value2IsTime:           value2DescFromDB[2]
    property bool       value3IsTime:           value3DescFromDB[2]
    property bool       value4IsTime:           value4DescFromDB[2]
    property string     explanation:            DB.getDatabaseValuesFor(page,"explanation")[0]

    function capitaliseFirstLetter(string) {
        return string.charAt(0).toUpperCase() + string.slice(1);
    }
    property string     attachedPage:       capitaliseFirstLetter(page)+".qml"

    ListModel {
        id: settingButtonModel
    }

    ListModel {
        id: settingSliderModel
    }

    Component.onCompleted: {
        if (value1Display) {if(value1IsTime) {settingButtonModel.append({"value": value1, "valueDesc": value1Desc,"valueName":"value1"});} else {settingSliderModel.append({"value":value1, "valueDesc":value1Desc,"valueName":"value1"});}};
        if (value2Display) {if(value2IsTime) {settingButtonModel.append({"value": value2, "valueDesc": value2Desc,"valueName":"value2"});} else {settingSliderModel.append({"value":value2, "valueDesc":value2Desc,"valueName":"value2"});}};
        if (value3Display) {if(value3IsTime) {settingButtonModel.append({"value": value3, "valueDesc": value3Desc,"valueName":"value3"});} else {settingSliderModel.append({"value":value3, "valueDesc":value3Desc,"valueName":"value3"});}};
        if (value4Display) {if(value4IsTime) {settingButtonModel.append({"value": value4, "valueDesc": value4Desc,"valueName":"value4"});} else {settingSliderModel.append({"value":value4, "valueDesc":value4Desc,"valueName":"value4"});}};
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
                text: "Reset to default"
                onClicked: {
                    DB.defaultDatabaseValuesFor(page)
                    pageStack.replace(Qt.resolvedUrl("Settings.qml"),{ page:page,title:title }, false )
                }
            }
        }

        PageHeader {
            id: header
            title: "Settings: "+settingsPage.title.toString()
        }

        //Display the explanation
        TextArea {
            id: explanation
            height: text.height
            color: Theme.highlightColor
            anchors.top: header.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            readOnly: true
            text: settingsPage.explanation
            wrapMode: TextEdit.WordWrap
            label: "explanation"
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
                text: { model.valueDesc+": "+selectedMinute+"m "+selectedSecond+"s" }
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
                maximumValue: 100
                stepSize: 1
                value: model.value
                valueText: value
                label: model.valueDesc
                onValueChanged: { DB.setDatabaseValuesFor(page,model.valueName,value);}
            }
        }

        //push page on stack and change to it
//        Button {
//            id: buttonGo
//            anchors.top: listViewSliders.bottom
//            anchors.topMargin: Theme.paddingLarge
//            anchors.horizontalCenter: parent.horizontalCenter
//            height: Theme.itemSizeMedium
//            text: "Go for it!"
//            onClicked: pageStack.push(Qt.resolvedUrl(attachedPage),{page:page,title:title})
//        }
    }
}
