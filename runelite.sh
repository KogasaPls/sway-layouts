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

swaymsg unmark

numWins=0
placeholderExists=false

tree="$(swaymsg -t get_tree)"
readarray wins < <(echo $tree | jq -r '.. | (.nodes? //empty)[] |  select(.pid) | "\(.rect.y) \(.rect.x) \(.rect.width) \(.rect.height) \(.pid) \(.app_id) \(.visible) \(.name)"')
IFS=$'\n' resizeOnlyWins=($(sort -k1,1n -k2,2n <<<"${wins[*]}"))
unset IFS

users=()
xs=()
ys=()
ws=()
hs=()

for win in "${resizeOnlyWins[@]}"; do
  win=($win) #convert to array
  xpos="${win[1]}"
  ypos="${win[0]}"
  width="${win[2]}"
  height="${win[3]}"
  pid="${win[4]}"
  app="${win[5]}"
  isVisible="${win[6]}"
  name="${win[@]:7}"
  case "$name" in
  "RuneLite"*)
    echo "$name ($pid) at pos ($xpos, $ypos)"
    let numWins="$numWins + 1"
    swaymsg [pid=$pid] mark "rl$numWins"
    users+=("${name:11}")
    xs+=("$xpos")
    ys+=("$ypos")
    ws+=("$width")
    hs+=("$height")
    ;;
  esac
  if [[ "$app" == "rl-placeholder" ]]; then
    #    echo "Placeholder found ($pid)"
    swaymsg [app_id="rl-placeholder"] mark "rl0"
    placeholderExists=true
  fi
done

case $numWins in
1)
  # setup workspace for 1 1280x720 window, centered-ish
  swaymsg [workspace=4] gaps left current set 629
  swaymsg [workspace=4] gaps right current set 629
  swaymsg [workspace=4] gaps top current set 319
  swaymsg [workspace=4] gaps bottom current set 349
  swaymsg [app_id="rl-notification.py" title="${users[0]}"] move absolute position 3200 360
  ;;

2) ;; # todo

3)
  # setup workspace for 3 windows, 1 big + 2 small
  swaymsg [workspace=4] gaps left current set 239
  swaymsg [workspace=4] gaps right current set 239
  swaymsg [workspace=4] gaps top current set 40
  swaymsg [workspace=4] gaps bottom current set 40
  # check if windows just need to be resized
  if [[ "${xs[0]}" != 2809 || "${xs[1]}" != 2809 ]] || (("${xs[2]}" != "${xs[1]}" + "${ws[1]}" + 10)) || (("${ys[1]}" != "${ys[0]}" + "${hs[0]}" + 10)); then
    resizeOnly=false
  fi

  if [[ $resizeOnly == false ]]; then
    if [ $placeholderExists == false ]; then
      nohup footclient --app-id "rl-placeholder" &
      sleep 0.2
      swaymsg [app_id="rl-placeholder"] mark "rl0"
    fi
    swaymsg [workspace=4] move to workspace 5
    swaymsg [con_mark="rl0"] move to workspace 4

    swaymsg [con_mark="rl0"] splitv
    swaymsg [con_mark="rl2"] move to mark rl0
    swaymsg [con_mark="rl2"] splith
    swaymsg [con_mark="rl3"] move to mark rl2
    swaymsg [con_mark="rl0"] splith
    swaymsg [con_mark="rl1"] move to mark rl0
    swaymsg [con_mark="rl1"] swap container with mark rl0
  fi

  swaymsg [con_mark="rl1"] resize set width 1282px height 722px
  swaymsg [con_mark="rl2"] resize set width 1026px height 578px
  swaymsg [con_mark="rl3"] resize set width 1026px height 578px

  if ! [ -z "${users[0]}" ]; then
    swaymsg [app_id="rl-notification.py" title="${users[0]}"] move absolute position 2810 81
  fi
  if ! [ -z "${users[1]}" ]; then
    swaymsg [app_id="rl-notification.py" title="${users[1]}"] move absolute position 2810 813
  fi
  if ! [ -z "${users[2]}" ]; then
    swaymsg [app_id="rl-notification.py" title="${users[2]}"] move absolute position 3846 813
  fi
  ;;
esac
