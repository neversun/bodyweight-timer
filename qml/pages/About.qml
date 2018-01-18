import QtQuick 2.0
import Sailfish.Silica 1.0

Page{
    id: aboutPage
    SilicaFlickable {
        id: flickerList
        anchors.fill: aboutPage
        contentHeight: content.height

        Column {
            id: content
            anchors {
               left: parent.left
               right: parent.right
               margins: Theme.paddingLarge
            }
            spacing: Theme.paddingMedium

            PageHeader {
                title: qsTrId('about')
                width: parent.width
            }

            Column {
                id: portrait
                width: parent.width

                Label {
                    text: qsTrId('made-by').arg('neversun')
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                SectionHeader {
                    text: qsTrId('source-code')
                }

                Label {
                    text: "github.com"
                    font.underline: true;
                    anchors.horizontalCenter: parent.horizontalCenter
                    MouseArea {
                        anchors.fill : parent
                        onClicked: Qt.openUrlExternally("https://github.com/neversun/bodyweight-timer")
                    }
                }

                SectionHeader {
                    text: qsTrId('icon')
                }

                Label {
                    //% "Made by %1"
                    text: qsTrId('made-by').arg('LinuCC')
                    font.underline: true;
                    anchors.horizontalCenter: parent.horizontalCenter
                    MouseArea {
                        anchors.fill : parent
                        onClicked: Qt.openUrlExternally("https://github.com/LinuCC")
                    }
                }

                SectionHeader {
                    text: qsTrId('credits')
                }

                Label {
                    wrapMode: TextEdit.WordWrap
                    textFormat: Text.RichText;
                    width: parent.width
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    onLinkActivated: {
                        Qt.openUrlExternally(link)
                    }
                    text:  "<style>a:link { color: " + Theme.primaryColor + "; }</style>" +
                           "<a href=\"http://www.freesound.org/people/Benboncan/sounds/66951/\">\"Boxing Bell\"</a> (modifications: 1. shortend length), made by <a href=\"http://www.freesound.org/people/Benboncan/\">Benboncan</a> under <a href=\"http://creativecommons.org/licenses/by/3.0/\">CC BY 3.0</a>)<p></p>"+
                           "<a href=\"http://www.freesound.org/people/Benboncan/sounds/66952/\">\"Boxing Bell\"</a> (modifications: 1. shortend length, 2. Remixed into double bell), made by <a href=\"http://www.freesound.org/people/Benboncan/\">Benboncan</a> under <a href=\"http://creativecommons.org/licenses/by/3.0/\">CC BY 3.0</a>)"
                }
            }
        }
    }
}
