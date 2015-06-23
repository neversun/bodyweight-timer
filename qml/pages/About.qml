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
                title: "About"
                width: parent.width
            }


            Label {
                wrapMode: TextEdit.WordWrap
                text: "Please report issues or request features at Github"
                width: parent.width
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeSmall
            }

            Button {
                highlightColor: Theme.highlightColor
                text: "Open Github"
                onClicked: {
                    Qt.openUrlExternally("https://github.com/neversun/bodyweight-timer")
                }
                width: parent.width/2
                height: Theme.itemSizeMedium
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Label {
                wrapMode: TextEdit.WordWrap
                text: "\nThe sounds \"Boxing Bell\" (modifications: shortend length), made by Benboncan under CC BY 3.0 at: \nhttp://www.freesound.org/people/Benboncan/sounds/66951/ \nhttp://www.freesound.org/people/Benboncan/sounds/66952/ \n"
                width: parent.width
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.highlightColor
            }
        }
    }
}
