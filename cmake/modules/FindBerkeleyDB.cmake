# FindBerkeleyDB
# Version 1.0.1.1
# Finds the BerkeleyDB includes and libraries (`db` `db_cxx` `db_stl` `db_sql`). A minimum of one of the libs is required, or it fails.
#
# Output variables to be used in CMakeLists.txt
# ^^^^^^^^^^^
# BERKELEYDB_INCLUDE_DIRS
# BERKELEYDB_LIBRARIES
# BERKELEYDB_VERSION
# BERKELEYDB_MAJOR_VERSION
# BERKELEYDB_MINOR_VERSION
# BERKELEYDB_PATCH_VERSION
#
# User-passable values to be set with CMake commands
# ^^^^^^^^^^^^^^^^^^^^
# BERKELEYDB_ROOT
# BERKELEYDB_LIBNAME
# BERKELEYDB_CXX_LIBNAME
# BERKELEYDB_STL_LIBNAME
# BERKELEYDB_SQL_LIBNAME
#
# If all else fails, set whichever of these is failing manually with CMake commands
# ^^^^^^^^^^^^^^^^^^^^
# BERKELEYDB_INCLUDE_DIRS
# BERKELEYDB_LIB
# BERKELEYDB_CXX_LIB
# BERKELEYDB_STL_LIB
# BERKELEYDB_SQL_LIB

# TODO: If Berkeley DB ever gets a Pkg-config ".pc" file, add pkg_check_modules() here

# HINTS don't change across OS's
# Checks if evnironment paths are empty, set them if they aren't
IF(NOT "$ENV{BERKELEYDB_ROOT}" STREQUAL "")
  set(_BDB_HINTS "$ENV{BERKELEYDB_ROOT}")
ELSEIF(NOT "$ENV{BERKELEYDBROOT}" STREQUAL "")
  set(_BDB_HINTS "$ENV{BERKELEYDBROOT}")
ELSE()
  # Set empty just in case..
  set(_BDB_HINTS "")
ENDIF()

# Allow user to pass a path instead of guessing
IF(BERKELEYDB_ROOT)
  list(APPEND _BDB_PATHS "${BERKELEYDB_ROOT}")
ENDIF()
# Default paths to search for Berkeley DB, regardless of root path
IF(CMAKE_SYSTEM_NAME MATCHES "Windows")
  # Shameless copy-paste from FindOpenSSL.cmake v3.8
  file(TO_CMAKE_PATH "$ENV{PROGRAMFILES}" _programfiles)
  list(APPEND _BDB_HINTS "${_programfiles}")

  # There's actually production release and version numbers in the file path.
  # For example, if they're on v6.2.32: C:/Program Files/Oracle/Berkeley DB 12cR1 6.2.32/
  # But this still works to find it. It probably doesn't read past "Berkeley DB" is my guess.
  list(APPEND _BDB_PATHS
    "${_programfiles}/Oracle/Berkeley DB"
    "${_programfiles}/Berkeley DB"
    "C:/Program Files (x86)/Oracle/Berkeley DB"
    "C:/Program Files (x86)/Berkeley DB"
    "C:/Program Files/Oracle/Berkeley DB"
    "C:/Program Files/Berkeley DB"
    "C:/Oracle/Berkeley DB"
    "C:/Berkeley DB"
  )
ELSE()
  # Paths for anything other than Windows
  # Cellar/berkeley-db is for macOS from homebrew installation
  list(APPEND _BDB_PATHS
    "/usr"
    "/usr/local"
    "/usr/local/Cellar/berkeley-db"
    "/opt"
    "/opt/local"
  )
ENDIF()

# Find includes path | This is passed directly to CMakeLists.txt without moving it into a different var.
find_path(BERKELEYDB_INCLUDE_DIRS
  NAMES "db.h" "db_cxx.h"
  HINTS ${_BDB_HINTS}
  PATH_SUFFIXES "include" "includes"
  PATHS ${_BDB_PATHS}
)

# Checks if the version file exists, save the version file to a var, and fail if there's no version file
IF(BERKELEYDB_INCLUDE_DIRS AND EXISTS "${BERKELEYDB_INCLUDE_DIRS}/db.h")
  set(_BERKELEYDB_VERSION_file "${BERKELEYDB_INCLUDE_DIRS}/db.h")
ELSE()
  message(FATAL_ERROR "Failed to find the Berkeley DB header file \"db.h\"! Try setting \"BERKELEYDB_ROOT\".")
ENDIF()

# Read the version file db.h into a variable
file(READ ${_BERKELEYDB_VERSION_file} _BERKELEYDB_header_contents)
# Parse the DB version into variables to be used in the lib names
string(REGEX REPLACE ".*DB_VERSION_MAJOR	([0-9]+).*" "\\1" BERKELEYDB_MAJOR_VERSION "${_BERKELEYDB_header_contents}")
string(REGEX REPLACE ".*DB_VERSION_MINOR	([0-9]+).*" "\\1" BERKELEYDB_MINOR_VERSION "${_BERKELEYDB_header_contents}")
string(REGEX REPLACE ".*DB_VERSION_PATCH	([A-Z0-9]+).*" "\\1" BERKELEYDB_PATCH_VERSION "${_BERKELEYDB_header_contents}") # Patch ver is x.x.xNC for non-crypto installs
set(BERKELEYDB_VERSION "${BERKELEYDB_MAJOR_VERSION}.${BERKELEYDB_MINOR_VERSION}.${BERKELEYDB_PATCH_VERSION}") # The output version var

# Function to set the various libnames in the variables used in find_library.
# output_var should be the actual var name used in find_library commands.
# target_db is the base lib name (e.g. "db" for libdb, or "db_cxx" for libdb_cxx).
function(set_db_names output_var target_db)
  # Different systems sometimes have a version in the lib name...
  # and some have a dash or underscore before the versions.
  # CMake recommends to put unversioned names before versioned names
  list(APPEND _libname_list
    "${target_db}"
    "lib${target_db}"
    "lib${target_db}${BERKELEYDB_MAJOR_VERSION}.${BERKELEYDB_MINOR_VERSION}"
    "lib${target_db}-${BERKELEYDB_MAJOR_VERSION}.${BERKELEYDB_MINOR_VERSION}"
    "lib${target_db}_${BERKELEYDB_MAJOR_VERSION}.${BERKELEYDB_MINOR_VERSION}"
    "lib${target_db}${BERKELEYDB_MAJOR_VERSION}${BERKELEYDB_MINOR_VERSION}"
    "lib${target_db}-${BERKELEYDB_MAJOR_VERSION}${BERKELEYDB_MINOR_VERSION}"
    "lib${target_db}_${BERKELEYDB_MAJOR_VERSION}${BERKELEYDB_MINOR_VERSION}"
    "lib${target_db}${BERKELEYDB_MAJOR_VERSION}"
    "lib${target_db}-${BERKELEYDB_MAJOR_VERSION}"
    "lib${target_db}_${BERKELEYDB_MAJOR_VERSION}"
  )
  # CMake's version of a return statement..
  # but declares scope outside of the function, as all functions use local scope by default
  set(${output_var} "${_libname_list}" PARENT_SCOPE)
endfunction()

# Library search suffixes | aka /usr/${_BDB_L_SUF} if searching /usr
# Only using a var for this because it's reused multiple times
list(APPEND _BDB_L_SUF
  "lib"
  "libs"
  "lib64"
  "libs64"
)

# Checks for if the user used custom flags for the library names...
# else uses function to set db libnames used in find_library() calls.
IF(BERKELEYDB_LIBNAME)
  list(APPEND _BDB_LIBNAMES "${BERKELEYDB_LIBNAME}")
ELSE()
  set_db_names(_BDB_LIBNAMES "db")
ENDIF()
# Find libdb | Moved into BERKELEYDB_LIBRARIES eventually
find_library(BERKELEYDB_LIB
  NAMES ${_BDB_LIBNAMES}
  HINTS ${_BDB_HINTS}
  PATH_SUFFIXES ${_BDB_L_SUF}
  PATHS ${_BDB_PATHS}
)

IF(BERKELEYDB_CXX_LIBNAME)
  list(APPEND _BDB_CXX_LIBNAMES "${BERKELEYDB_CXX_LIBNAME}")
ELSE()
  set_db_names(_BDB_CXX_LIBNAMES "db_cxx")
ENDIF()
# Find libdb_cxx | Moved into BERKELEYDB_LIBRARIES eventually
find_library(BERKELEYDB_CXX_LIB
  NAMES ${_BDB_CXX_LIBNAMES}
  HINTS ${_BDB_HINTS}
  PATH_SUFFIXES ${_BDB_L_SUF}
  PATHS ${_BDB_PATHS}
)

IF(BERKELEYDB_STL_LIBNAME)
  list(APPEND _BDB_STL_LIBNAMES "${BERKELEYDB_STL_LIBNAME}")
ELSE()
  set_db_names(_BDB_STL_LIBNAMES "db_stl")
ENDIF()
# Find libdb_stl | Moved into BERKELEYDB_LIBRARIES eventually
find_library(BERKELEYDB_STL_LIB
  NAMES ${_BDB_STL_LIBNAMES}
  HINTS ${_BDB_HINTS}
  PATH_SUFFIXES ${_BDB_L_SUF}
  PATHS ${_BDB_PATHS}
)

IF(BERKELEYDB_SQL_LIBNAME)
  list(APPEND _BDB_SQL_LIBNAMES "${BERKELEYDB_SQL_LIBNAME}")
ELSE()
  set_db_names(_BDB_SQL_LIBNAMES "db_sql")
ENDIF()
# Find libdb_sql | Moved into BERKELEYDB_LIBRARIES eventually
find_library(BERKELEYDB_SQL_LIB
  NAMES ${_BDB_SQL_LIBNAMES}
  HINTS ${_BDB_HINTS}
  PATH_SUFFIXES ${_BDB_L_SUF}
  PATHS ${_BDB_PATHS}
)

# Set found library path(s) into BERKELEYDB_LIBRARIES to be used in CMakeLists.txt
IF(BERKELEYDB_LIB)
  list(APPEND BERKELEYDB_LIBRARIES ${BERKELEYDB_LIB})
ELSE()
  message(STATUS "Berkeley DB's \"libdb\" was not found! Try setting \"BERKELEYDB_LIBNAME\" if needed.")
ENDIF()
IF(BERKELEYDB_CXX_LIB)
  list(APPEND BERKELEYDB_LIBRARIES ${BERKELEYDB_CXX_LIB})
ELSE()
  message(STATUS "Berkeley DB's \"libdb_cxx\" was not found! Try setting \"BERKELEYDB_CXX_LIBNAME\" if needed.")
ENDIF()
IF(BERKELEYDB_STL_LIB)
  list(APPEND BERKELEYDB_LIBRARIES ${BERKELEYDB_STL_LIB})
ELSE()
  message(STATUS "Berkeley DB's \"libdb_stl\" was not found! Try setting \"BERKELEYDB_STL_LIBNAME\" if needed.")
ENDIF()
IF(BERKELEYDB_SQL_LIB)
  list(APPEND BERKELEYDB_LIBRARIES ${BERKELEYDB_SQL_LIB})
ELSE()
  message(STATUS "Berkeley DB's \"libdb_sql\" was not found! Try setting \"BERKELEYDB_SQL_LIBNAME\" if needed.")
ENDIF()

# Fails if required vars aren't found, or if the version doesn't meet specifications.
# "FOUND_VAR is obsolete and only for older versions of cmake."
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(BerkeleyDB
  FOUND_VAR BERKELEYDB_FOUND
  REQUIRED_VARS BERKELEYDB_INCLUDE_DIRS BERKELEYDB_LIBRARIES
  VERSION_VAR BERKELEYDB_VERSION
)

# This loops through each found library and shows them in a more readable format.
# Get the list length
list(LENGTH BERKELEYDB_LIBRARIES _BDB_LENGTH)
IF(_BDB_LENGTH GREATER 0)
  # Minus 1 on index length to avoid out-of-bounds
  math(EXPR _BDB_LENGTH "${_BDB_LENGTH}-1")
ENDIF()
# Pre-loop message
message(STATUS "Found the following Berkeley DB libraries:")
# Loop with a range of the list length
foreach(_loopcount RANGE 0 ${_BDB_LENGTH})
  # Get the current index item into a var
  list(GET BERKELEYDB_LIBRARIES ${_loopcount} _BDB_INDEX_ITEM)
  # Gets basename of current index item
  get_filename_component(_BDB_INDEX_ITEM_BASENAME "${_BDB_INDEX_ITEM}" NAME)
  # Output library basename, and path without library name, of index item
  message(STATUS "  ${_BDB_INDEX_ITEM_BASENAME}")
endforeach()
