# Termux XMR Mining

Just a simple guide for easily mining XMR (Monero) with Termux on mobiles.

## Installation

The first thing you have to do is to install [Termux](https://github.com/termux/termux-app).

Once done, run the following commands:

```console
$ pkg upgrade
$ pkg install -y git build-essential cmake libuv libzmq libcurl
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

Once the compilation is finished, check if the binary called `p2pool` has been compiled correctly with `./p2pool --help`.

### Installing xmrig

```console
$ git clone https://github.com/xmrig/xmrig.git
$ cd xmrig
$ mkdir build && cd build
$ cmake -DWITH_HWLOC=OFF ..
$ make -j$(nproc)
```

Once the compilation is finished, check if the binary called `xmrig` has been compiled correctly with `./xmrig --help`.

### Installing Termux API

In order to be able to detect the temperature on mobile devices, you need to install both, mobile app and the Termux package.

* Mobile App

Search for application named "Termux:API" on the Google Play store and install it.

* Termux Package

```console
$ pkg install -y termux-api
```

Additionally, you will also have to install the `jq` package as it is now required by the launcher scripts.

```console
$ pkg install -y jq
```

Once done, run the following command:

```console
$ termux-battery-status | jq .
```

If you see something, then it means that the __Termux API__ has been installed correctly.

> You don't have to grant any permissions to the 'Termux:API' application as no permissions are required to query the device battery status.

## Remote nodes

By default, the P2Pool launcher script is configured to use remote Monero mining nodes as this project is primilary made for low-end devices.

Use can use this page to select the remote node you want to use:

* https://monero.fail/
* https://p2pmd.xmrvsbeast.com/p2pool/monero_nodes.html

## Launcher scripts

To make the prcess even more easier, you can use the following launcher scripts:

* __[start-p2pool.sh](start-p2pool.sh)__
* __[start-xmrig.sh](start-xmrig.sh)__

### Running launcher scripts

Clone this repo to make things easier:

```console
$ git clone https://github.com/Jiab77/termux-xmr-mining.git
$ cd termux-xmr-mining
```

Once done, run each launcher scripts in a dedicated tab / session by swipping from left to right on mobile devices.

_Add your wallet address in the `start-p2pool.sh` script or it will not run._

* __P2Pool__

```console
$ ./start-p2pool.sh
```

> Wait around 5 to 10 minutes for `p2pool` to be fully synced.

* __XMRig__

```console
$ ./start-xmrig.sh
```

> You can stop both scripts by using `[Ctrl + C]` in case the mobile device is overheating.

## Check your progress

Have a look at the [pool observer](https://p2pool.observer) and paste the wallet address you are using for mining to see your progression.

> You might also have to look at the [pool mini observer](https://mini.p2pool.observer) instead of the main one if the "mini" has been enabled.

## XvB Raffle

The support for [XvB Raffle](https://xmrvsbeast.com/p2pool) is currently in development and might not be functional yet.

You will need to [register](https://p2pmd.xmrvsbeast.com/cgi-bin/p2pool_bonus_submit.cgi) to get started.

> Once done, set the `XVB_TOKEN` variable in the config part of the __[start-p2pool.sh](start-p2pool.sh)__ launcher script.

Here is some useful information:

__Nodes__

* P2P: `p2pmd.xmrvsbeast.com:18081`
* EU: `eu.xmrvsbeast.com:18089`
* NA: `na.xmrvsbeast.com:18089`

> These nodes are listed in the following format: `node:rpc`

## APIs

The support for the several supported APIs will be implemented soon.

Here is some implementation details:

__P2Pool__

* Argument(s): `--local-api`
* Path: `/local/`
* Port: `3333`

__XMRig__

* Argument(s): `--http-host`, `--http-port`
* Port: `18088`

__XvB__

* Public: `https://xmrvsbeast.com/p2pool/stats`
* Private: `https://xmrvsbeast.com/cgi-bin/p2pool_bonus_history_api.cgi?address=WALLET_ADDRESS&token=TOKEN`

## Tor

The support for Tor will be implemented soon.

Here is some implementation details:

__P2Pool__

* Argument: `--socks5`
* Value: `IP:PORT`

__XMRig__

* Argument: `--proxy`
* Value: `IP:PORT`

## Thanks

Thanks to [gupax](https://github.com/hinto-janai/gupax) and [gupaxx](https://github.com/Cyrix126/gupaxx) devs for the inspiration.

## Roadmap

* [X] Create launcher scripts
* [X] Add device memory detection code
* [X] Add OpenCL support for Intel and Nvidia
* [ ] Add [XvB Raffle](https://p2pmd.xmrvsbeast.com/p2pool) support (_pending_)
* [ ] Add API support for P2Pool, XMrig and XvB
* [ ] Add Tor support
* [ ] Create installer scripts
* [ ] Improve OpenCL code
* [ ] Improve documentation

## References

* https://p2pool.io
* https://p2pool.io/mini
* https://p2pmd.xmrvsbeast.com/p2pool
* https://github.com/SChernykh/p2pool
* https://github.com/xmrig/xmrig

## Author

* __Jiab77__
