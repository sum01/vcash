# Installs the executable and rpc script

# Set paths if none detected, as they don't seem to default correctly
IF(NOT CMAKE_INSTALL_BINDIR)
  set(CMAKE_INSTALL_BINDIR bin)
ENDIF()
IF(NOT CMAKE_INSTALL_LIBDIR)
  set(CMAKE_INSTALL_LIBDIR lib)
ENDIF()

foreach(_exe_name ${_VCASH_EXE})
  # Gives "Make install" esque operations a location to install to...
  # and creates a .cmake files for other projects to import.
  install(TARGETS ${_exe_name}
    EXPORT "${_exe_name}-targets"
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
  )

  # "The install(TARGETS) and install(EXPORT) commands work together to install a target and a file to help import it"
  # Installs the Vcash.cmake file which external projects can import.
  # This will point towards the pre-compiled binary after installation, but be treated as if it had been compiled inside the external project.
  install(EXPORT "${_exe_name}-targets"
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/Vcash" # ex: /usr/lib/cmake/Vcash/Vcash-targets.cmake
  )

  # "The export command is used to generate a file exporting targets from a project build tree"
  # Creates an import file for external projects which are aware of the build tree.
  # This will not be installed, and is only usefull in certain situations.
  export(TARGETS ${_exe_name}
    FILE "${_exe_name}-exports.cmake"
  )
endforeach()

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
