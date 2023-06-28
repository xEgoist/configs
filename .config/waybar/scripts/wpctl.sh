#! /bin/sh

TEXT=""
while [[ -z "$TEXT"  ]]; do
  TEXT=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -Eo "MUTED|[0-9]\.[0-9]*" | tail -1 | awk '{print($1 == "MUTED" ? "🔇" : $1 * 100"% 🔊")}')
  TOOLTIP=$(wpctl inspect @DEFAULT_AUDIO_SINK@ | grep  "node.nick" | cut -d "=" -f2 | tr -d "\"")
  # BUGFIX: Since Wireplumber doesn't wait at boot for initialization, we need to wait manually here.
  # Maybe it will be fixed in the future.
done


printf "%s\nDevice:%s\n\n" "${TEXT}" "${TOOLTIP}"
