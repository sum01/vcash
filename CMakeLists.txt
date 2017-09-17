CMAKE_MINIMUM_REQUIRED(VERSION 3.1.3)
# == START Minimum version requirement list ==
# 3.0 for versioning inside of project()
# 3.1.3 for THREADS_PREFER_PTHREAD_FLAG | CMAKE_CXX_STANDARD | CMAKE_CXX_STANDARD_REQUIRED
# EVENTUALLY: 3.9 for the addition of a DESCRIPTION to project()
# == END Minimum version requirement list ==
#
# For cross-compiling, read https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html#cross-compiling-toolchain

# Get version string from constants.hpp
file(STRINGS "coin/include/coin/constants.hpp" VCASH_VERSION)
string(REGEX REPLACE ".*version_string = \"([0-9]+)\\.([0-9]+)\\.([0-9]+)\\.([0-9]+).*"
"\\1.\\2.\\3.\\4" VCASH_VERSION "${VCASH_VERSION}")

message(STATUS "Starting cmake build of Vcash v${VCASH_VERSION}")
project(Vcash VERSION ${VCASH_VERSION} LANGUAGES C CXX)

# Build options for multi-config only (aka Windows)
IF(CMAKE_CONFIGURATION_TYPES)
  # Lists the available build options
  set(CMAKE_CONFIGURATION_TYPES "Debug;Release" CACHE STRING "Available build types." FORCE)
# Single-config (aka Unix)
ELSEIF(NOT CMAKE_BUILD_TYPE)
  # Default to a release build if nothing is specified
  message(STATUS "Defaulting to Release build type since nothing was specified.")
  set(CMAKE_BUILD_TYPE Release)
ENDIF()

# Require/Build for C++11
# Consider changing to target_compile_features in the future. Links below for feature lists...
# https://cmake.org/cmake/help/latest/prop_gbl/CMAKE_C_KNOWN_FEATURES.html#prop_gbl:CMAKE_C_KNOWN_FEATURES
# https://cmake.org/cmake/help/latest/prop_gbl/CMAKE_CXX_KNOWN_FEATURES.html#prop_gbl:CMAKE_CXX_KNOWN_FEATURES
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Dependency versions | Vars used instead of setting directly on find_package because they are used in some IF's
set(OPENSSL_MIN_VER "1.0.1") # Minimum | Do not set the letter ("status") version
# TODO: Remove OPENSSL_MAX_VER when 1.1.x is in master branch
set(OPENSSL_MAX_VER "1.0.2") # Maximum | Do not set the letter ("status") version
set(BOOST_MIN_VER "1.54.0") # Minimum
# Prevent accidental building with DB v5, which isn't compatible with wallets built with DB v6
option(WITH_INCOMPATIBLE_BDB "Enables building with a Berkeley DB v5 minimum instead of v6 minimum." OFF)
IF(WITH_INCOMPATIBLE_BDB)
  set(BERKELEYDB_MIN_VER "5.0.0") # Minimum
ELSE()
  set(BERKELEYDB_MIN_VER "6.0.0") # Minimum
ENDIF()
# TODO: Remove BERKELEYDB_MAX_VER if/when Vcash is compatible with versions 6.2 or greater of BerkeleyDB
set(BERKELEYDB_MAX_VER "6.1.36") # Maximum

# Adds our custom find_package modules to the list of modules available for cmake
list(APPEND CMAKE_MODULE_PATH "cmake/Modules")

# Start of finding dependencies...
find_package(OpenSSL ${OPENSSL_MIN_VER} REQUIRED)
# TODO: Max 1.0.2 allowed at the moment. Remove this when 1.1.x is in master branch
IF(OPENSSL_VERSION VERSION_GREATER ${OPENSSL_MAX_VER})
  message(FATAL_ERROR "OpenSSL v${OPENSSL_VERSION} was found, but a maximum of v${OPENSSL_MAX_VER} is compatible.")
ENDIF()

IF(CMAKE_SYSTEM_NAME MATCHES "Windows")
  message(STATUS "Windows system detected, ignoring pthread.")
  # Don't use pthreads on non-POSIX Windows
  set(THREADS_PREFER_PTHREAD_FLAG OFF)
ELSE()
  message(STATUS "Non-Windows system detected, using pthread.")
  # Tells find_package(Threads) to get pthread.h & use -lpthread compile flag
  # Should only get set on non-Windows, aka Unix
  set(THREADS_PREFER_PTHREAD_FLAG ON)
ENDIF()

find_package(Threads REQUIRED)
find_package(Boost ${BOOST_MIN_VER} COMPONENTS system REQUIRED)
find_package(BerkeleyDB ${BERKELEYDB_MIN_VER} REQUIRED)

# TODO: Remove this max version check if/when Vcash is compatible with versions 6.2 or greater of BerkeleyDB
IF(BERKELEYDB_VERSION VERSION_GREATER "${BERKELEYDB_MAX_VER}")
  message(FATAL_ERROR "The detected BerkeleyDB v${BERKELEYDB_VERSION} isn't compatible! Maximum v${BERKELEYDB_MAX_VER} is compatible.")
# Throw a warning if the user has DB ver < 6 but continue building
ELSEIF(BERKELEYDB_VERSION VERSION_LESS "6.0.0")
  message(WARNING "Pre-existing wallet data is not backwards compatible with version v5 of Berkeley DB if it was originally built with v6. \n
    Read \"docs/BUILDING.md\" for more info.")
ENDIF()

# Initial setting of compiler definitions
# I believe this makes the binary 64-bit only, which should be noted somewhere...
set(_definitions "-D_FILE_OFFSET_BITS=64")

IF(CMAKE_BUILD_TYPE STREQUAL "Release")
  message(STATUS "Setting build flag for \"Release\" build-type.")
  list(APPEND _definitions "-DNDEBUG")
ENDIF()

# Adds compile definitions for the detected compiler
# MSVC compiler
IF(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
  message(STATUS "MSVC compiler detected, setting definitions.")

  # Copy-paste from https://stackoverflow.com/a/40217291
  # Gets correct WinNT kernel version based on system
  # Technically you can get MSVC on non-Windows OS's, but we probably don't need to worry about that..
  macro(get_WIN32_WINNT version)
    if (CMAKE_SYSTEM_VERSION)
        set(ver ${CMAKE_SYSTEM_VERSION})
        string(REGEX MATCH "^([0-9]+).([0-9])" ver ${ver})
        string(REGEX MATCH "^([0-9]+)" verMajor ${ver})
        # Check for Windows 10, b/c we'll need to convert to hex 'A'.
        if ("${verMajor}" MATCHES "10")
            set(verMajor "A")
            string(REGEX REPLACE "^([0-9]+)" ${verMajor} ver ${ver})
        endif ("${verMajor}" MATCHES "10")
        # Remove all remaining '.' characters.
        string(REPLACE "." "" ver ${ver})
        # Prepend each digit with a zero.
        string(REGEX REPLACE "([0-9A-Z])" "0\\1" ver ${ver})
        set(${version} "0x${ver}")
    endif(CMAKE_SYSTEM_VERSION)
  endmacro(get_WIN32_WINNT)
  get_WIN32_WINNT(ver)

  list(APPEND _definitions
    "-D_WIN32_WINNT=${ver}" # Specifies WinNT kernel to build for
    "-D_UNICODE"
    "-DUNICODE"
    "-D_SCL_SECURE_NO_DEPRECATE"
    "-D_CRT_SECURE_NO_DEPRECATE"
    "-DBOOST_ALL_NO_LIB" # This, and BOOST_ALL_DYN_LINK tell cmake to use dynamic lib names
    "-DBOOST_ALL_DYN_LINK"
    "-Zc:wchar_t" # "If /Zc:wchar_t is on, wchar_t maps to the Microsoft-specific native type __wchar_t"
    "-Zc:forScope" # "Used to implement standard C++ behavior for for loops with Microsoft extensions"
  )

  # Optimizations for release type builds
  # We could add /IGNORE:4267,4244 to flags to hide "conversion from 'X' to 'Y', possible loss of data", but probably shouldn't.
  # FIXME - these show as unrecognized linker options and get ignored...
  # set(CMAKE_STATIC_LINKER_FLAGS_RELEASE "${CMAKE_STATIC_LINKER_FLAGS_RELEASE} /OPT:ICF=5 /OPT:REF")
  # set(CMAKE_EXE_LINKER_FLAGS_RELEASE "${CMAKE_EXE_LINKER_FLAGS_RELEASE} /OPT:ICF=5 /OPT:REF")

# Clang/AppleClang compiler
ELSEIF(CMAKE_CXX_COMPILER_ID MATCHES "Clang") # MATCHES Clang and AppleClang
  message(STATUS "Clang compiler detected, setting definitions.")
  # NOTE: Do we really need this flag? Copied from Jamfile
  list(APPEND _definitions "-DBOOST_NO_CXX11_NUMERIC_LIMITS")
# GCC compiler
ELSEIF(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  message(STATUS "GCC compiler detected, setting definitions.")
  # 02 optimization required to build on GCC >= v6, otherwise it fails
  list(APPEND _definitions "-O2")
ENDIF()

# Set all our various definitions
message(STATUS "List of definitions to be used (delimited by semi-colon): ${_definitions}")
add_definitions(${_definitions})

# Paths are relative when called and do not require CMAKE_CURRENT_SOURCE_DIR
# Libcoin
add_library(coin STATIC
  coin/src/account.cpp
  coin/src/accounting_entry.cpp
  coin/src/address.cpp
  coin/src/address_manager.cpp
  coin/src/alert.cpp
  coin/src/alert_manager.cpp
  coin/src/alert_unsigned.cpp
  coin/src/base58.cpp
  coin/src/big_number.cpp
  coin/src/blake256.cpp
  coin/src/block.cpp
  coin/src/block_index.cpp
  coin/src/block_index_disk.cpp
  coin/src/block_locator.cpp
  coin/src/block_merkle.cpp
  coin/src/chainblender_broadcast.cpp
  coin/src/chainblender.cpp
  coin/src/chainblender_join.cpp
  coin/src/chainblender_leave.cpp
  coin/src/chainblender_manager.cpp
  coin/src/chainblender_status.cpp
  coin/src/checkpoints.cpp
  coin/src/checkpoint_sync.cpp
  coin/src/checkpoint_sync_unsigned.cpp
  coin/src/configuration.cpp
  coin/src/crypter.cpp
  coin/src/database_stack.cpp
  coin/src/db.cpp
  coin/src/db_env.cpp
  coin/src/db_tx_bdb.cpp
  coin/src/db_tx.cpp
  coin/src/db_tx_ldb.cpp
  coin/src/db_wallet.cpp
  coin/src/ecdhe.cpp
  coin/src/file.cpp
  coin/src/filesystem.cpp
  coin/src/gateway.cpp
  coin/src/globals.cpp
  coin/src/hash.cpp
  coin/src/hc256.cpp
  coin/src/hd_configuration.cpp
  coin/src/hd_ecdsa.cpp
  coin/src/hd_keychain.cpp
  coin/src/http_transport.cpp
  coin/src/incentive_answer.cpp
  coin/src/incentive_collaterals.cpp
  coin/src/incentive.cpp
  coin/src/incentive_manager.cpp
  coin/src/incentive_question.cpp
  coin/src/incentive_sync.cpp
  coin/src/incentive_vote.cpp
  coin/src/inventory_vector.cpp
  coin/src/kernel.cpp
  coin/src/key.cpp
  coin/src/key_pool.cpp
  coin/src/key_public.cpp
  coin/src/key_reserved.cpp
  coin/src/key_store_basic.cpp
  coin/src/key_store_crypto.cpp
  coin/src/key_wallet.cpp
  coin/src/key_wallet_master.cpp
  coin/src/merkle_tree_partial.cpp
  coin/src/message.cpp
  coin/src/mining.cpp
  coin/src/mining_manager.cpp
  coin/src/nat_pmp_client.cpp
  coin/src/nat_pmp.cpp
  coin/src/pbkdf2.cpp
  coin/src/point_in.cpp
  coin/src/point_out.cpp
  coin/src/reward.cpp
  coin/src/ripemd160.cpp
  coin/src/rpc_connection.cpp
  coin/src/rpc_json_parser.cpp
  coin/src/rpc_manager.cpp
  coin/src/rpc_server.cpp
  coin/src/rpc_transport.cpp
  coin/src/script_checker.cpp
  coin/src/script_checker_queue.cpp
  coin/src/script.cpp
  coin/src/secret.cpp
  coin/src/sha256.cpp
  coin/src/signature_cache.cpp
  coin/src/stack.cpp
  coin/src/stack_impl.cpp
  coin/src/status_manager.cpp
  coin/src/tcp_acceptor.cpp
  coin/src/tcp_connection.cpp
  coin/src/tcp_connection_manager.cpp
  coin/src/tcp_transport.cpp
  coin/src/transaction_bloom_filter.cpp
  coin/src/transaction.cpp
  coin/src/transaction_in.cpp
  coin/src/transaction_index.cpp
  coin/src/transaction_merkle.cpp
  coin/src/transaction_out.cpp
  coin/src/transaction_pool.cpp
  coin/src/transaction_position.cpp
  coin/src/transaction_wallet.cpp
  coin/src/upnp_client.cpp
  coin/src/utility.cpp
  coin/src/wallet.cpp
  coin/src/wallet_manager.cpp
  coin/src/whirlpool.cpp
  coin/src/zerotime_answer.cpp
  coin/src/zerotime.cpp
  coin/src/zerotime_lock.cpp
  coin/src/zerotime_manager.cpp
  coin/src/zerotime_question.cpp
  coin/src/zerotime_vote.cpp
)
# Libdatabase
add_library(database STATIC
  database/src/block.cpp
  database/src/broadcast_operation.cpp
  database/src/compression.cpp
  database/src/ecdhe.cpp
  database/src/entry.cpp
  database/src/find_operation.cpp
  database/src/hc256.cpp
  database/src/key_pool.cpp
  database/src/message.cpp
  database/src/node.cpp
  database/src/node_impl.cpp
  database/src/operation.cpp
  database/src/operation_queue.cpp
  database/src/ping_operation.cpp
  database/src/query.cpp
  database/src/routing_table.cpp
  database/src/rpc.cpp
  database/src/slot.cpp
  database/src/stack.cpp
  database/src/stack_impl.cpp
  database/src/storage.cpp
  database/src/store_operation.cpp
  database/src/udp_handler.cpp
  database/src/udp_multiplexor.cpp
  database/src/whirlpool.cpp
)

target_include_directories(coin
  PUBLIC coin/include
  PUBLIC database/include
  PUBLIC ${Boost_INCLUDE_DIRS}
  PUBLIC ${OPENSSL_INCLUDE_DIR}
  PUBLIC ${BERKELEYDB_INCLUDE_DIRS}
)

target_include_directories(database
  PUBLIC database/include
  PUBLIC ${Boost_INCLUDE_DIRS}
  PUBLIC ${OPENSSL_INCLUDE_DIR}
)

add_executable(vcashd coin/test/main.cpp)

# Threads::Threads seems to always trigger a quiet cmake error on Windows, but it doesn't break the build..
# Unsure of a way around this, as we need the thread libs to build/run Vcash.
target_link_libraries(vcashd coin database ${BERKELEYDB_LIBRARIES} ${OPENSSL_LIBRARIES} ${Boost_LIBRARIES} Threads::Threads)

# Set paths if none detected, as they don't seem to default correctly
# bin and lib are not OS-specific, but generic names for cmake
IF(NOT CMAKE_INSTALL_BINDIR)
  set(CMAKE_INSTALL_BINDIR bin)
ENDIF()
IF(NOT CMAKE_INSTALL_LIBDIR)
  set(CMAKE_INSTALL_LIBDIR lib)
ENDIF()

# ARCHIVE is for STATIC libs
install(TARGETS vcashd database coin
  RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
  ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
)

# TODO: Add a Windows batch/powershell RPC script, uncomment this, and delete the currently used install(FILES)
#IF(CMAKE_SYSTEM_NAME MATCHES "Windows")
#  set(_VCASH_RPC_NAME "vcashrpc.ps")
#ELSE()
#  set(_VCASH_RPC_NAME "vcashrpc")
#ENDIF()
#install(FILES ${_VCASH_RPC_NAME}
#  PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE # Should be equivilent to chmod 755
#  DESTINATION "${CMAKE_INSTALL_BINDIR}"
#)

# Install the rpc.sh if not Windows | Trying to avoid doing IF(UNIX) for cross-compiling
IF(NOT CMAKE_SYSTEM_NAME MATCHES "Windows")
  install(FILES vcashrpc
    PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE # Should be equivilent to chmod 755
    DESTINATION "${CMAKE_INSTALL_BINDIR}"
  )
ENDIF()

# Consider adding the following functions..
# add_test https://cmake.org/cmake/help/latest/command/add_test.html If added, then TravisCI needs `make test` added to `.travis.yml`
# export https://cmake.org/cmake/help/latest/command/export.html Makes it easy for external CMake projects to import Vcash
