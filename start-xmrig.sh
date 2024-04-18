#!/usr/bin/env bash

# XMRig launcher script
# Made by Jiab77
#
# Version 0.2.0

# Options
[[ -r $HOME/.debug ]] && set -o xtrace || set +o xtrace

# Config
CLEAR_SCREEN=false
LIMIT_ON_BATTERY=true
ENABLE_OPENCL=true
SLOW_MODE=false
SLOW_MODE_THRES=4G
MIN_BAT_LEVEL=20
MIN_DEV_TEMP=30
MAX_DEV_TEMP=40
SLEEP_DELAY=5

# Internals
BIN_XMRIG=~/xmrig/build/xmrig
BIN_AWK=$(command -v awk 2>/dev/null)
SLOW_MODE_THRES_CLEAN="${SLOW_MODE_THRES//G/}"
SLOW_MODE_RAM_SIZE=$((SLOW_MODE_THRES_CLEAN*1024*1024))
DEVICE_MEM_SIZE=$(grep MemTotal /proc/meminfo | awk '{ print $2 }')
POOL_HOST="localhost"
RIG_ID="$(hostname)"
KEEP_MINING=false
MINER_STARTED=false
OVER_HEATING=false
IS_CHARGING=false
OPT_ARGS=

# Functions
function die() {
  echo -e "\nError: $*\n" >&2
  exit 255
}
function print_usage() {
  echo -e "\nUsage: $(basename "$0") [flags] -- Start XMRig optimized for your device"
  echo -e "\nFlags:"
  echo -e "  -h | --help\tPrint this message and exit"
  echo -e "  -b | --bin\tUse given XMRig binary path"
  echo -e "  -c | --config\tUse given config file"
  echo -e "  -r | --remote-pool\tUse given remote P2Pool host"
  echo -e "  --min-temp\tMinimal temperature to start mining"
  echo -e "  --max-temp\tMaximal temperature to stop mining"
  echo
  exit
}
function load_config() {
  if [[ -r "$1" ]]; then
    source "$1"
  else
    die "Could not read given config file."
  fi
}
function get_device_temp() {
  if [[ $(printenv | grep -ci android) -ne 0 && $(printenv | grep -ci termux) -ne 0 ]]; then
    if [[ -n $(command -v termux-battery-status 2>/dev/null) && -n $(command -v jq 2>/dev/null) ]]; then
      termux-battery-status | jq -rc .temperature | cut -d"." -f1
    fi
  else
    for T in $(cat /sys/class/thermal/thermal_zone*/temp); do
        echo $((T/1000))
    done | sort -nr | head -n1
  fi
}
function get_battery_level() {
  if [[ $(printenv | grep -ci android) -ne 0 && $(printenv | grep -ci termux) -ne 0 ]]; then
    if [[ -n $(command -v termux-battery-status 2>/dev/null) && -n $(command -v jq 2>/dev/null) ]]; then
      termux-battery-status | jq -rc .percentage
    fi
  else
    [[ -r /sys/class/power_supply/BAT0/capacity ]] && cat /sys/class/power_supply/BAT0/capacity 2>/dev/null
    [[ -r /sys/class/power_supply/BAT1/capacity ]] && cat /sys/class/power_supply/BAT1/capacity 2>/dev/null
  fi
}
function get_device_status() {
  if [[ $(printenv | grep -ci android) -ne 0 && $(printenv | grep -ci termux) -ne 0 ]]; then
    if [[ -n $(command -v termux-battery-status 2>/dev/null) && -n $(command -v jq 2>/dev/null) ]]; then
      local PWR_SOURCE ; PWR_SOURCE=$(termux-battery-status | jq -rc .plugged)
      local PWR_STATUS ; PWR_STATUS=$(termux-battery-status | jq -rc .status) ; PWR_STATUS="${PWR_STATUS// /-}"
      local PWR_DATA=(
        "${PWR_SOURCE,,}"
        "${PWR_STATUS,,}"
      )
      echo ${PWR_DATA[@]}
    fi
  else
    local PWR_ONLINE
    local PWR_SOURCE
    local PWR_STATUS
    local PWR_DATA

    [[ -r /sys/class/power_supply/AC0/uevent ]] && PWR_ONLINE=$(grep -m1 -i online /sys/class/power_supply/AC0/uevent | cut -d"=" -f2)
    [[ -r /sys/class/power_supply/ADP1/uevent ]] && PWR_ONLINE=$(grep -m1 -i online /sys/class/power_supply/ADP1/uevent | cut -d"=" -f2)
    [[ -r /sys/class/power_supply/BAT0/uevent ]] && PWR_STATUS=$(grep -m1 -i status /sys/class/power_supply/BAT0/uevent | cut -d"=" -f2)
    [[ -r /sys/class/power_supply/BAT1/uevent ]] && PWR_STATUS=$(grep -m1 -i status /sys/class/power_supply/BAT1/uevent | cut -d"=" -f2)

    [[ $PWR_ONLINE -eq 1 ]] && PWR_SOURCE="plugged" || PWR_SOURCE="unplugged"
    PWR_STATUS="${PWR_STATUS// /-}" ; PWR_STATUS="${PWR_STATUS,,}"
    PWR_DATA=(
      "$PWR_SOURCE"
      "$PWR_STATUS"
    )
    echo ${PWR_DATA[@]}
  fi
}
function get_opencl_platform() {
  $BIN_XMRIG --print-platforms | grep -m1 -i $1 -B3 | grep -i index | awk '{ print $2 }'
}
function kill_miner() {
  pkill xmrig
}
function start_miner() {
  if [[ $LIMIT_ON_BATTERY == false ]]; then
    $BIN_XMRIG \
      -o "${POOL_HOST}:3333" \
      --rig-id="$RIG_ID" \
      --print-time=5 \
      --health-print-time=10 \
      $OPT_ARGS
  else
    $BIN_XMRIG \
      -o "${POOL_HOST}:3333" \
      --rig-id="$RIG_ID" \
      --print-time=5 \
      --health-print-time=10 \
      --pause-on-battery \
      --pause-on-active=10 \
      $OPT_ARGS
  fi
}

# Flags
while [[ $# -ne 0 ]]; do
  case $1 in
    "-h"|"--help") print_usage ;;
    "-b"|"--bin") shift && BIN_XMRIG="$1" && shift ;;
    "-c"|"--config") shift && load_config "$1" && shift ;;
    "-r"|"--remote-pool") shift && POOL_HOST="$1" && shift ;;
    "--min-temp") shift && MIN_DEV_TEMP="$1" && shift ;;
    "--max-temp") shift && MAX_DEV_TEMP="$1" && shift ;;
    *) die "Unsupported argument given: $1" ;;
  esac
done

# Checks
[[ -z $BIN_AWK ]] && die "You must have 'awk' installed to run this script."
[[ ! -r $BIN_XMRIG ]] && die "File '$BIN_XMRIG' is missing 'read' permission."
[[ ! -x $BIN_XMRIG ]] && die "File '$BIN_XMRIG' is missing 'exec' permission."

# Overrides
[[ $DEVICE_MEM_SIZE -lt $SLOW_MODE_RAM_SIZE ]] && SLOW_MODE=true
[[ -z $($BIN_XMRIG --print-platforms 2>/dev/null) ]] && ENABLE_OPENCL=false
[[ -z $RIG_ID || $RIG_ID == "localhost" ]] && RIG_ID="TXM-$RANDOM"

# Init
[[ $SLOW_MODE == true ]] && OPT_ARGS+=" --randomx-mode=light"
if [[ $ENABLE_OPENCL == true ]]; then
  [[ -z $PLATFORM_ID ]] && PLATFORM_ID=$(get_opencl_platform cuda)
  [[ -z $PLATFORM_ID ]] && PLATFORM_ID=$(get_opencl_platform intel)
  OPT_ARGS+=" --opencl --opencl-platform=$PLATFORM_ID"
fi

# Main
while :; do
  [[ $CLEAR_SCREEN == true ]] && clear

  CURRENT_TEMP=$(get_device_temp)
  POWER_LEVEL=$(get_battery_level)    # For later use
  POWER_STATUS=$(get_device_status)   # For later use

  if [[ $CURRENT_TEMP -ge $MAX_DEV_TEMP ]]; then
    if [[ $MINER_STARTED == true ]]; then
      OVER_HEATING=true
      KEEP_MINING=false
      MINER_STARTED=false
      kill_miner
    fi
  fi

  if [[ $OVER_HEATING == true && $CURRENT_TEMP -gt $MIN_DEV_TEMP ]]; then
    KEEP_MINING=false
    echo -e "\nWaiting for the device to cool down for a moment...\n"
  else
    OVER_HEATING=false
    KEEP_MINING=true
  fi

  if [[ $KEEP_MINING == true && $MINER_STARTED == false ]]; then
    start_miner &
    MINER_STARTED=true
  fi

  sleep $SLEEP_DELAY
done
