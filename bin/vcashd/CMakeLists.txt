cmake_minimum_required(VERSION 3.0.0 FATAL_ERROR)

# Get version string from constants.hpp
file(STRINGS "../../lib/coin/src/constants.hpp" _VCASH_CONSTANTS)
# Using a temperary version var, as the correct project variables are auto-filled after project()
string(REGEX REPLACE ".*version_string = \"([0-9]+).([0-9]+).([0-9]+).([0-9]+)\".*" "\\1.\\2.\\3.\\4" _VCASH_VERSION "${_VCASH_CONSTANTS}")

project(vcashd VERSION ${_VCASH_VERSION} LANGUAGES C CXX)

# Build libcoin
add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/../../lib/coin" "${CMAKE_CURRENT_BINARY_DIR}/coin")

# Create vcashd
add_executable(vcashd main.cpp)

# Link to the lib
target_link_libraries(vcashd
	PRIVATE coin
)

install_and_export(vcashd)

IF(NOT CMAKE_SYSTEM_NAME STREQUAL "Windows")
	# look for vcashrpc deps
	foreach(_vcash_found_program "bash" "curl" "jq")
		find_program(_temp_found_program
			NAMES ${_vcash_found_program}
		)
		IF(NOT _vcash_found_program)
			message(STATUS "Not installing vcashrpc since some/all necessary dependencies are missing.")
			return()
		ENDIF()
	endforeach()

	# If all found, we install
	message(STATUS "The vcashrpc script will be installed.")

	install(FILES vcashrpc
		PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE # Basically chmod 755
		DESTINATION "${CMAKE_INSTALL_BINDIR}"
	)
ENDIF()
