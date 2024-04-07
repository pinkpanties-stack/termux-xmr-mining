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
* __[start-xmrig.sh](start-xmrig.sh)__

## Run launcher scripts

Clone this repo to make things easier:

```console
$ git clone https://github.com/Jiab77/termux-xmr-mining.git
$ cd termux-xmr-mining
```

Once done, make the launcher scripts executable first with `chmod -c +x start-*.sh` then excute them both in dedicated tab / session.

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

Have a look at the [pool observer](https://p2pool.observer/) and paste the wallet address you are using for mining to see your progression.

## Thanks

Thanks to [gupax](https://github.com/hinto-janai/gupax) devs for the inspiration.

## References

* https://p2pool.io
* https://github.com/SChernykh/p2pool
* https://github.com/xmrig/xmrig

## Author

* __Jiab77__
