#!/bin/bash
tree="$(swaymsg -t get_tree)"

if [ -z "$(echo $tree | grep '"current_workspace": "11",')" ]; then
  sourceWS=12
  targetWS=11
else
  sourceWS=11
  targetWS=12
fi

numWins="$(echo "$tree" | grep '"app_id": "mpv"' -c)"

swaymsg unmark
swaymsg [app_id="chatterino"] mark chat
swaymsg [app_id="firefox" title=".*Chat.*Destiny\.gg"] mark dgg
swaymsg [con_mark="chat"] move container to workspace "$targetWS"
if (("$numWins" == 0)); then #if there's no mpv windows to position, use something...
  swaymsg [workspace=$sourceWS] mark win1
else
  swaymsg [workspace="$sourceWS" app_id="mpv"] mark win1
fi
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

swaymsg [workspace="$sourceWS" app_id="mpv"] mark win2
swaymsg [con_mark="win1"] splitv
swaymsg [con_mark="win2"] move to mark win1
swaymsg [con_mark="win2"] swap container with mark win1
swaymsg [con_mark="win1"] resize set width 1920px height 1080px

if (("$numWins" == 2)); then
  swaymsg workspace "$targetWS"
  exit
fi

swaymsg [workspace="$sourceWS" app_id="mpv"] mark win3
swaymsg [con_mark="win2"] splith
swaymsg [con_mark="win3"] move to mark win2
swaymsg [con_mark="win3"] swap container with mark win2

if (("$numWins" == 3)); then
  swaymsg workspace "$targetWS"
  exit
fi

swaymsg [workspace="$sourceWS" app_id="mpv"] mark win4
swaymsg [con_mark="win3"] splith
swaymsg [con_mark="win4"] move to mark win3
swaymsg [con_mark="win4"] swap container with mark win3
swaymsg [con_mark="win2"] resize set width 640
swaymsg [con_mark="win3"] resize set width 640
swaymsg [con_mark="win4"] resize set width 640

swaymsg workspace "$targetWS"
