import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/database.js" as DB

Page {
    id: root
    property bool blankingDisabled

    Component.onCompleted: {
         blankingDisabled = DB.isBlankingDisabled()
    }

    SilicaFlickable {
        id: flickerList
        anchors.fill: parent
        height: parent.height
        width: parent.width

        Column {
            id: content
            anchors {
               left: parent.left
               right: parent.right
               margins: Theme.paddingLarge
            }
            spacing: Theme.paddingMedium

            PageHeader {
                id: header
                title: "Settings"
            }
// Keep this option invisible to the user until timer works reliable even on deactivating blanking mode
//            TextSwitch {
//                id: blankingModeSwitch
//                text: "Blanking mode"
//                description: "Disables blanking of screen"
//                checked: blankingDisabled
//                onCheckedChanged: {
//                    if(checked) {
//                        DB.setBlankingDisabled(true);
//                    }
//                    else {
//                        DB.setBlankingDisabled(false);
//                    }
//                }
//            }
        }
    }
}
