#!/bin/bash
# Positions 3 RuneLite clients into a 1280x720 main window with two 1024x576 alt windows.
# All three windows are exactly 16:9 and divisible by 8 in both directions, for optimal scaling, and the layout is
# designed for playing 1 main + 2 rune dragon alts with minimal cognitive/eye strain.
# Only works on a 2560x1440 monitor with 1px borders, 30px bar, and the following very specific and irregular gaps.
# SWAY:
# workspace 4 gaps inner 10
# workspace 4 gaps outer 10
# workspace 4 gaps left 239
# workspace 4 gaps right 239
# workspace 4 gaps top 40
# workspace 4 gaps bottom 40
# BSPWM:
# bspc config -d IV window_gap 10
# bspc config -d IV bottom_padding 40
# bspc config -d IV top_padding 40
# bspc config -d IV left_padding 239
# bspc config -d IV right_padding 239

# Note: you must select a window ("rl0") before running this script. This window is placed next to the RuneLite clients.

swaymsg unmark
swaymsg mark rl0

swaymsg [title="RuneLite.*Potapto"] mark rl1
swaymsg [title="RuneLite.*Maldemort"] mark rl2
swaymsg [title="RuneLite.*Potaptwo"] mark rl3

swaymsg [con_mark="rl0"] splitv

swaymsg [con_mark="rl2"] move to mark rl0
swaymsg [con_mark="rl2"] splith
swaymsg [con_mark="rl3"] move to mark rl2
swaymsg [con_mark="rl0"] splith
swaymsg [con_mark="rl1"] move to mark rl0
swaymsg [con_mark="rl1"] swap container with mark rl0

swaymsg [con_mark="rl1"] resize set width 1282px height 722px
swaymsg [con_mark="rl2"] resize set width 1026px height 578px
swaymsg [con_mark="rl3"] resize set width 1026px height 578px
