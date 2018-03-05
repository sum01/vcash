cmake_minimum_required(VERSION 3.1.0 FATAL_ERROR)
#[[
	Minimum version requirement list:
	- 3.0 for versioning inside of project()
	- 3.1 for THREADS_PREFER_PTHREAD_FLAG | CMAKE_CXX_STANDARD | CMAKE_CXX_STANDARD_REQUIRED
	- EVENTUALLY: 3.9 for the addition of a DESCRIPTION to project()

	For cross-compiling, read https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html#cross-compiling-toolchain ...
	and when cross-compiling for Windows, use the Cmake flag -D_WIN32_WINNT=XXXXX | literal format expected, ex: "0x0501" ...
	Accepted values for _WIN32_WINNT are here https://docs.microsoft.com/en-us/cpp/porting/modifying-winver-and-win32-winnt
]]

#[[
	TODO: Change to target_compile_features. Links below for feature lists...
	https://cmake.org/cmake/help/latest/prop_gbl/CMAKE_C_KNOWN_FEATURES.html#prop_gbl:CMAKE_C_KNOWN_FEATURES
	https://cmake.org/cmake/help/latest/prop_gbl/CMAKE_CXX_KNOWN_FEATURES.html#prop_gbl:CMAKE_CXX_KNOWN_FEATURES
]]

# TODO: https://cmake.org/cmake/help/latest/command/add_test.html

add_subdirectory(bin/vcashd)
