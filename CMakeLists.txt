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

# Adds our custom find_package modules to the list of modules available for cmake
# Prepended xvc_ onto module names to avoid clashing with potentially pre-existing modules
IF(NOT VCASH_MODPATH_SET)
  list(APPEND CMAKE_MODULE_PATH "cmake/modules")
  set(VCASH_MODPATH_SET TRUE)
ENDIF()
IF(NOT VCASH_SETTINGS_SET)
  include(xvc_settings)
ENDIF()
IF(NOT VCASH_DEPS_SET)
  include(xvc_dependencies)
ENDIF()
IF(NOT VCASH_DEFS_SET)
  include(xvc_definitions)
ENDIF()

add_subdirectory(coin)
add_subdirectory(database)

add_executable(vcashd coin/test/main.cpp)

# Threads::Threads seems to always trigger a quiet cmake error on Windows, but it doesn't break the build..
# Unsure of a way around this, as we need the thread libs to build/run Vcash.
target_link_libraries(vcashd coin database ${BERKELEYDB_LIBRARIES} ${OPENSSL_LIBRARIES} ${Boost_LIBRARIES} Threads::Threads)

# ARCHIVE is for STATIC libs
install(TARGETS vcashd RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")

# Install vcashrpc if not Windows | Trying to avoid doing IF(UNIX) for cross-compiling
IF(NOT CMAKE_SYSTEM_NAME MATCHES "Windows")
  install(FILES vcashrpc
    PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE # Should be equivilent to chmod 755
    DESTINATION "${CMAKE_INSTALL_BINDIR}"
  )
ELSE()
  message(STATUS "The RPC script will not be installed because you are on a Windows machine.")
ENDIF()

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

# Consider adding the following functions..
# add_test https://cmake.org/cmake/help/latest/command/add_test.html If added, then TravisCI needs `make test` added to `.travis.yml`
# export https://cmake.org/cmake/help/latest/command/export.html Makes it easy for external CMake projects to import Vcash
