# sway-layouts
A collection of (personal-use) scripts for arranging windows into predefined layouts in Sway.

## mpv.sh
![mpv-demo](https://github.com/KogasaPls/sway-layouts/blob/main/screenshots/mpv-demo.png)

For use with a dedicated 2560x1440 media+chat monitor. Organizes mpv windows nicely: 1x 1920x1080 window and 0-3 smaller windows on top. 

[image:

## runelite.sh
![runelite-demo](https://github.com/KogasaPls/sway-layouts/blob/main/screenshots/runelite-demo.png)

Positions 3 RuneLite clients into a 1280x720 main window with two 1024x576 alt windows.
All three windows are exactly 16:9 and divisible by 8 in both directions, for optimal scaling, and the layout is
designed for playing 1 main + 2 rune dragon alts with minimal cognitive/eye strain.
Only works on a 2560x1440 monitor with 1px borders, 30px bar, and the following very specific and irregular gaps:

Sway:
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

bspwm:
```
### ~/.config/bspwm/bspwmrc

 bspc config -d IV window_gap 10
 bspc config -d IV bottom_padding 40
 bspc config -d IV top_padding 40
 bspc config -d IV left_padding 239
 bspc config -d IV right_padding 239
```
Note: you must select a window ("rl0") before running this script. This window is placed next to the RuneLite clients.
