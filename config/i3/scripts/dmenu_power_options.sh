#!/bin/bash

# my custom dmenu power options
#echo -e "poweroff\nreboot\nsuspend" | $HOME/.config/i3/scripts/my_dmenu.sh -p "Power Options:" | xargs systemctl

choice=`echo -e "0: Logout\n1: Shutdown\n2: Suspend\n3: Reboot\n4: Cancel" | $HOME/.config/i3/scripts/my_dmenu.sh -p "Power Options:" | cut -d ':' -f 1`

# execute the choice in background
case "$choice" in
  #0) i3-msg exit & ;;
  0) i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -B 'Yes, exit i3' 'i3-msg exit' & ;;
  1) systemctl poweroff & ;;
  2) systemctl suspend & ;;
  3) systemctl reboot & ;;
  4) exit ;;
esac