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
                title: qsTr('about')
                width: parent.width
            }

            Column {
                id: portrait
                width: parent.width

                Label {
                    text: qsTr('made by %1').arg('neversun')
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                SectionHeader {
                    text: qsTr('source code')
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
                    text: qsTr('icon')
                }

                Label {
                    text: qsTr('made by %1').arg('LinuCC')
                    font.underline: true;
                    anchors.horizontalCenter: parent.horizontalCenter
                    MouseArea {
                        anchors.fill : parent
                        onClicked: Qt.openUrlExternally("https://github.com/LinuCC")
                    }
                }

                SectionHeader {
                    text: qsTr('credits')
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
