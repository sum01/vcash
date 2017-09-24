CMAKE_MINIMUM_REQUIRED(VERSION 3.1)
# == START Minimum version requirement list ==
# 3.0 for versioning inside of project()
# 3.1 for THREADS_PREFER_PTHREAD_FLAG | CMAKE_CXX_STANDARD | CMAKE_CXX_STANDARD_REQUIRED
# EVENTUALLY: 3.9 for the addition of a DESCRIPTION to project()
# == END Minimum version requirement list ==
#
# For cross-compiling, read https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html#cross-compiling-toolchain
# Use -DBUILD_VCASH_CRAWLER=ON to build the crawler (OFF by default)
# Use -DBUILD_VCASH_DAEMON=OFF to NOT build the daemon (ON by default)

# Get version string from constants.hpp
file(STRINGS "coin/include/coin/constants.hpp" _VCASH_CONSTANTS)
string(REGEX REPLACE ".*version_string = \"([0-9]+).([0-9]+).([0-9]+).([0-9]+)\".*" "\\1.\\2.\\3.\\4" _VCASH_VERSION "${_VCASH_CONSTANTS}")

project(Vcash VERSION "${_VCASH_VERSION}" LANGUAGES C CXX)
message(STATUS "Starting Cmake build of ${CMAKE_PROJECT_NAME} v${PROJECT_VERSION}")

# Require/Build for C++11
# Consider changing to target_compile_features in the future. Links below for feature lists...
# https://cmake.org/cmake/help/latest/prop_gbl/CMAKE_C_KNOWN_FEATURES.html#prop_gbl:CMAKE_C_KNOWN_FEATURES
# https://cmake.org/cmake/help/latest/prop_gbl/CMAKE_CXX_KNOWN_FEATURES.html#prop_gbl:CMAKE_CXX_KNOWN_FEATURES
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Set system-specific settings
IF(CMAKE_CONFIGURATION_TYPES)
  # Lists the available build options
  set(CMAKE_CONFIGURATION_TYPES "Debug;Release" CACHE STRING "Available build types." FORCE)
ELSEIF(NOT CMAKE_BUILD_TYPE)
    # Default to a release build if nothing is specified
    message(STATUS "Defaulting to Release build type since nothing was specified.")
    set(CMAKE_BUILD_TYPE Release)
ENDIF()

# Flags to tell cmake which targets you want to build
option(BUILD_VCASH_DAEMON "Builds the Vcash daemon." ON)
option(BUILD_VCASH_CRAWLER "Builds the Vcash crawler." OFF)
# Fail if no targets are selected
IF(NOT BUILD_VCASH_DAEMON AND NOT BUILD_VCASH_CRAWLER)
  message(FATAL_ERROR "You did not select to build the daemon or crawler, stopping the build.")
ELSE()
  # Notify which targets will be built
  message(STATUS "${CMAKE_PROJECT_NAME} build targets:")
  message(STATUS "  Daemon | ${BUILD_VCASH_DAEMON}")
  message(STATUS "  Crawler | ${BUILD_VCASH_CRAWLER}")
ENDIF()

# Adds our custom find_package modules to the list of modules available for cmake
list(APPEND CMAKE_MODULE_PATH "cmake/modules")
include(xvc_dependencies)
include(xvc_definitions)

# Both daemon & crawler use libdatabase
add_subdirectory(database)

IF(BUILD_VCASH_DAEMON)
  add_subdirectory(coin)

  add_executable(vcashd coin/test/main.cpp)
  list(APPEND _VCASH_EXE "vcashd") # Name of target to install in xvc_install.cmake

  # FIXME: Threads::Threads seems to always trigger a quiet cmake error on Windows, but it doesn't break the build..
  # This links all our libs to vcashd.
  target_link_libraries(vcashd
    PUBLIC coin
    PUBLIC database
  )
ENDIF()

IF(BUILD_VCASH_CRAWLER)
  add_subdirectory(crawler)

  add_executable(vcashc crawler/test/stack.cpp)
  list(APPEND _VCASH_EXE "vcashc") # Name of target to install in xvc_install.cmake

  target_link_libraries(vcashc
    PUBLIC crawler
    PUBLIC database
  )
ENDIF()

# Runs the install script
include(xvc_install)

# Consider adding the following functions..
# add_test https://cmake.org/cmake/help/latest/command/add_test.html If added, then TravisCI needs `make test` added to `.travis.yml`
