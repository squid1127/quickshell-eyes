import Quickshell
import Quickshell.Io
import QtQuick

ShellRoot {
    id: root
    property bool displayOn: true
    property string pendingAction: ""
    property int dpmsRequestId: 0
    property int pendingActionRequestId: -1
    property var pendingDpmsIpcRequests: []

    function nextDpmsRequestId(): int {
        root.dpmsRequestId += 1
        return root.dpmsRequestId
    }


    function open(): void {
        if (pendingAction === "open" || pendingAction === "checking-open" || (DisplayState.isOpen && pendingAction === ""))
            return

        console.log("display: open()")
        actionTimer.stop()
        pendingAction = ""

        pendingAction = "checking-open"
        root.pendingActionRequestId = root.nextDpmsRequestId()
        DPMSController.get(root.pendingActionRequestId)
    }

    function close(): void {
        if (pendingAction === "close" || pendingAction === "checking-close" || (!DisplayState.isOpen && pendingAction === ""))
            return

        console.log("display: close()")
        actionTimer.stop()
        DisplayState.isOpen = false
        pendingAction = ""

        pendingAction = "checking-close"
        root.pendingActionRequestId = root.nextDpmsRequestId()
        DPMSController.get(root.pendingActionRequestId)
    }

    Connections {
        target: DPMSController

        function onDpmsRead(requestId: int, dpmsOn: bool): void {
            const ipcRequestIndex = root.pendingDpmsIpcRequests.indexOf(requestId)
            if (ipcRequestIndex !== -1) {
                const pendingRequests = root.pendingDpmsIpcRequests.slice()
                pendingRequests.splice(ipcRequestIndex, 1)
                root.pendingDpmsIpcRequests = pendingRequests
                displayIpc.dpmsRead(dpmsOn)
                return
            }

            if (requestId !== root.pendingActionRequestId)
                return

            root.pendingActionRequestId = -1

            if (root.pendingAction === "checking-open") {
                if (!dpmsOn) {
                    DPMSController.set(true)
                    root.pendingAction = "open"
                    actionTimer.restart()
                } else {
                    root.pendingAction = ""
                    DisplayState.isOpen = true
                }
            } else if (root.pendingAction === "checking-close") {
                if (dpmsOn) {
                    root.pendingAction = "close"
                    actionTimer.restart()
                } else {
                    root.pendingAction = ""
                }
            } else if (root.pendingAction === "checking-close-timer") {
                if (dpmsOn)
                    DPMSController.set(false)
                root.pendingAction = ""
            }
        }
    }

    Timer {
        id: actionTimer
        interval: DisplayState.dpmsDelay

        onTriggered: {
            if (root.pendingAction === "open") {
                DisplayState.isOpen = true
                root.pendingAction = ""
            } else if (root.pendingAction === "close") {
                root.pendingAction = "checking-close-timer"
                root.pendingActionRequestId = root.nextDpmsRequestId()
                DPMSController.get(root.pendingActionRequestId)
            }
        }
    }

    IpcHandler {
        id: displayIpc
        target: "display"

        signal dpmsRead(bool dpmsOn)

        function open(): void { root.open() }
        function close(): void { root.close() }
        function toggle(): void {DisplayState.isOpen ? root.close() : root.open()}

        function getCloseTime(): int { return DisplayState.closeTime }
        function setCloseTime(value: int): void { DisplayState.closeTime = value }
        function getDpmsDelay(): int { return DisplayState.dpmsDelay }
        function setDpmsDelay(value: int): void { DisplayState.dpmsDelay = value }
        function isOpen(): bool { return DisplayState.isOpen }
        function isClosed(): bool { return !DisplayState.isOpen }


        function getDpms(): void {
            const requestId = root.nextDpmsRequestId()
            root.pendingDpmsIpcRequests = root.pendingDpmsIpcRequests.concat(requestId)
            DPMSController.get(requestId)
        }
    }

    
    Variants {
        model: Quickshell.screens
        Bars {

        }
    }
}