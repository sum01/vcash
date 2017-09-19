# Dependency versions & find_package() commands.
# Only things used in all libs and the binary are set here, as to be more modular.

# TODO: Remove OPENSSL_MAX_VER when 1.1.x is in master branch
# TODO: Remove BERKELEYDB_MAX_VER if/when Vcash is compatible with versions 6.2 or greater of BerkeleyDB

# Prevent accidental building with DB v5, which isn't compatible with wallets built with DB v6
option(WITH_INCOMPATIBLE_BDB "Enables building with a Berkeley DB v5 minimum instead of v6 minimum." OFF)

# Do not set the letter ("status") version for either OPENSSL variables!
set(OPENSSL_MIN_VER "1.0.1")
set(OPENSSL_MAX_VER "1.0.2")

set(BOOST_MIN_VER "1.54.0")

IF(WITH_INCOMPATIBLE_BDB)
  set(BERKELEYDB_MIN_VER "5.0.0")
ELSE()
  set(BERKELEYDB_MIN_VER "6.0.0")
ENDIF()
set(BERKELEYDB_MAX_VER "6.1.36")

IF(CMAKE_SYSTEM_NAME MATCHES "Windows")
  # Don't use pthreads on non-POSIX Windows
  message(STATUS "${CMAKE_SYSTEM_NAME} detected, not using pthread...")
  set(THREADS_PREFER_PTHREAD_FLAG OFF)
ELSE()
  # Tells find_package(Threads) to get pthread.h & use -lpthread compile flag
  # Should only get set on non-Windows, aka Unix
  message(STATUS "${CMAKE_SYSTEM_NAME} detected, using pthread...")
  set(THREADS_PREFER_PTHREAD_FLAG ON)
ENDIF()

# Needed in both lib coin and database
find_package(Boost ${BOOST_MIN_VER} COMPONENTS system REQUIRED)
find_package(OpenSSL ${OPENSSL_MIN_VER} REQUIRED)
find_package(BerkeleyDB ${BERKELEYDB_MIN_VER} REQUIRED)
find_package(Threads REQUIRED) # Not pthread specificly, code uses #include <thread>

# ~~ Max version checks ~~
# TODO: Max 1.0.2 allowed at the moment. Remove this when 1.1.x is in master branch
IF(OPENSSL_VERSION VERSION_GREATER ${OPENSSL_MAX_VER})
  message(FATAL_ERROR "OpenSSL v${OPENSSL_VERSION} was found, but a maximum of v${OPENSSL_MAX_VER} is compatible.")
ENDIF()

# TODO: Remove this max version check if/when Vcash is compatible with versions 6.2 or greater of BerkeleyDB
IF(BERKELEYDB_VERSION VERSION_GREATER "${BERKELEYDB_MAX_VER}")
  message(FATAL_ERROR "The detected BerkeleyDB v${BERKELEYDB_VERSION} isn't compatible! Maximum v${BERKELEYDB_MAX_VER} is compatible.")
# Throw a warning if the user has DB ver < 6 but continue building
ELSEIF(BERKELEYDB_VERSION VERSION_LESS "6.0.0")
  message(WARNING "Pre-existing wallet data is not backwards compatible with version v5 of Berkeley DB if it was originally built with v6. \n
    Read \"docs/BUILDING.md\" for more info.")
ENDIF()

# Quick bool var used to IF check in other modules
set(VCASH_DEPS_SET TRUE)
