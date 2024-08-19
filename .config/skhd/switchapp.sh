#!/bin/sh

selected=$(yabai -m query --windows | jq -r '.[] | "\(.pid)|\(.id)|\(.app)"' | choose)

if [ -n "$selected" ]; then
    window_id=$(echo $selected | cut -d'|' -f2)
    yabai -m window --focus $window_id
fi
