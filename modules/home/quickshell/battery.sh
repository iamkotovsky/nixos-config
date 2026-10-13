#!/usr/bin/env bash
# Emits {"cap":<percent>,"charging":true|false} for the Battery applet.
# cap is -1 when no battery is present.
set -euo pipefail

cap=-1
charging=false
for b in /sys/class/power_supply/BAT*; do
  [ -d "$b" ] || continue
  c=$(cat "$b/capacity" 2>/dev/null) || continue
  s=$(cat "$b/status" 2>/dev/null)
  cap=$c
  if [ "$s" = "Charging" ]; then charging=true; fi
done

jq -n --argjson cap "$cap" --argjson charging "$charging" \
  '{cap:$cap,charging:$charging}'