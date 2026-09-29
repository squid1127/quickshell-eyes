import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    required property var modelData
    screen: modelData

    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "eyes"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: DisplayState.isOpen ? WlrKeyboardFocus.None : WlrKeyboardFocus.Exclusive
    mask: DisplayState.isOpen ? passThroughMask : null

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    Item {
        id: panelContent

        anchors.fill: parent
        focus: !DisplayState.isOpen
        Keys.onPressed: (event) => {
            root.open();
            event.accepted = true;
        }

        MouseArea {
            property real previousX: 0
            property real previousY: 0
            property bool hasPreviousPosition: false

            anchors.fill: parent
            enabled: !DisplayState.isOpen
            hoverEnabled: true
            acceptedButtons: Qt.AllButtons
            onClicked: root.open()
            onEntered: {
                previousX = mouseX;
                previousY = mouseY;
                hasPreviousPosition = true;
            }
            onPositionChanged: {
                if (hasPreviousPosition && (mouseX !== previousX || mouseY !== previousY))
                    root.open();

                previousX = mouseX;
                previousY = mouseY;
                hasPreviousPosition = true;
            }
        }

        Rectangle {
            height: (parent.height / 2) * (!DisplayState.isOpen)
            color: "black"

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            Behavior on height {
                SmoothedAnimation {
                    velocity: 1
                    duration: DisplayState.closeTime
                }

            }

        }

        Rectangle {
            height: (parent.height / 2) * (!DisplayState.isOpen)
            color: "black"

            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }

            Behavior on height {
                SmoothedAnimation {
                    velocity: 1
                    duration: DisplayState.closeTime
                }

            }

        }

    }

    Region {
        id: passThroughMask

        item: panelContent
        intersection: Intersection.Xor
    }

}
