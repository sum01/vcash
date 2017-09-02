Required Dependencies
======
You should always use the highest version available that conforms to these dependencies.

|Dependency |Version                 |Name on Debian/Ubuntu    |Name on Arch |Name on Homebrew
|:----------|:----------------------:|:-----------------------:|:-----------:|:---:
|Boost      |min. `1.54`             |`libboost-all-dev`       |`boost`      |`boost`
|Berkeley DB|min. `5.0` max `6.1`    |`libdb++-dev` `libdb-dev`|`db`         |`berkeley-db`
|OpenSSL    |min. `1.0.1` max `1.0.2`|`openssl` `libssl-dev`   |`openssl-1.0`|`openssl`

**Build tools for Linux & macOS:** `cmake`, `make`, and a C++ compiler such as `GCC` or `Clang`  
**Build tools for Windows:** `cmake`, and a C++ compiler such as `MSVC`

Windows downloads
---
[Visual Studio 2017](https://www.visualstudio.com) comes with the `MSVC` compiler. Select "Desktop Development with C++" when installing.  
[Cmake](https://cmake.org/download/)  
[Boost](https://bintray.com/boostorg/release/boost-binaries) - Click the version, then `Files`, and install a version with a `msvc-14.1` suffix  
[OpenSSL](https://slproweb.com/products/Win32OpenSSL.html) - Install the full (not light) version.  
[Berkeley DB](http://www.oracle.com/technetwork/database/database-technologies/berkeleydb/downloads/index-082944.html) - Remove `otn/` from your download link to avoid making an account.

macOS downloads
---
[Homebrew package manager](https://brew.sh/) - Make sure to follow the setup guide on their website.  

Homebrew downloads an incompatible Berkeley DB version, so use `brew install https://raw.githubusercontent.com/Homebrew/homebrew-core/1e62c645b2fc2d82042d9f7c364c6a246f2e11ed/Formula/berkeley-db.rb` to install version `6.1.26`.  

Also, make sure you don't accidentally upgrade it by running `brew pin berkeley-db`
