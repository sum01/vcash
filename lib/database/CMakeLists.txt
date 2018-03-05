cmake_minimum_required(VERSION 3.1.0 FATAL_ERROR)

# Like an include guard so we don't rebuild
IF(_VCASH_LIBDATABASE_ALREADY_BUILT)
	return()
ELSE()
	set(_VCASH_LIBDATABASE_ALREADY_BUILT true)
ENDIF()

# Should proably have a version
project(database LANGUAGES CXX)

list(APPEND CMAKE_MODULE_PATH
	"${CMAKE_CURRENT_SOURCE_DIR}/../../cmake"
	"${CMAKE_CURRENT_SOURCE_DIR}/../../cmake/FindBerkeleyDB"
	"${CMAKE_CURRENT_SOURCE_DIR}/../../cmake/install_and_export"
)

include(vcash_libdeps)

find_package(Boost 1.54.0 COMPONENTS system REQUIRED)
# v1.66.0 removed a lot of previously working (but deprecated) things
# TODO: Remove when https://github.com/openvcash/vcash/issues/38 is fixed
vcash_max_dep_version("Boost" "${Boost_MAJOR_VERSION}.${Boost_MINOR_VERSION}.${Boost_SUBMINOR_VERSION}" "1.65.1")

# Do not set the letter ("status") version for OpenSSL!
find_package(OpenSSL "1.0.1" REQUIRED)
vcash_max_dep_version("OpenSSL" ${OPENSSL_VERSION} "1.0.2")

# Only default threads settings if none were passed by the user
IF(NOT CMAKE_USE_SPROC_INIT AND NOT CMAKE_USE_WIN32_THREADS_INIT AND NOT CMAKE_USE_PTHREADS_INIT AND NOT CMAKE_HP_PTHREADS_INIT AND NOT CMAKE_THREAD_PREFER_PTHREAD AND NOT THREADS_PREFER_PTHREAD_FLAG)
  IF(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    message(STATUS "${CMAKE_SYSTEM_NAME} detected, using WIN32 threads...")
    # Tells FindThreads to get the WIN32 threads
    set(CMAKE_USE_WIN32_THREADS_INIT ON)
  ELSE()
    # Tells find_package(Threads) to get pthread.h & use -lpthread compile flag
    message(STATUS "Non-Windows OS detected, defaulting to using pthreads...")
    set(THREADS_PREFER_PTHREAD_FLAG ON)
  ENDIF()
ENDIF()

# Code uses #include <thread>
find_package(Threads REQUIRED)

vcash_library_template("database"
	"${CMAKE_CURRENT_SOURCE_DIR}/src"
	"ecrypt-config.h;ecrypt-sync.h;udp_multiplexor.hpp;routing_table.hpp;udp_handler.hpp;stack.hpp;hc256.hpp;protocol.hpp;ecdhe.h;ecdhe.hpp;ecrypt-portable.h;network.hpp;utility.hpp;node.hpp;query.hpp;cpu.hpp;operation.hpp;slot.hpp;logger.hpp;message.hpp;random.hpp;store_operation.hpp;node_impl.hpp;handler.hpp;constants.hpp;storage.hpp;rpc.hpp;operation_queue.hpp;ecrypt-machine.h;broadcast_operation.hpp;entry.hpp;byte_buffer.hpp;crypto.hpp;key_pool.hpp;storage_node.hpp;compression.hpp;find_operation.hpp;ping_operation.hpp;stack_impl.hpp;block.hpp;whirlpool.hpp"
	"store_operation.cpp;compression.cpp;broadcast_operation.cpp;entry.cpp;stack.cpp;ping_operation.cpp;operation.cpp;node_impl.cpp;rpc.cpp;block.cpp;slot.cpp;query.cpp;hc256.cpp;udp_handler.cpp;storage.cpp;udp_multiplexor.cpp;find_operation.cpp;node.cpp;ecdhe.cpp;key_pool.cpp;message.cpp;operation_queue.cpp;stack_impl.cpp;routing_table.cpp;whirlpool.cpp"
)

target_link_libraries(database
  PUBLIC ${Boost_LIBRARIES}
  PUBLIC ${OPENSSL_LIBRARIES}
  PUBLIC Threads::Threads
)

target_include_directories(database
  PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
  PUBLIC $<INSTALL_INTERFACE:src>
  PUBLIC ${Boost_INCLUDE_DIRS}
  PUBLIC ${OPENSSL_INCLUDE_DIR}
)

install_and_export(database)
