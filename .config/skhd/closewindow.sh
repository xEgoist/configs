#! /bin/sh
OLD="$(yabai -m query --spaces --space | "${jq}" '.index')"
yabai -m window --close
NEW="$(yabai -m query --spaces --space | "${jq}" '.index')"
if ! [ "$OLD" = "$NEW" ]
  then yabai -m space --focus "$OLD"
fi

if ! $(yabai -m query --windows --window); then
    # If no window is focused, focus on any window in the current space, this prevents something like safari from stealing the focus
    SPACE_WINDOWS=$(yabai -m query --windows --space)
    FIRST_WINDOW=$(echo "$SPACE_WINDOWS" | jq '.[0].id')

    if [ "$FIRST_WINDOW" != "null" ]; then
        yabai -m window --focus "$FIRST_WINDOW"
    fi

fi
