#!/usr/bin/env bash

# Options
set -o xtrace

# Config
LIMIT_ON_BATTERY=true

# Internals
BIN_XMRIG=~/xmrig/build/xmrig

# Main
if [[ $LIMIT_ON_BATTERY == false ]]; then
  $BIN_XMRIG \
    -o 127.0.0.1:3333 \
    --print-time=5 \
    --health-print-time=10
else
  $BIN_XMRIG \
    -o 127.0.0.1:3333 \
    --print-time=5 \
    --health-print-time=10 \
    --pause-on-battery \
    --pause-on-active=10
fi
