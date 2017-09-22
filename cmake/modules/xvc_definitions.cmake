# Compiler definitions kept in a separate module for neatness

# I believe this makes the binary 64-bit only, which should be noted somewhere...
set(_xvc_definitions "-D_FILE_OFFSET_BITS=64")

IF(CMAKE_BUILD_TYPE STREQUAL "Release")
  message(STATUS "Setting build flag for \"Release\" build-type.")
  list(APPEND _xvc_definitions "-DNDEBUG")
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

  list(APPEND _xvc_definitions
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
  list(APPEND _xvc_definitions "-DBOOST_NO_CXX11_NUMERIC_LIMITS")
# GCC compiler
ELSEIF(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" AND CMAKE_BUILD_TYPE STREQUAL "Release")
  message(STATUS "GCC compiler detected, setting definitions.")
  # 02 optimization required to build on GCC >= v6, otherwise it fails
  list(APPEND _xvc_definitions "-O2")
ENDIF()

# Set all our various definitions
message(STATUS "List of definitions to be used (delimited by semi-colon): ${_xvc_definitions}")
add_definitions(${_xvc_definitions})
