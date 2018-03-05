cmake_minimum_required(VERSION 3.0.0 FATAL_ERROR)

# Like an include guard so we don't rebuild
IF(_VCASH_LIBCOIN_ALREADY_BUILT)
	return()
ELSE()
	set(_VCASH_LIBCOIN_ALREADY_BUILT true)
ENDIF()

# Should proably have a version
project(coin LANGUAGES C CXX)

add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/../database" "${CMAKE_CURRENT_BINARY_DIR}/database")

find_package(BerkeleyDB 5.0.0 REQUIRED)

vcash_max_dep_version("BerkeleyDB" ${BERKELEYDB_VERSION} "6.1.36")

IF(BERKELEYDB_VERSION VERSION_LESS "6.0.0")
  message(WARNING "Pre-existing wallet data is not backwards compatible with version v5 of Berkeley DB if it was originally built with v6. Read https://github.com/openvcash/vcash/wiki/Compile-With-Cmake#preamble--warning for more info.")
ENDIF()

vcash_library_template("coin"
	"${CMAKE_CURRENT_SOURCE_DIR}/src"
	"transaction_bloom_filter.hpp;incentive.hpp;types.hpp;globals.hpp;zerotime_lock.hpp;script_checker.hpp;ecrypt-config.h;ecrypt-sync.h;transaction_out.hpp;checkpoints.hpp;signature_cache.hpp;zerotime_answer.hpp;script.hpp;sph_blake.h;block_merkle.hpp;chainblender_manager.hpp;transaction_in.hpp;alert.hpp;sph_types.h;transaction.hpp;tcp_transport.hpp;stack.hpp;endian.hpp;http_transport.hpp;db_tx_bdb.hpp;rpc_json_parser.hpp;incentive_collaterals.hpp;alert_manager.hpp;zerotime_vote.hpp;db_env.hpp;transaction_merkle.hpp;file.hpp;hc256.hpp;mining.hpp;protocol.hpp;crypter.hpp;db_wallet.hpp;coin_control.hpp;zerotime_manager.hpp;tcp_connection_manager.hpp;ecdhe.h;zerotime.hpp;ecdhe.hpp;ripemd160.hpp;chainblender_broadcast.hpp;ecrypt-portable.h;network.hpp;incentive_manager.hpp;database_stack.hpp;mining_manager.hpp;utility.hpp;key_reserved.hpp;point_in.hpp;block_locator.hpp;median_filter.hpp;secret.hpp;wallet.hpp;chainblender.hpp;db_tx.hpp;reward.hpp;wallet_manager.hpp;chainblender_status.hpp;status_manager.hpp;block_index.hpp;zerotime_question.hpp;logger.hpp;message.hpp;chainblender_join.hpp;incentive_question.hpp;random.hpp;script_checker_queue.hpp;key_wallet_master.hpp;transaction_wallet.hpp;pbkdf2.hpp;key.hpp;incentive_sync.hpp;alert_unsigned.hpp;block_index_disk.hpp;point_out.hpp;big_number.hpp;hd_ecdsa.hpp;destination.hpp;account.hpp;key_wallet.hpp;filesystem.hpp;gateway.hpp;incentive_answer.hpp;constants.hpp;hash.hpp;rpc_server.hpp;key_store.hpp;base58.hpp;blake256.hpp;tcp_connection.hpp;hd_configuration.hpp;nat_pmp.hpp;configuration.hpp;hd_keychain.hpp;chainblender_leave.hpp;block_orphan.hpp;time.hpp;sha256.hpp;rpc_transport.hpp;inventory_vector.hpp;output.hpp;ecrypt-machine.h;transaction_index.hpp;tcp_acceptor.hpp;address_manager.hpp;checkpoint_sync.hpp;checkpoint_sync_unsigned.hpp;rpc_connection.hpp;accounting_entry.hpp;db_tx_ldb.hpp;crypto.hpp;merkle_tree_partial.hpp;key_store_crypto.hpp;key_pool.hpp;db.hpp;rpc_manager.hpp;transaction_position.hpp;kernel.hpp;upnp_client.hpp;key_store_basic.hpp;nat_pmp_client.hpp;data_buffer.hpp;address.hpp;stack_impl.hpp;transaction_pool.hpp;block.hpp;incentive_vote.hpp;android.hpp;whirlpool.hpp;key_public.hpp"
	"wallet_manager.cpp;db_wallet.cpp;chainblender_leave.cpp;address_manager.cpp;incentive_vote.cpp;chainblender_broadcast.cpp;secret.cpp;script_checker.cpp;mining_manager.cpp;checkpoints.cpp;nat_pmp_client.cpp;configuration.cpp;utility.cpp;account.cpp;address.cpp;script_checker_queue.cpp;point_in.cpp;zerotime_vote.cpp;transaction_position.cpp;rpc_manager.cpp;db_env.cpp;tcp_connection.cpp;zerotime_manager.cpp;crypter.cpp;chainblender_manager.cpp;kernel.cpp;db.cpp;merkle_tree_partial.cpp;alert_unsigned.cpp;stack.cpp;incentive_answer.cpp;base58.cpp;hd_configuration.cpp;alert.cpp;hd_keychain.cpp;block_locator.cpp;db_tx_ldb.cpp;big_number.cpp;ripemd160.cpp;accounting_entry.cpp;gateway.cpp;incentive.cpp;hash.cpp;block.cpp;key_reserved.cpp;rpc_connection.cpp;pbkdf2.cpp;status_manager.cpp;blake256.cpp;db_tx_bdb.cpp;incentive_question.cpp;transaction_wallet.cpp;hc256.cpp;alert_manager.cpp;sha256.cpp;transaction_pool.cpp;zerotime_lock.cpp;block_index_disk.cpp;key_store_crypto.cpp;tcp_acceptor.cpp;nat_pmp.cpp;mining.cpp;checkpoint_sync.cpp;db_tx.cpp;key_store_basic.cpp;block_index.cpp;zerotime_answer.cpp;transaction_merkle.cpp;zerotime_question.cpp;key.cpp;zerotime.cpp;wallet.cpp;checkpoint_sync_unsigned.cpp;rpc_json_parser.cpp;hd_ecdsa.cpp;point_out.cpp;chainblender_status.cpp;ecdhe.cpp;transaction_index.cpp;transaction_in.cpp;script.cpp;chainblender_join.cpp;inventory_vector.cpp;key_wallet_master.cpp;upnp_client.cpp;globals.cpp;reward.cpp;incentive_collaterals.cpp;transaction_out.cpp;signature_cache.cpp;tcp_connection_manager.cpp;incentive_manager.cpp;key_pool.cpp;incentive_sync.cpp;database_stack.cpp;message.cpp;tcp_transport.cpp;transaction_bloom_filter.cpp;transaction.cpp;block_merkle.cpp;key_public.cpp;stack_impl.cpp;rpc_transport.cpp;whirlpool.cpp;rpc_server.cpp;filesystem.cpp;chainblender.cpp;http_transport.cpp;file.cpp;key_wallet.cpp"
)

target_include_directories(coin
  PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
  PUBLIC $<INSTALL_INTERFACE:src>
	PRIVATE ${BERKELEYDB_INCLUDE_DIRS}
)

target_link_libraries(coin
	PUBLIC database
	PRIVATE ${BERKELEYDB_LIBRARIES}
)

install_and_export(coin)
