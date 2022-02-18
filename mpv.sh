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

#IFS=$'\n'
tree=$(swaymsg -t get_tree)
readarray wins < <(echo "$tree" | jq -r '.. | (.nodes? //empty)[] |  select(.pid and .visible) | "\(.pid) \(.app_id) \(.rect.x) \(.name)"')
for win in "${wins[@]}"; do
  win=($win) #convert to array
  pid="${win[0]}"
  app="${win[1]}"
  xpos="${win[2]}"
  name="${win[@]:3}"
  echo "$app ($pid) \"$name\""
  if [[ "$name" == "placeholder-foot*" ]]; then
    kill "$pid"
  elif [[ "$app" == "com.chatterino.https://www.chatterino" || "$name" == *"Chat - Destiny.gg"* ]]; then
    let "numChats=$numChats+1"
    swaymsg "[pid=$pid] mark --add \"chat$numChats\""
  elif [[ "$app" == "mpv" ]]; then
    let "numMpv=$numMpv+1"
    swaymsg "[pid=$pid] mark --add \"mpv$numMpv\""
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

# (to avoid swaymsg 'node not found' errors
# fallthrough until we run out of windows to move
case 1:${numMpv:--} in
1:*[!0-9]*)
  ! echo NAN
  exit
  ;;
$((numMpv > 0))*)
  swaymsg workspace 13
  # echo "Moving to workspace $target"
  swaymsg [con_mark="chat1"] move container to workspace $target

  swaymsg [con_mark="chat1"] splith
  swaymsg [con_mark="mpv1"] move container to mark chat1
  swaymsg [con_mark="mpv1"] swap container with mark chat1
  swaymsg [con_mark="chat1"] resize set width 640px
  ;;&
$((numMpv > 1))*)
  swaymsg [con_mark="mpv1"] splitv
  swaymsg [con_mark="mpv2"] move container to mark mpv1
  swaymsg [con_mark="mpv2"] swap container with mark mpv1
  swaymsg [con_mark="mpv1"] resize set width 1920px height 1080px
  ;;&
$((numMpv > 2))*)
  # Put win3 next to win2 so they're evenly split
  swaymsg [con_mark="mpv2"] splith
  swaymsg [con_mark="mpv3"] move container to mark mpv2
  swaymsg [con_mark="mpv3"] swap container with mark mpv2
  ;;&
$((numMpv > 3))*)
  # Put win4 next to win2 and win3 and then size them evenly
  swaymsg [con_mark="mpv3"] splith
  swaymsg [con_mark="mpv4"] move container to mark mpv3
  swaymsg [con_mark="mpv4"] swap container with mark mpv3
  swaymsg [con_mark="mpv2"] resize set width 640
  swaymsg [con_mark="mpv3"] resize set width 640
  swaymsg [con_mark="mpv4"] resize set width 640
  ;;
esac

if [[ "$numChats" == 2 ]]; then
  swaymsg [con_mark="chat2"] move container to workspace $target
  swaymsg [con_mark="chat1"] splitv
  swaymsg [con_mark="chat2"] move container to mark chat1
fi

swaymsg workspace $target
