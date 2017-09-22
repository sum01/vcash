CMAKE_MINIMUM_REQUIRED(VERSION 3.1)
# == START Minimum version requirement list ==
# 3.0 for versioning inside of project()
# 3.1 for THREADS_PREFER_PTHREAD_FLAG | CMAKE_CXX_STANDARD | CMAKE_CXX_STANDARD_REQUIRED
# EVENTUALLY: 3.9 for the addition of a DESCRIPTION to project()
# == END Minimum version requirement list ==
#
# For cross-compiling, read https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html#cross-compiling-toolchain

# Get version string from constants.hpp
file(STRINGS "coin/include/coin/constants.hpp" _VCASH_CONSTANTS)
string(REGEX REPLACE ".*version_string = \"([0-9]+).([0-9]+).([0-9]+).([0-9]+)\".*" "\\1.\\2.\\3.\\4" _VCASH_VERSION "${_VCASH_CONSTANTS}")

project(Vcash VERSION "${_VCASH_VERSION}" LANGUAGES C CXX)
message(STATUS "Starting cmake build of Vcash v${PROJECT_VERSION}")

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

# Adds our custom find_package modules to the list of modules available for cmake
list(APPEND CMAKE_MODULE_PATH "cmake/modules")
# Prepending xvc_ onto module names to avoid clashing with potentially pre-existing Cmake modules.
# This technically isn't needed, but is used to keep the main CMakeLists clean.
include(xvc_dependencies)
include(xvc_definitions)

# Triggers the CMakeLists.txt in coin/ and database/
add_subdirectory(coin) # libcoin
add_subdirectory(database) # libdatabase

add_executable(vcashd coin/test/main.cpp)

# FIXME: Threads::Threads seems to always trigger a quiet cmake error on Windows, but it doesn't break the build..
# This links all our libs to vcashd.
target_link_libraries(vcashd
  PUBLIC coin
  PUBLIC database
  PRIVATE ${BERKELEYDB_LIBRARIES}
  PRIVATE ${OPENSSL_LIBRARIES}
  PRIVATE ${Boost_LIBRARIES}
  PRIVATE Threads::Threads
)

# Set paths if none detected, as they don't seem to default correctly
IF(NOT CMAKE_INSTALL_BINDIR)
  set(CMAKE_INSTALL_BINDIR bin)
ENDIF()
IF(NOT CMAKE_INSTALL_LIBDIR)
  set(CMAKE_INSTALL_LIBDIR lib)
ENDIF()

# Gives "Make install" esque operations a location to install to...
# and creates a .cmake files for other projects to import.
install(TARGETS vcashd
  EXPORT "${CMAKE_PROJECT_NAME}-targets"
  RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
)

# "The install(TARGETS) and install(EXPORT) commands work together to install a target and a file to help import it"
# Installs the Vcash.cmake file which external projects can import.
# This will point towards the pre-compiled binary after installation, but be treated as if it had been compiled inside the external project.
install(EXPORT "${CMAKE_PROJECT_NAME}-targets"
  DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${CMAKE_PROJECT_NAME}" # ex: /usr/lib/cmake/Vcash/Vcash-targets.cmake
)

# "The export command is used to generate a file exporting targets from a project build tree"
# Creates an import file for external projects which are aware of the build tree.
# This will not be installed, and is only usefull in certain situations.
export(TARGETS vcashd
  FILE "${CMAKE_PROJECT_NAME}-exports.cmake"
)

# Installs vcashrpc if not on Windows
IF(CMAKE_SYSTEM_NAME MATCHES "Windows")
  message(STATUS "The RPC script will not be installed because you are on a Windows machine.")
ELSE()
  install(FILES vcashrpc
    PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE # Basically chmod 755
    DESTINATION "${CMAKE_INSTALL_BINDIR}"
  )
ENDIF()

# TODO: Add a Windows batch/powershell RPC script, uncomment this, and delete the currently used install(FILES)
#IF(CMAKE_SYSTEM_NAME MATCHES "Windows")
#  set(_VCASH_RPC_NAME "vcashrpc.ps")
#ELSE()
#  set(_VCASH_RPC_NAME "vcashrpc")
#ENDIF()
#install(FILES ${_VCASH_RPC_NAME}
#  PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_EXECUTE
#  DESTINATION "${CMAKE_INSTALL_BINDIR}"
#)

# Consider adding the following functions..
# add_test https://cmake.org/cmake/help/latest/command/add_test.html If added, then TravisCI needs `make test` added to `.travis.yml`
