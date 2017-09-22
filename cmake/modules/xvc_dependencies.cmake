# Dependency versions & find_package() commands in a small module for easier updating

# TODO: Remove OPENSSL_MAX_VER and max version check when 1.1.x is in master branch
# TODO: Remove BERKELEYDB_MAX_VER and max version check when Vcash is compatible with version > 6.2

# ~~ Boost ~~
find_package(Boost "1.54.0" COMPONENTS system REQUIRED)

# ~~ OpenSSL ~~
# Do not set the letter ("status") version for OpenSSL!
find_package(OpenSSL "1.0.1" REQUIRED)
set(OPENSSL_MAX_VER "1.0.2") # Used in max ver check

# ~~ Berkeley DB ~~
# Prevent accidental building with DB v5, which isn't compatible with wallets built with DB v6
option(WITH_INCOMPATIBLE_BDB "Enables building with a Berkeley DB v5 minimum instead of v6 minimum." OFF)
IF(WITH_INCOMPATIBLE_BDB)
  set(BERKELEYDB_MIN_VER "5.0.0")
ELSE()
  set(BERKELEYDB_MIN_VER "6.0.0")
ENDIF()
set(BERKELEYDB_MAX_VER "6.1.36") # Last release ver before v6.2, which isn't compatible
find_package(BerkeleyDB ${BERKELEYDB_MIN_VER} REQUIRED)

# ~~ Threads ~~
IF(CMAKE_SYSTEM_NAME MATCHES "Windows")
  # Don't use pthreads on Windows (not POSIX)
  message(STATUS "${CMAKE_SYSTEM_NAME} detected, not using pthread...")
  set(THREADS_PREFER_PTHREAD_FLAG OFF)
ELSE()
  # Tells find_package(Threads) to get pthread.h & use -lpthread compile flag
  message(STATUS "${CMAKE_SYSTEM_NAME} detected, using pthread...")
  set(THREADS_PREFER_PTHREAD_FLAG ON)
ENDIF()
find_package(Threads REQUIRED) # pthread not needed specificly, code uses #include <thread>

# ~~ Max version checks after finding ~~
IF(OPENSSL_VERSION VERSION_GREATER ${OPENSSL_MAX_VER})
  message(FATAL_ERROR "The detected OpenSSL v${OPENSSL_VERSION} isn't compatible! Maximum of v${OPENSSL_MAX_VER} is compatible.")
ENDIF()

IF(BERKELEYDB_VERSION VERSION_GREATER "${BERKELEYDB_MAX_VER}")
  message(FATAL_ERROR "The detected BerkeleyDB v${BERKELEYDB_VERSION} isn't compatible! Maximum of v${BERKELEYDB_MAX_VER} is compatible.")
# Throw a warning if the user has DB ver < 6 but continue building
ELSEIF(BERKELEYDB_VERSION VERSION_LESS "6.0.0")
  message(WARNING "Pre-existing wallet data is not backwards compatible with version v5 of Berkeley DB if it was originally built with v6. \n
    Read \"docs/BUILDING.md\" for more info.")
ENDIF()
