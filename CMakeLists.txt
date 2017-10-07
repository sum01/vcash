CMAKE_MINIMUM_REQUIRED(VERSION 3.1)
# == START Minimum version requirement list ==
# 3.0 for versioning inside of project()
# 3.1 for THREADS_PREFER_PTHREAD_FLAG | CMAKE_CXX_STANDARD | CMAKE_CXX_STANDARD_REQUIRED
# EVENTUALLY: 3.9 for the addition of a DESCRIPTION to project()
# == END Minimum version requirement list ==
#
# For cross-compiling, read https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html#cross-compiling-toolchain ...
# and when cross-compiling for Windows, use the Cmake flag -D_WIN32_WINNT=XXXXX | literal format expected, ex: "0x0501" ...
# Accepted values for _WIN32_WINNT are here https://docs.microsoft.com/en-us/cpp/porting/modifying-winver-and-win32-winnt
#
# Use -DBUILD_VCASH_CRAWLER=ON to build the crawler (OFF by default)
# Use -DBUILD_VCASH_DATABASE=ON to build to database (OFF by default)
# Use -DBUILD_VCASH_DAEMON=OFF to NOT build the daemon (ON by default)

# Get version string from constants.hpp
file(STRINGS "coin/include/coin/constants.hpp" _VCASH_CONSTANTS)
# Using a temperary version var, as the correct project variables are auto-filled after project()
string(REGEX REPLACE ".*version_string = \"([0-9]+).([0-9]+).([0-9]+).([0-9]+)\".*" "\\1.\\2.\\3.\\4" _VCASH_VERSION "${_VCASH_CONSTANTS}")

project(Vcash VERSION "${_VCASH_VERSION}" LANGUAGES C CXX)
message(STATUS "Starting Cmake build of ${CMAKE_PROJECT_NAME} v${PROJECT_VERSION}")

# Require/Build for C++11
# Consider changing to target_compile_features in the future. Links below for feature lists...
# https://cmake.org/cmake/help/latest/prop_gbl/CMAKE_C_KNOWN_FEATURES.html#prop_gbl:CMAKE_C_KNOWN_FEATURES
# https://cmake.org/cmake/help/latest/prop_gbl/CMAKE_CXX_KNOWN_FEATURES.html#prop_gbl:CMAKE_CXX_KNOWN_FEATURES
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Set build-type options
IF(CMAKE_CONFIGURATION_TYPES)
  # Sets the available build options for multi-config build systems
  set(CMAKE_CONFIGURATION_TYPES "Debug;Release" CACHE STRING "Available build types." FORCE)
ELSEIF(NOT CMAKE_BUILD_TYPE)
    message(STATUS "Defaulting to Release build type since nothing was specified.")
    # Sets the build type to Release (if not specified) on single-config build systems
    set(CMAKE_BUILD_TYPE Release)
ENDIF()

# Flags to tell cmake which targets you want to build
option(BUILD_VCASH_DAEMON "Build the Vcash daemon executable." ON)
option(BUILD_VCASH_CRAWLER "Build the Vcash crawler executable." OFF)
option(BUILD_VCASH_DATABASE "Build the Vcash database executable." OFF)
# Fail if no targets are selected
IF(NOT BUILD_VCASH_DAEMON AND NOT BUILD_VCASH_CRAWLER AND NOT BUILD_VCASH_DATABASE)
  message(FATAL_ERROR "You did not select to build any executables, stopping the build.")
ELSE()
  # Notify which targets will be built
  message(STATUS "${CMAKE_PROJECT_NAME} exectuable build targets:")
  message(STATUS "  Daemon | ${BUILD_VCASH_DAEMON}")
  message(STATUS "  Crawler | ${BUILD_VCASH_CRAWLER}")
  message(STATUS "  Database | ${BUILD_VCASH_DATABASE}")
ENDIF()

# Adds our custom find_package modules to the list of modules available for cmake
list(APPEND CMAKE_MODULE_PATH "cmake/modules")
# Runs find_package() commands and checks if versions are compatible
include(vcash_dependencies)
# Adds our list of custom definitions to the compiler definitions to correctly build Vcash
include(vcash_definitions)

# Build libdatabase | All executables use libdatabase, so we declare outside IF() checks
add_subdirectory(database)

IF(BUILD_VCASH_DAEMON)
  # Build libcoin
  add_subdirectory(coin)

  set(_VCASH_DAEMON_NAME "vcashd")
  list(APPEND _VCASH_INSTALL_TARGETS "${_VCASH_DAEMON_NAME}")

  add_executable(${_VCASH_DAEMON_NAME} coin/test/main.cpp)

  target_link_libraries(${_VCASH_DAEMON_NAME}
    PUBLIC coin
    PUBLIC database
  )
ENDIF()

IF(BUILD_VCASH_CRAWLER)
  # Build libcrawler
  add_subdirectory(crawler)

  set(_VCASH_CRAWLER_NAME "vcashc")
  list(APPEND _VCASH_INSTALL_TARGETS "${_VCASH_CRAWLER_NAME}")

  add_executable(${_VCASH_CRAWLER_NAME} crawler/test/stack.cpp)

  target_link_libraries(${_VCASH_CRAWLER_NAME}
    PUBLIC crawler
    PUBLIC database
  )
ENDIF()

IF(BUILD_VCASH_DATABASE)
  # Doesn't require any other libs (libdatabase was already built above)

  set(_VCASH_DATABASE_NAME "vcashdb")
  list(APPEND _VCASH_INSTALL_TARGETS "${_VCASH_DATABASE_NAME}")

  add_executable(${_VCASH_DATABASE_NAME} database/test/stack.cpp)

  target_link_libraries(${_VCASH_DATABASE_NAME}
    PUBLIC database
  )
ENDIF()

# Runs the install script
include(vcash_install)

# Consider adding the following functions..
# add_test https://cmake.org/cmake/help/latest/command/add_test.html If added, then TravisCI needs `make test` added to `.travis.yml`
