CMAKE_MINIMUM_REQUIRED(VERSION 3.1.3)

project(Libdatabase LANGUAGES C CXX)

IF(NOT VCASH_MODPATH_SET)
  list(APPEND CMAKE_MODULE_PATH "../cmake/modules")
  set(VCASH_MODPATH_SET TRUE)
ENDIF()
IF(NOT VCASH_SETTINGS_SET)
  include(xvc_settings)
ENDIF()
IF(NOT VCASH_DEPS_SET)
  include(xvc_dependencies)
ENDIF()
IF(NOT VCASH_DEFS_SET)
  include(xvc_definitions)
ENDIF()

add_library(database STATIC
  src/block.cpp
  src/broadcast_operation.cpp
  src/compression.cpp
  src/ecdhe.cpp
  src/entry.cpp
  src/find_operation.cpp
  src/hc256.cpp
  src/key_pool.cpp
  src/message.cpp
  src/node.cpp
  src/node_impl.cpp
  src/operation.cpp
  src/operation_queue.cpp
  src/ping_operation.cpp
  src/query.cpp
  src/routing_table.cpp
  src/rpc.cpp
  src/slot.cpp
  src/stack.cpp
  src/stack_impl.cpp
  src/storage.cpp
  src/store_operation.cpp
  src/udp_handler.cpp
  src/udp_multiplexor.cpp
  src/whirlpool.cpp
)

target_include_directories(database
  PUBLIC include
  PUBLIC ${Boost_INCLUDE_DIRS}
  PUBLIC ${OPENSSL_INCLUDE_DIR}
)

install(TARGETS database ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}")
