#!/usr/bin/env bash

# P2Pool launcher script
# Made by Jiab77
#
# Version 0.2.0

# Options
[[ -r $HOME/.debug ]] && set -o xtrace || set +o xtrace

# Config
LIGHT_MODE=false
LIGHT_MODE_THRES=8G
USE_POOL_MINI=true
USE_REMOTE_NODE=true
REMOTE_NODE="node.monerodevs.org"
REMOTE_RPC_PORT=18089
REMOTE_ZMQ_PORT=18084
WALLET_ADDR=""
XVB_TOKEN=""

# Internals
BIN_P2POOL=~/p2pool/build/p2pool
BIN_AWK=$(command -v awk 2>/dev/null)
LIGHT_MODE_THRES_CLEAN="${LIGHT_MODE_THRES//G/}"
LIGHT_MODE_RAM_SIZE=$((LIGHT_MODE_THRES_CLEAN*1024*1024))
DEVICE_MEM_SIZE=$(grep MemTotal /proc/meminfo | awk '{ print $2 }')
LOCAL_NODE="127.0.0.1"
OPT_ARGS=

# Functions
function die() {
  echo -e "\nError: $*\n" >&2
  exit 255
}
function print_usage() {
  echo -e "\nUsage: $(basename "$0") [flags] -- Start P2Pool with the configured remote node and wallet address"
  echo -e "\nFlags:"
  echo -e "  -h | --help\tPrint this message and exit"
  echo -e "  -b | --bin\tUse given P2Pool binary path"
  echo -e "  -c | --config\tUse given config file"
  echo -e "  -r | --remote-node\tUse given remote node"
  echo -e "  -w | --wallet\tUse given wallet address"
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
function init_pool() {
  if [[ $USE_REMOTE_NODE == false ]]; then
    $BIN_P2POOL \
      --host "$LOCAL_NODE" \
      --wallet "$WALLET_ADDR" \
      $OPT_ARGS
  else
    $BIN_P2POOL \
      --host "$REMOTE_NODE" \
      --wallet "$WALLET_ADDR" \
      --rpc-port $REMOTE_RPC_PORT \
      --zmq-port $REMOTE_ZMQ_PORT \
      $OPT_ARGS
  fi
}

# Flags
while [[ $# -ne 0 ]]; do
  case $1 in
    "-h"|"--help") print_usage ;;
    "-b"|"--bin") shift && BIN_P2POOL="$1" && shift ;;
    "-c"|"--config") shift && load_config "$1" && shift ;;
    "-r"|"--remote-node") shift && REMOTE_NODE="$1" && shift ;;
    "-w"|"--wallet") shift && WALLET_ADDR="$1" && shift ;;
    *) die "Unsupported argument given: $1" ;;
  esac
done

# Checks
[[ -z $BIN_AWK ]] && die "You must have 'awk' installed to run this script."
[[ -z $WALLET_ADDR ]] && die "You must define the wallet address before running this script."
[[ ! -r $BIN_P2POOL ]] && die "File '$BIN_P2POOL' is missing 'read' permission."
[[ ! -x $BIN_P2POOL ]] && die "File '$BIN_P2POOL' is missing 'exec' permission."

# Overrides
[[ $DEVICE_MEM_SIZE -lt $LIGHT_MODE_RAM_SIZE ]] && LIGHT_MODE=true
[[ $(echo "$REMOTE_NODE" | grep -ci "p2pmd") -ne 0 ]] && REMOTE_RPC_PORT=18081

# Init
[[ $LIGHT_MODE == true ]] && OPT_ARGS+=" --light-mode"
[[ $USE_POOL_MINI == true ]] && OPT_ARGS+=" --mini"

# Main
init_pool
