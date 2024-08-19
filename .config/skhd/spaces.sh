#!/bin/sh

space_number=$1
action=$2  # 'focus' or 'move'
current_spaces=$(yabai -m query --spaces | jq 'length')

if [ $space_number -gt $current_spaces ]; then
    # Create new spaces until we have enough
    for ((i=current_spaces+1; i<=space_number; i++)); do
        yabai -m space --create
    done
fi

if [ "$action" = "focus" ]; then
    # Focus the space
    yabai -m space --focus $space_number
elif [ "$action" = "move" ]; then
    yabai -m window --space $space_number
fi
