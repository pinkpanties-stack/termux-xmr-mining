#!/usr/bin/env bash

# Options
set -o xtrace

# Config
USE_REMOTE_NODE=true
REMOTE_NODE="node.monerodevs.org"
RPC_PORT=18089
ZMQ_PORT=18084
WALLET_ADDR=""

# Internals
BIN_P2POOL=~/p2pool/build/p2pool

# Checks
if [[ -z $WALLET_ADDR ]]; then
  echo -e "\nError: You must define the wallet address before running this script.\n" >&2
  exit 255
fi

# Main
if [[ $USE_REMOTE_NODE == false ]]; then
  $BIN_P2POOL \
    --host 127.0.0.1 \
    --wallet "$WALLET_ADDR" \
    --light-mode
else
  $BIN_P2POOL \
    --host "$REMOTE_NODE" \
    --rpc-port $RPC_PORT \
    --zmq-port $ZMQ_PORT \
    --wallet "$WALLET_ADDR" \
    --light-mode
fi
