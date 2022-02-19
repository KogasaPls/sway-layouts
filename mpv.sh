#!/bin/bash
## Since rearranging is hard, we prefer to move everything from one workspace
## to a clean one. We use 11 and 12 for our mpv monitor.
swaymsg unmark
tree="$(swaymsg -t get_tree)"
if [ -z "$(echo $tree | grep '"current_workspace": "11",')" ]; then
  initial=12
  target=11
else
  initial=11
  target=12
fi

numMpv=0
numChats=0

# pass any argument to force-refresh the layout
if [ $1 ]; then
  sorted=false
else
  sorted=true
fi

numInvisWindows=0

readarray wins < <(swaymsg -t get_tree | jq -r '.. | (.nodes? //empty)[] |  select(.pid) | "\(.rect.x) \(.rect.y) \(.pid) \(.app_id) \(.visible) \(.name)"')
IFS=$'\n' sortedWins=($(sort -k1,1n -k2,2nr <<<"${wins[*]}"))
unset IFS
for win in "${sortedWins[@]}"; do
  win=($win) #convert to array
  xpos="${win[0]}"
  ypos="${win[1]}"
  pid="${win[2]}"
  app="${win[3]}"
  isVisible="${win[4]}"
  name="${win[@]:5}"
  echo "$app ($pid) at pos ("$xpos", "$ypos") \"$name\""
  if [[ "$app" == "com.chatterino.https://www.chatterino" || "$name" == *"Chat - Destiny.gg"* ]]; then
    let "numChats=$numChats+1"
    swaymsg "[pid=$pid] mark --add \"chat$numChats\""
    if [[ "$xpos" != 1920 ]]; then
      echo "not sorted: $name"
      sorted=false
    fi
  elif [[ "$app" == "mpv" || $xpos < 2560 ]]; then
    echo "MPV FOUND: $name"
    let "numMpv=$numMpv+1"
    swaymsg "[pid=$pid] mark --add \"mpv$numMpv\""
    if [[ "$isVisible" == "false" ]]; then
      echo "$name is not visible"
      let "numInvisWindows=$numInvisWindows+1"
    else
      case "$xpos,$ypos" in
      "0,0" | "640,0" | "1280,0" | "960,0" | "0,360") ;;

      *)
        echo "not sorted: $name"
        sorted=false
        ;;
      esac
    fi
    #  elif [[ "$name" == "placeholder-foot*" ]]; then
    #    kill "$pid"
  fi
done

##TODO: make sense if there's no MPV's or no chats
if false; then
  if [[ "$numMpv" == 0 ]] && [[ "$numChats" -gt 0 ]]; then
    numLoops=0
    nohup 'foot -T "placeholder-foot-mpv"'
    swaymsg '[title="placeholder-foot"] mark --add chat1'
    numMpv=1
  elif [[ "$numChats" == 0 ]] && [[ "$numMpv" -gt 0 ]]; then
    numLoops=0
    nohup 'foot -T "placeholder-foot-chat"'
    swaymsg '[title="placeholder-foot-chat"] mark --add chat1'
    numChats=1
  fi
fi

move() {
  case $1 in
  0)
    #swaymsg workspace 13 # switch to a blank workspace while everything is moved around
    swaymsg [con_mark="chat1"] move container to workspace $target
    ;;
  1)
    swaymsg [con_mark="chat1"] splith
    swaymsg [con_mark="mpv1"] move container to mark chat1
    swaymsg [con_mark="mpv1"] swap container with mark chat1
    swaymsg [con_mark="chat1"] resize set width 640px
    ;;
  2)
    swaymsg [con_mark="mpv1"] splitv
    swaymsg [con_mark="mpv2"] move container to mark mpv1
    swaymsg [con_mark="mpv2"] swap container with mark mpv1
    swaymsg [con_mark="mpv1"] resize set width 1920px height 1080px
    ;;
  3)
    # Put win3 next to win2 so they're evenly split
    swaymsg [con_mark="mpv2"] splith
    swaymsg [con_mark="mpv3"] move container to mark mpv2
    ;;
  4)
    # Put win4 next to win2 and win3 and then size them evenly
    swaymsg [con_mark="mpv3"] splith
    swaymsg [con_mark="mpv4"] move container to mark mpv3
    swaymsg [con_mark="mpv2"] resize set width 640px
    swaymsg [con_mark="mpv3"] resize set width 640px
    swaymsg [con_mark="mpv4"] resize set width 640px
    ;;
  esac
}

if [[ "$sorted" == true && "$numInvisWindows" == 0 ]]; then
  # already sorted, just move the new window in place
  echo "sorted and no invisible windows"
  exit
elif [[ "$sorted" == true && "$numInvisWindows" > 0 ]]; then
  echo "sorted and some invisible windows"
  let start="$numMpv - $numInvisWindows + 1"
  for ((n = $start; n <= $numMpv; n++)); do
    move "$n"
  done
else
  # move everything to a new workspace and arrange it from scratch
  echo "not sorted"
  swaymsg workspace 13 #switch to blank workspace while moving stuff
  for ((n = 0; n <= $numMpv; n++)); do
    move "$n"
  done
  if [[ "$numChats" == 2 ]]; then
    swaymsg [con_mark="chat1"] splitv
    swaymsg [con_mark="chat2"] move container to mark chat1
    swaymsg [con_mark="chat2"] swap container with mark chat1
  fi
  swaymsg workspace $target
fi
