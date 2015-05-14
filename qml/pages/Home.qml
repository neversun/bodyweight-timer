import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/database.js" as DB

Page {
    id: root

    Component.onCompleted: {
        DB.initializeDatabase();
    }

    SilicaFlickable {
        id: flickerList
        anchors.fill: parent
        height: parent.height
        width: parent.width

        PullDownMenu {
            MenuItem {
                text: "About"
                onClicked: pageStack.push(Qt.resolvedUrl("About.qml"))
            }
        }

        PageHeader {
            id: header
            title: "Workouts"
        }

        ListModel {
            id: homeModel
            ListElement {
                page: "circleInterval"
                title: "Circle interval"
            }
            ListElement {
                page: "intervalSet"
                title: "Interval set"
            }
            ListElement {
                page: "ladder"
                title: "Ladder"
            }
            ListElement {
                page: "superSet"
                title: "Super set"
            }
            ListElement {
                page: "tabata"
                title: "Tabata"
            }
        }

        SilicaListView {
            id: timerList
            width: parent.width
            height: parent.height
            anchors.top: header.bottom
            anchors.topMargin: Theme.paddingLarge
            model: homeModel

            delegate: BackgroundItem {
                onClicked: pageStack.push(Qt.resolvedUrl("Settings.qml"), {page: model.page,title:model.title} )
                width: root.width
                Label {
                        text: model.title
                        font.pixelSize: Theme.fontSizeLarge
                        height: Theme.itemSizeLarge
                        width: parent.width
                        color: highlighted ? Theme.highlightColor : Theme.primaryColor
                        horizontalAlignment: Text.AlignHCenter
                    }
            }
        }
    }
}
