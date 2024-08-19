#!/bin/sh

selected=$(yabai -m query --windows | jq -r '.[] | "\(.pid)|\(.id)|\(.app)"' | choose)

if [ -n "$selected" ]; then
    pid=$(echo $selected | cut -d'|' -f1)
    kill $pid 
fi
