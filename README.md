# quickshell-eyes

Quickshell overlay for Hyprland that animates the display into and out of a screen-off state. The overlay responds to pointer and keyboard activity, and uses Hyprland DPMS to turn the display off after the close delay.

The `display` IPC target controls the overlay and exposes its state:

```sh
qs ipc call display open
qs ipc call display close
qs ipc call display toggle

qs ipc call display isOpen
qs ipc call display isClosed
qs ipc call display getCloseTime
qs ipc call display setCloseTime 4000
qs ipc call display getDpmsDelay
qs ipc call display setDpmsDelay 5500
```

`closeTime` controls the overlay animation duration in milliseconds. `dpmsDelay` controls how long the display remains in the closing transition before DPMS is disabled. The open state is changed with `open`, `close`, and `toggle`.

DPMS status is refreshed asynchronously. Start waiting for the signal before requesting the value, for example in separate terminals:

```sh
qs ipc wait display dpmsRead
```

```sh
qs ipc call display getDpms
```

The `dpmsRead` signal emits `true` when DPMS is on and `false` when it is off. DPMS control requires Quickshell's Lua-backed Hyprland integration.
