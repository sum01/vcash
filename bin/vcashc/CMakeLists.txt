cmake_minimum_required(VERSION 3.0.0 FATAL_ERROR)
project(vcashc VERSION 0.0.1 LANGUAGES CXX)

# Build libcoin
add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/../../lib/crawler" "${CMAKE_CURRENT_BINARY_DIR}/crawler")

# Create vcashd
add_executable(vcashc main.cpp)

# Link to the lib
target_link_libraries(vcashc
	PRIVATE crawler
)

install_and_export(vcashc)
