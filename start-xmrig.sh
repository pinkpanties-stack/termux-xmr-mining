#!/usr/bin/env bash

# Options
set -o xtrace

# Config
LIMIT_ON_BATTERY=true
ENABLE_OPENCL=true

# Internals
BIN_XMRIG=~/xmrig/build/xmrig

# Checks
[[ -z $($BIN_XMRIG --print-platforms 2>/dev/null) ]] && ENABLE_OPENCL=false

# Init
[[ $ENABLE_OPENCL == true ]] && OPT_ARGS="--opencl"

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
