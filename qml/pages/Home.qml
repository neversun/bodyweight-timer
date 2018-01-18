import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/database.js" as DB

Page {
    id: root

    Component.onCompleted: {
        DB.initializeDatabase()
    }

    onStatusChanged: {
        if(status === PageStatus.Activating) {
            appWindow.timerRunning = false
            appWindow.exerciseActive = false
            appWindow.timerStartedOnce = false
        }
    }

    ScreenBlank {
      enabled: appWindow.exerciseActive
    }

    SilicaFlickable {
        id: flickerList
        anchors.fill: parent
        height: parent.height
        width: parent.width

        PullDownMenu {
            MenuItem {
                text: qsTrId("about")
                onClicked: pageStack.push(Qt.resolvedUrl("About.qml"))
            }
        }

        PageHeader {
            id: header
            title: {
                qsTrId("workouts")
            }
        }

        ListModel {
            id: homeModel
            ListElement {
                page: "CircleInterval"
                title: qsTrId("circle-interval")
            }
            ListElement {
                page: "IntervalSet"
                title: qsTrId("interval-set")
            }
            ListElement {
                page: "Ladder"
                title: qsTrId("ladder")
            }
            ListElement {
                page: "SuperSet"
                title: qsTrId("super-set")
            }
            ListElement {
                page: "Tabata"
                title: qsTrId("tabata")
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
                onClicked: pageStack.push(Qt.resolvedUrl(model.page+".qml"), {page: model.page,title:model.title} )
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
