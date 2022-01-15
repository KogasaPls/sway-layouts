#!/bin/bash
tree="$(swaymsg -t get_tree)"

## Since rearranging is hard, we prefer to move everything from one workspace
## to a clean one. We use 11 and 12 for our mpv monitor.
if [ -z "$(echo $tree | grep '"current_workspace": "11",')" ]; then
  sourceWS=12
  targetWS=11
else
  sourceWS=11
  targetWS=12
fi

numWins="$(echo "$tree" | grep '"app_id": "mpv"' -c)" #number of mpv clients

swaymsg unmark
swaymsg [app_id="chatterino"] mark chat                         #top chat
swaymsg [app_id="firefox" title=".*Chat.*Destiny\.gg"] mark dgg #bottom chat

swaymsg [con_mark="chat"] move container to workspace "$targetWS"
if (("$numWins" == 0)); then #if there's no mpv windows to position, use something... WTB placeholders pls
  #  swaymsg [workspace=$sourceWS] mark win1 ##will un-tag dgg or chat
  swaymsg [workspace=$sourceWS app_id="foot"] mark win1
else
  swaymsg [workspace="$sourceWS" app_id="mpv"] mark win1
fi
# Put win1 to the left of chat(s) with width 1920px
swaymsg [con_mark="chat"] splith
swaymsg [con_mark="win1"] move to mark chat
swaymsg [con_mark="win1"] swap container with mark chat
swaymsg [con_mark="chat"] resize set width 640px
swaymsg [con_mark="chat"] splitv
swaymsg [con_mark="dgg"] move container to mark chat

if (("$numWins" <= 1)); then
  swaymsg workspace "$targetWS"
  exit
fi

# Put win2 above win1, so that win1 has size 1920x1080
swaymsg [workspace="$sourceWS" app_id="mpv"] mark win2
swaymsg [con_mark="win1"] splitv
swaymsg [con_mark="win2"] move to mark win1
swaymsg [con_mark="win2"] swap container with mark win1
swaymsg [con_mark="win1"] resize set width 1920px height 1080px

if (("$numWins" == 2)); then
  swaymsg workspace "$targetWS"
  exit
fi

# Put win3 next to win2 so they're evenly split
swaymsg [workspace="$sourceWS" app_id="mpv"] mark win3
swaymsg [con_mark="win2"] splith
swaymsg [con_mark="win3"] move to mark win2
swaymsg [con_mark="win3"] swap container with mark win2

if (("$numWins" == 3)); then
  swaymsg workspace "$targetWS"
  exit
fi

# Put win4 next to win2 and win3 and then size them evenly
swaymsg [workspace="$sourceWS" app_id="mpv"] mark win4
swaymsg [con_mark="win3"] splith
swaymsg [con_mark="win4"] move to mark win3
swaymsg [con_mark="win4"] swap container with mark win3
swaymsg [con_mark="win2"] resize set width 640
swaymsg [con_mark="win3"] resize set width 640
swaymsg [con_mark="win4"] resize set width 640

swaymsg workspace "$targetWS"
