SET(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)
set(triple aarch64-linux-gnu)
set(CMAKE_SYSROOT /usr/aarch64-linux-gnu)
set(CMAKE_FIND_ROOT_PATH /usr/aarch64-linux-gnu)

set(CMAKE_C_COMPILER clang)
set(CMAKE_C_COMPILER_TARGET ${triple})
set(CMAKE_CXX_COMPILER clang++)
set(CMAKE_CXX_COMPILER_TARGET ${triple})
set(CMAKE_AR llvm-ar)

# Set various compiler flags
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-psabi --specs=nosys.specs -fdata-sections -ffunction-sections -Wl,--gc-sections")
set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS} ${CMAKE_CXX_FLAGS} -stdlib=libc++ -fno-exceptions")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -stdlib=libc++ -lc++ -lc++abi")


# Use our definitions for compiler tools
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)

# Search for libraries and headers in the target directories only
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# Optionally reduce compiler sanity check when cross-compiling.
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

#include_directories("${CROSS_OPENJDK_PATH}/include")
#include_directories("${CROSS_OPENJDK_PATH}/include/linux")


#SET(JAVA_HOME "$JAVA_HOME/")
#SET(JAVA_INCLUDE_PATH "$JAVA_HOME/include")
#SET(JAVA_AWT_INCLUDE_PATH "$JAVA_HOME/include")
#SET(JAVA_INCLUDE_PATH2 "$JAVA_HOME/include/linux")

#SET(JAVA_JVM_LIBRARY "$CROSS_OPENJDK_PATH/lib/${JAVA_INSTALLATION_TYPE}/libjvm.so")
#SET(JAVA_AWT_LIBRARY "$CROSS_OPENJDK_PATH/lib/libawt.so")


# Only on aarch64 & armhf architecture
set(CMAKE_THREAD_LIBS_INIT "-lpthread")
set(CMAKE_HAVE_THREADS_LIBRARY 1)
set(CMAKE_USE_WIN32_THREADS_INIT 0)
set(CMAKE_USE_PTHREADS_INIT 1)
set(THREADS_PREFER_PTHREAD_FLAG ON)

# Use LLD on linux
#add_link_options("-fuse-ld=lld" "-rtlib=compiler-rt" "-unwindlib=libunwind" "-Wl,--as-needed")
add_link_options("-fuse-ld=lld" "-v")