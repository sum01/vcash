# Builds the crawler library
# Add/delete paths to .cpp files when more are created/deleted.

add_library(crawler STATIC
  src/database_stack.cpp
  src/http_transport.cpp
  src/probe_manager.cpp
  src/stack_impl.cpp
  src/stack.cpp
)

target_include_directories(crawler
  PUBLIC include
  PUBLIC ../database/include
  PRIVATE ${Boost_INCLUDE_DIRS}
  PRIVATE ${OPENSSL_INCLUDE_DIR}
)
