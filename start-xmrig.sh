#!/usr/bin/env bash

# Options
set -o xtrace

# Config
LIMIT_ON_BATTERY=true
ENABLE_OPENCL=true
SLOW_MODE=false
SLOW_MODE_THRES=4G

# Internals
BIN_XMRIG=~/xmrig/build/xmrig
SLOW_MODE_THRES_CLEAN="${SLOW_MODE_THRES//G/}"
SLOW_MODE_RAM_SIZE=$((SLOW_MODE_THRES_CLEAN*1024*1024))
DEVICE_MEM_SIZE=$(cat /proc/meminfo | grep MemTotal | cut -d" " -f9)

# Checks
[[ $DEVICE_MEM_SIZE -lt $SLOW_MODE_RAM_SIZE ]] && SLOW_MODE=true
[[ $SLOW_MODE == true || -z $($BIN_XMRIG --print-platforms 2>/dev/null) ]] && ENABLE_OPENCL=false

# Init
[[ $ENABLE_OPENCL == true ]] && OPT_ARGS="--opencl --opencl-platform=0"
[[ $SLOW_MODE == true ]] && OPT_ARGS="--randomx-mode=light"

# Main
if [[ $LIMIT_ON_BATTERY == false ]]; then
  $BIN_XMRIG \
    -o 127.0.0.1:3333 \
    --print-time=5 \
    --health-print-time=10 \
    $OPT_ARGS
else
  $BIN_XMRIG \
    -o 127.0.0.1:3333 \
    --print-time=5 \
    --health-print-time=10 \
    --pause-on-battery \
    --pause-on-active=10 \
    $OPT_ARGS
fi
