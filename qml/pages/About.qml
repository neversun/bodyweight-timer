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
                textFormat: Text.RichText;
                width: parent.width
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeMedium
                onLinkActivated: {
                    Qt.openUrlExternally(link)
                }
                text:  "<style>a:link { color: " + Theme.highlightColor + "; }</style>" +
                       //   Github
                       "Please report issues or request features at <a href=\"https://github.com/neversun/bodyweight-timer\">Github</a> <p><p>" +
                       //   Icon credits
                       "Awesome icon made by <a href=\"https://github.com/LinuCC\">LinuCC</a> <p><p>"
            }

            Label {
                wrapMode: TextEdit.WordWrap
                textFormat: Text.RichText;
                width: parent.width
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeTiny
                onLinkActivated: {
                    Qt.openUrlExternally(link)
                }
                text:  "<style>a:link { color: " + Theme.highlightColor + "; }</style>" +
                       //   Sound credit
                       "The sounds:<br>" +
                       " <a href=\"http://www.freesound.org/people/Benboncan/sounds/66951/\">\"Boxing Bell\"</a> (modifications: shortend length), made by <a href=\"http://www.freesound.org/people/Benboncan/\">Benboncan</a> under <a href=\"http://creativecommons.org/licenses/by/3.0/\">CC BY 3.0</a> <br>"+
                       " <a href=\"http://www.freesound.org/people/Benboncan/sounds/66952/\">\"Boxing Bell\"</a> (modifications: shortend length), made by <a href=\"http://www.freesound.org/people/Benboncan/\">Benboncan</a> under <a href=\"http://creativecommons.org/licenses/by/3.0/\">CC BY 3.0</a> <br>"
            }
        }
    }
}
