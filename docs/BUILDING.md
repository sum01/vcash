General Build Info
======
# WARNING
**Pre-existing wallet data is not backwards compatible with version v5 of Berkeley DB if it was originally built with v6.**

If you build with v5 and have old wallet data that was built with v6, you will need to delete your [Vcash data folder](COMMON_ISSUES.md), and recreate your wallet.

You can import your private keys or recover from your wallet seed, but if you do not have these then you will not be able to recover the wallet.

If you are sure you want to build with Berkeley DB v5, and you understand the risks, then use the build flag listed below called `WITH_INCOMPATIBLE_BDB`

Build flags
---
Use the various build flags when initiating `cmake` to trigger certain options, or to choose where to install things. A list of some of them [can be found here.](https://cmake.org/Wiki/CMake_Useful_Variables)

Please note that none of these are required for the build process.   
A complete list of custom flags can be found in the comments of the [FindBerkeleyDB module.](../cmake/Modules/FindBerkeleyDB.cmake#L3-L26)

|Custom Flags           |Linux Example       |macOS Example|Windows Example
|:----------------------|:------------------:|:-----------:|:---:
|`BERKELEYDB_ROOT`      |`/usr/include`      |`/usr/local` |`"C:/Program Files (x86)/Oracle/Berkeley DB 12cR1 6.1.36"`
|`BERKELEYDB_LIBNAME`   |`libdb.so`          |`libdb.dylib`|`libdb62.lib`
|`WITH_INCOMPATIBLE_BDB`|`ON`                |`ON`         |`ON`

If you have trouble getting CMake to find [OpenSSL](https://cmake.org/cmake/help/latest/module/FindOpenSSL.html), [Boost](https://cmake.org/cmake/help/latest/module/FindBoost.html), or [Threads](https://cmake.org/cmake/help/latest/module/FindThreads.html) dependencies, try setting their various path flags.

Boost system not found
---
Set the build flag `BOOST_LIBRARYDIR` to your `lib64-msvc-VERSIONHERE`.  

Example for Boost v1.64.0 on Win10: `BOOST_LIBRARYDIR:PATH=C:/local/boost_1_64_0/lib64-msvc-14.1`

OpenSSL not found
---
If CMake is not finding the correct version of OpenSSL, then you need to pass its paths with cmake flags.  

**Example for Arch Linux:** `cmake -DOPENSSL_INCLUDE_DIR=/usr/include/openssl-1.0 -DOPENSSL_SSL_LIBRARY=/usr/lib/libssl.so.1.0.0 -DOPENSSL_CRYPTO_LIBRARY=/usr/lib/libcrypto.so.1.0.0`

**Example for OSX:** `cmake -DOPENSSL_ROOT_DIR=/usr/local/opt/openssl CMakeLists.txt`

Build Errors
---
|Problem                                                 |Solution
|:------------------------------------------------------:|:---:
|`c++: internal compiler error: Killed (program cc1plus)`|You ran out of RAM during building. Increase your swap partition or add more RAM to your system -- 1GB minimum needed.
|`msbuild not found`                                     |Add the path to your `MSBuild.exe` to your environment variables
