# Builds the database library
# Add/delete paths to .cpp files when more are created/deleted.

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

target_link_libraries(database
  PUBLIC ${Boost_LIBRARIES}
  PUBLIC ${OPENSSL_LIBRARIES}
  PUBLIC Threads::Threads
)

target_include_directories(database
  PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include/database>
  PUBLIC $<INSTALL_INTERFACE:include/database>
  PUBLIC ${Boost_INCLUDE_DIRS}
  PUBLIC ${OPENSSL_INCLUDE_DIR}
)

set_target_properties(database PROPERTIES OUTPUT_NAME "xvc-database")

IF(VCASH_INSTALL_LIBS)
	install_and_export("database")
ENDIF()
