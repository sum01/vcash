# WARNING: DO NOT USE THIS BRANCH IN PRODUCTION!    
# Vcash
> A decentralized currency for the internet.

[![Donate](https://img.shields.io/badge/donate-BTC-yellow.svg)](https://blockchain.info/address/35nXEZoiZCVQKGTLR63XUhPfqWszBihFkd)
[![Slack](https://slack.vcash.info/badge.svg)](https://slack.vcash.info/)
[![Release](https://img.shields.io/github/release/openvcash/vcash.svg)](https://github.com/openvcash/vcash/releases/latest)  
[![TravisCI](https://img.shields.io/travis/openvcash/vcash/master.svg?label=Linux%20%26%20macOS%20build)](https://travis-ci.org/openvcash/vcash)

https://vcash.info/  

What is Vcash?
---
Vcash is a decentralized internet currency that enables you to send money to anyone in the world, instantly, and at almost no cost.

## Features of Vcash
- 3-tiered network using [PoW,](https://github.com/openvcash/papers/blob/master/rewardv3.pdf) [PoS,](https://github.com/openvcash/docs.vcash.info/blob/master/docs/block/generation/proof-of-stake.md) and [incentive nodes.](https://github.com/openvcash/papers/blob/master/incentive.pdf)
- [Zerotime:](https://github.com/openvcash/papers/blob/master/zerotime.pdf) a near-instantaneous off-chain transaction protocol.
- [Chainblender:](https://github.com/openvcash/papers/blob/master/chainblender.pdf) an (optional) client-side blending system to protect your anonymity.
- [An average block time of 100 seconds.](https://github.com/openvcash/papers/blob/master/scaling_the_blockchain.pdf)
- Fully encrypted network, a UDP layer, and port randomization.
- Blake256 8-rounds hash.

Docs and whitepapers
---
[The docs](https://docs.vcash.info/), their [source on github,](https://github.com/openvcash/docs.vcash.info) and [the whitepapers.](https://github.com/openvcash/papers)  

Read [common issues](docs/COMMON_ISSUES.md) if you're having problems related to the coin other than when trying to build from source.

Building from source
---
There are currently two ways to build the source code: [CMake](https://cmake.org/) and [Boost.](http://www.boost.org/build/) CMake relies on the dependencies to be installed system-wide, while Boost-build requires you to build and compile dependencies into the [vcash/deps](deps) folder.

### Building with CMake
[Dependencies can be found here.](docs/DEPENDENCIES.md)  
Read [BUILDING](docs/BUILDING.md) before attempting to build from source.  

#### Windows
1. Install [the dependencies](docs/DEPENDENCIES.md) to their default locations.
2. Download and extract the [Source code (zip).](https://github.com/openvcash/vcash/releases/latest)
3. Run the following from your command prompt...  
```
cd C:\path\to\vcash
cmake -G "Visual Studio 15 2017 Win64" -T v141,host=x64 CMakeLists.txt
msbuild Vcash.sln /p:Configuration=Release /p:Platform=x64
```
If you want to compile faster, add the `/m:1` flag to `msbuild`, where `1` is your cpu core count.

Once done compiling, you should have a `vcash.exe` you can run.

#### Linux & macOS
1. Install [the dependencies](docs/DEPENDENCIES.md) with your package manager.
2. Download and extract the [Source code (tar.gz)](https://github.com/openvcash/vcash/releases/latest)
3. Run the following commands from your terminal...  
```
cd /path/to/vcash
cmake CMakeLists.txt
make
make install
```
If you want to compile faster, add the `-j$(nproc)` flag to `make`. Requires the [GNU coreutils.](https://www.gnu.org/software/coreutils/coreutils.html)  

After `make install`, you should be able to run `vcashd` and `sh vcashrpc.sh` from your terminal.  

###### Arch Linux  
[![The AUR PKGBUILD](https://img.shields.io/aur/version/vcash.svg)](https://aur.archlinux.org/packages/vcash/) is available, which builds and installs the source code from the latest release.

If you don't know how to install something from the Arch User Repository, [read this Arch wiki post](https://wiki.archlinux.org/index.php/AUR_helpers) or [this post on the forums.](https://forum.vcash.info/d/56-arch-linux-aur-pkgbuild-s)

License
---
Vcash is released under the terms of the AGPL-3.0 license. See [LICENSE](LICENSE) for more information.
