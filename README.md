# Termux XMR Mining

Just a simple guide for easily mining XMR with Termux on mobiles.

## Installation

The first thing you have to do is to install [Termux](https://github.com/termux/termux-app).

Once done, run the following commands:

```console
$ pkg upgrade
$ pkg install git build-essential cmake libuv libzmq libcurl
```

Next, install [p2pool](https://github.com/SChernykh/p2pool) and [xmrig](https://github.com/xmrig/xmrig).

### Installing p2pool

```console
$ git clone --recursive https://github.com/SChernykh/p2pool.git
$ cd p2pool
$ mkdir build && cd build
$ cmake ..
$ make -j$(nproc)
```

Once the compilation is finished, check if you have a binary called `p2pool` with a command like `ls -halF` or `./p2pool --help`.

### Installing xmrig

```console
$ git clone https://github.com/xmrig/xmrig.git
$ cd xmrig
$ mkdir build && cd build
$ cmake -DWITH_HWLOC=OFF ..
$ make -j$(nproc)
```

Once the compilation is finished, check if you have a binary called `xmrig` with a command like `ls -halF` or `./xmrig --help`.

## Remote nodes

Use can use this page to select the remote node you want to use:

* https://monero.fail/
* http://p2pmd.xmrvsbeast.com/p2pool/monero_nodes.html

## Launcher scripts

To make the prcess even more easier, you can use the following launcher scripts:

* __[start-p2pool.sh](start-p2pool.sh)__

```bash
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
```

> The `--light-mode` argument is required to avoid consuming all the mobile memory which then leads to a complete crash...

* __[start-xmrig.sh](start-xmrig.sh)__

```bash
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
DEVICE_MEM_SIZE=$(cat /proc/meminfo | cut -d" " -f9)

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
```

## Run launcher scripts

Clone this repo to make things easier:

```console
$ git clone https://github.com/Jiab77/termux-xmr-mining.git
$ cd termux-xmr-mining
```

Once done, make the launcher scripts executable first with `chmod -c +x start-*.sh` then excute them both in dedicated tab / session.

_Add your wallet address in the `start-p2pool.sh` script or it will not run._

* __start-p2pool.sh__

```console
$ ./start-p2pool.sh
```

> Wait around 5 to 10 minutes for `p2pool` to be fully synced.

* __start-xmrig.sh__

```console
$ ./start-xmrig.sh
```

> You can stop both scripts by using `[Ctrl + C]` in case the mobile device is overheating.

## Check your progress

Have a look at the [pool observer](https://p2pool.observer/) and paste the wallet address you are using for mining to see your progression.

## References

* https://p2pool.io
* https://github.com/SChernykh/p2pool
* https://github.com/xmrig/xmrig

## Author

* __Jiab77__
