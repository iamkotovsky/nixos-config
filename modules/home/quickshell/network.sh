#!/usr/bin/env bash
# Emits a small JSON blob for the Network QML applet.
#   {"state":"disconnected"}
#   {"state":"wifi","device":"wlo1","ssid":"FRITZ","ip":"192.168.1.5","signal":"72"}
#   {"state":"ethernet","device":"enp0s","ip":"192.168.1.6"}
# Deliberately not `set -e`: a dead pipeline head must not kill the script and
# make Quickshell parse an empty/partial stdout.
set -uo pipefail

line=""
while IFS=: read -r dev type state conn; do
  case "$state" in
    connected)
      case "$type" in
        wifi|ethernet) line="$dev:$type:$conn"; break ;;
      esac ;;
  esac
done < <(nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device status 2>/dev/null || true)

if [ -z "$line" ]; then
  jq -n '{state:"disconnected"}'
  exit 0
fi

dev=${line%%:*}
rest=${line#*:}
type=${rest%%:*}
conn=${rest#*:}

ip=$(ip -4 -o addr show dev "$dev" 2>/dev/null | awk '/inet /{print $4; exit}')
ip=${ip%%/*}

if [ "$type" = "wifi" ]; then
  sig=$(nmcli -t --rescan no -f IN-USE,SSID,SIGNAL device wifi list 2>/dev/null | awk -F: '$1=="*"{print $3; exit}')
  jq -n --arg dev "$dev" --arg ssid "$conn" --arg ip "$ip" --arg sig "${sig:-0}" \
    '{state:"wifi",device:$dev,ssid:$ssid,ip:$ip,signal:$sig}'
else
  jq -n --arg dev "$dev" --arg ip "$ip" \
    '{state:"ethernet",device:$dev,ip:$ip}'
fi