#! /bin/sh
OLD="$(yabai -m query --spaces --space | "${jq}" '.index')"
yabai -m window --close
NEW="$(yabai -m query --spaces --space | "${jq}" '.index')"
if ! [ "$OLD" = "$NEW" ]
  then yabai -m space --focus "$OLD"
fi
