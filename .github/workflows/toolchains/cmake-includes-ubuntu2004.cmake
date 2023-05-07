SET(CMAKE_SYSTEM_NAME Linux)

set(CMAKE_C_COMPILER "/usr/bin/clang-10")
set(CMAKE_CXX_COMPILER "/usr/bin/clang++-10")
set(CMAKE_AR /usr/bin/llvm-ar-10)

# Set various compiler flags
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-psabi --specs=nosys.specs -fdata-sections -ffunction-sections -Wl,--gc-sections")
set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS} ${CMAKE_CXX_FLAGS} -stdlib=libc++ -fno-exceptions")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -stdlib=libc++ -lc++ -lc++abi")

# Use LLD on linux
add_link_options("-fuse-ld=lld")

# ccache
find_program(CCACHE_FOUND ccache)
if(CCACHE_FOUND)
    set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE ccache)
    set_property(GLOBAL PROPERTY RULE_LAUNCH_LINK ccache) # Less useful to do it for linking, see edit2
endif(CCACHE_FOUND)
