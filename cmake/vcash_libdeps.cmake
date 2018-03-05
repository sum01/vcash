function(vcash_max_dep_version dep_name check_ver max_ver)
	IF(${check_ver} VERSION_GREATER ${max_ver})
		message(FATAL_ERROR "Detected ${dep_name} v${check_ver}, which isn't compatible! Maximum of v${max_ver} is compatible.")
	ENDIF()
endfunction()

include(FindBerkeleyDB)
include(install_and_export)

# Allow for shared libs
option(BUILD_SHARED_LIBS "Compile shared libraries instead of static." OFF)

# Creates a vcash library from passed values
function(vcash_library_template _xvc_lib_name _xvc_parent_src_dir _xvc_lib_headers _xvc_lib_sources)
	# Appends absolute paths to headers
	foreach(_current_raw_header ${_xvc_lib_headers})
		list(APPEND _VCASH_LIB_HEADERS
		"${_xvc_parent_src_dir}/${_current_raw_header}"
		)
	endforeach()
	# Appends absolute paths to sources
	foreach(_current_raw_src ${_xvc_lib_sources})
		list(APPEND _VCASH_LIB_SOURCES
		"${_xvc_parent_src_dir}/${_current_raw_src}"
		)
	endforeach()

	# Builds the library
	add_library(${_xvc_lib_name} ${_VCASH_LIB_SOURCES})

	# Adds its headers for install
	set_target_properties(${_xvc_lib_name} PROPERTIES
		PUBLIC_HEADER ${_VCASH_LIB_HEADERS})
endfunction()
