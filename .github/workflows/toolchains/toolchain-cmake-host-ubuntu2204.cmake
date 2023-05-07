SET(CMAKE_SYSTEM_NAME Linux)

set(CMAKE_C_COMPILER clang-14)
set(CMAKE_CXX_COMPILER clang++-14)
set(CMAKE_AR llvm-ar-14)

# Set various compiler flags
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-psabi --specs=nosys.specs -fdata-sections -ffunction-sections -Wl,--gc-sections")
set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS} ${CMAKE_CXX_FLAGS} -stdlib=libc++ -fno-exceptions")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -stdlib=libc++ -lc++ -lc++abi")

# Use LLD on linux
#add_link_options("-fuse-ld=lld" "-rtlib=compiler-rt" "-unwindlib=libunwind" "-Wl,--as-needed")
add_link_options("-fuse-ld=lld")
