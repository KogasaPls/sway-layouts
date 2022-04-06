# sway-layouts

A collection of (personal-use) scripts for arranging windows into predefined layouts in Sway.

## mpv.sh

Organizes mpv windows nicely, with one 1920x1080 window and 0-3 smaller windows on top. For use with a dedicated 2560x1440 media+chat monitor.
![mpv-demo](https://github.com/KogasaPls/sway-layouts/blob/main/screenshots/mpv-demo.png)

## runelite.sh

Positions 3 RuneLite clients in a suitable layout:
1 client: a single 1280x720 main window, centered
2 clients: TODO
3 clients: a 1280x720 main window with two 1024x576 alt windows and 1 placeholder terminal.
![runelite-demo](https://github.com/KogasaPls/sway-layouts/blob/main/screenshots/runelite-demo.png)

All windows (not including borders) are exactly 16:9 and divisible by 8 in both directions for optimal scaling.
The 3-client layout is designed for playing 1 main + 2 rune dragon alts with minimal cognitive/eye/wrist strain.
Assumes a 2560x1440 monitor with 1px borders and 30px bar tall bar at the top. Gaps are set at runtime to accomplish the correct size and position. For example, the 3-client window is set up like this:

```
### ~/.config/sway/config
...
 workspace 4 gaps inner 10
 workspace 4 gaps outer 10
 workspace 4 gaps left 239
 workspace 4 gaps right 239
 workspace 4 gaps top 40
 workspace 4 gaps bottom 40
```
