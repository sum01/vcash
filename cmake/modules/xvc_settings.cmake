# Call this module right after the project() in any CMakeLists.txt to set the generic settings

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

# Set paths if none detected, as they don't seem to default correctly
# bin and lib are not OS-specific, but generic names for cmake
IF(NOT CMAKE_INSTALL_BINDIR)
  set(CMAKE_INSTALL_BINDIR bin)
ENDIF()
IF(NOT CMAKE_INSTALL_LIBDIR)
  set(CMAKE_INSTALL_LIBDIR lib)
ENDIF()

set(VCASH_SETTINGS_SET TRUE)
