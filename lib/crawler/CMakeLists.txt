cmake_minimum_required(VERSION 3.0.0 FATAL_ERROR)

# Like an include guard so we don't rebuild
IF(_VCASH_LIBCRAWLER_ALREADY_BUILT)
	return()
ELSE()
	set(_VCASH_LIBCRAWLER_ALREADY_BUILT true)
ENDIF()

# Should proably have a version
project(crawler LANGUAGES CXX)

add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/../database" "${CMAKE_CURRENT_BINARY_DIR}/database")

vcash_library_template("crawler"
	"${CMAKE_CURRENT_SOURCE_DIR}/src"
	"peer.hpp;stack.hpp;http_transport.hpp;database_stack.hpp;logger.hpp;probe_manager.hpp;stack_impl.hpp"
	"stack.cpp;probe_manager.cpp;database_stack.cpp;stack_impl.cpp;http_transport.cpp"
)

target_include_directories(crawler
  PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
  PUBLIC $<INSTALL_INTERFACE:src>
)

target_link_libraries(crawler
	PRIVATE database
)

install_and_export(crawler)
