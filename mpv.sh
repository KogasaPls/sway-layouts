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

readarray wins < <(echo $tree | jq -r '.. | (.nodes? //empty)[] |  select(.pid) | "\(.rect.x) \(.rect.y) \(.rect.width) \(.rect.height) \(.pid) \(.app_id) \(.visible) \(.name)"')
IFS=$'\n' sortedWins=($(sort -k1,1n -k2,2nr <<<"${wins[*]}"))
unset IFS
for win in "${sortedWins[@]}"; do
  win=($win) #convert to array
  xpos="${win[0]}"
  ypos="${win[1]}"
  width="${win[2]}"
  height="${win[3]}"
  pid="${win[4]}"
  app="${win[5]}"
  isVisible="${win[6]}"
  name="${win[@]:7}"
  #echo "$app ($pid) at pos ("$xpos", "$ypos") with size ("$width", "$height") \"$name\""
  if [[ "$app" == "com.chatterino.https://www.chatterino" || "$name" == *"Chat - Destiny.gg"* ]]; then
    let "numChats=$numChats+1"
    swaymsg "[pid=$pid] mark --add \"chat$numChats\""
    if [[ "$xpos" != 1920 ]]; then
      #      echo "not sorted: $name"
      sorted=false
    fi
  elif [[ "$app" == "mpv" ]] || (("xpos" < 2560)); then
    let "numMpv=$numMpv+1"
    #    echo "mpv$numMpv : $name"
    swaymsg "[pid=$pid] mark --add \"mpv$numMpv\""
    if [[ "$isVisible" == "false" ]]; then
      #      echo "$name is not visible"
      xywh="$xpos,$ypos,$width,$height"
      #      echo "invisible: $name at xywh $xywh"
      let "numInvisWindows=$numInvisWindows+1"
    else
      configurations="0,0,1920,1440, 0,0,1920,360 0,0,960,360 0,0,640,360 1280,0,640,360 640,0,640,360 1280,0,640,360 0,360,1920,1080 960,0,960,360"
      xywh="$xpos,$ypos,$width,$height"
      if echo $configurations | grep -w $xywh >/dev/null; then
        #        echo "sorted: $name has xywh $xywh"
        continue
      else
        #        echo "not sorted: $name has xywh $xywh"
        sorted=false
      fi
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
  1)
    swaymsg [con_mark="chat1"] splith
    swaymsg [con_mark="mpv1"] move container to mark chat1
    swaymsg [con_mark="mpv1"] swap container with mark chat1
    ;;
  2)
    swaymsg [con_mark="mpv1"] splitv
    swaymsg [con_mark="mpv2"] move container to mark mpv1
    swaymsg [con_mark="mpv2"] swap container with mark mpv1
    ;;
  [3-6])
    # Put the remaining mpv windows in a top bar, sharing space evenly
    let "i=$1-1"
    oldWin="mpv$i"
    newWin="mpv$1"
    swaymsg [con_mark=$oldWin] splith
    swaymsg [con_mark=$newWin] move container to mark $oldWin
    ;;
  esac
}

resize() {
  case $1 in
  1)
    swaymsg [con_mark="mpv1"] resize set width 1920px
    ;;
  2)
    swaymsg [con_mark="mpv1"] resize set width 1920px height 1080px
    ;;
  [3-6])
    let "width=1920/($n-1)"
    for ((j = 2; j <= $1; j++)); do
      swaymsg [con_mark=mpv$j] resize set width "$width"px
    done
    ;;
  esac
}

if [[ "$sorted" == true && "$numInvisWindows" == 0 ]]; then
  exit
elif [[ "$sorted" == true && "$numInvisWindows" > 0 ]]; then
  let start="$numMpv - $numInvisWindows + 1"
  for ((n = $start; n <= $numMpv; n++)); do
    move "$n"
    resize "$n"
  done
else
  # move everything to a new workspace and arrange it from scratch
  swaymsg workspace 13 #switch to blank workspace while moving stuff
  swaymsg [con_mark="chat1"] move container to workspace $target
  echo $numMpv
  for ((n = 1; n <= $numMpv; n++)); do
    move "$n"
    resize "$n"
  done
  if [[ "$numChats" == 2 ]]; then
    swaymsg [con_mark="chat1"] splitv
    swaymsg [con_mark="chat2"] move container to mark chat1
    swaymsg [con_mark="chat2"] swap container with mark chat1
  fi
  swaymsg workspace $target
fi
