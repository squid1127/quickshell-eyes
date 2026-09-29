import Quickshell
import Quickshell.Hyprland
pragma Singleton

Singleton {
    signal dpmsRead(int requestId, bool dpmsOn)

    function set(to: bool): void { 
        if (Hyprland === null) {
            console.error("Cannot set DPMS; hyprland doesn't exist");
            return true;
        }

        if (!Hyprland.usingLua ) {
            console.error("Cannot set DPMS; this requires lua-backed hyprland");
            return true;
        }    

        const dispatch = "hl.dsp.dpms({ action = " + (to ? "enable" : "disable") + " })";
        
        console.log("set: " + to + ", " + dispatch);

        Hyprland.dispatch(dispatch)
    } 


    function get(requestId: int): void {
        if (Hyprland === null) {
            console.error("Cannot get DPMS; hyprland doesn't exist");
            dpmsRead(requestId, true);
            return;
        }

        const monitor = Hyprland.focusedMonitor;
        if (monitor === null) {
            console.error("Cannot get DPMS; no real monitor detected");
            dpmsRead(requestId, true);
            return;
        }

        const readUpdatedMonitor = function(): void {
            monitor.lastIpcObjectChanged.disconnect(readUpdatedMonitor);
            const dpms = monitor.lastIpcObject.dpmsStatus;
            console.log("get: " + dpms);
            dpmsRead(requestId, dpms);
        };

        monitor.lastIpcObjectChanged.connect(readUpdatedMonitor);
        Hyprland.refreshMonitors();
    } 
}
