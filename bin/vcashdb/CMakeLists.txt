cmake_minimum_required(VERSION 3.0.0 FATAL_ERROR)
project(vcashdb VERSION 0.0.1 LANGUAGES C CXX)

# Build libcoin
add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/../../lib/database" "${CMAKE_CURRENT_BINARY_DIR}/database")

# Create vcashd
add_executable(vcashdb main.cpp)

# Link to the lib
target_link_libraries(vcashdb
	PRIVATE database
)

install_and_export(vcashdb)
