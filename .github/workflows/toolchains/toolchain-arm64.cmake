set(CMAKE_CROSSCOMPILING TRUE)
SET(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)
set(TARGET_TRIPLE aarch64-linux-gnu)

set(CMAKE_C_COMPILER_TARGET ${TARGET_TRIPLE})
set(CMAKE_C_COMPILER /usr/bin/clang-10)
set(CMAKE_CXX_COMPILER_TARGET ${TARGET_TRIPLE})
set(CMAKE_CXX_COMPILER /usr/bin/clang++-10)
set(CMAKE_ASM_COMPILER_TARGET ${TARGET_TRIPLE})
set(CMAKE_ASM_COMPILER /usr/bin/clang-10)
set(CMAKE_AR "/usr/bin/llvm-ar-10" CACHE FILEPATH "" FORCE)

set(CMAKE_FIND_ROOT_PATH /usr/aarch64-linux-gnu /usr/lib/aarch64-linux-gnu /usr/include/aarch64-linux-gnu /usr/bin/aarch64-linux-gnu)
set(CMAKE_INCLUDE_PATH  /usr/include/aarch64-linux-gnu)
set(CMAKE_LIBRARY_PATH  /usr/lib/aarch64-linux-gnu)
set(CMAKE_PROGRAM_PATH  /usr/bin/aarch64-linux-gnu)
#set(CMAKE_SYSROOT /usr/lib/aarch64-linux-gnu)
#set(OPENSSL_INCLUDE_DIR /usr/include/openssl)
#include_directories("/usr/include/openssl")


# Set various compiler flags
set(CMAKE_EXE_LINKER_FLAGS_INIT "-fuse-ld=lld -rtlib=compiler-rt -unwindlib=libunwind")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "-fuse-ld=lld -rtlib=compiler-rt -unwindlib=libunwind")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "-fuse-ld=lld -rtlib=compiler-rt -unwindlib=libunwind")
set(CMAKE_CXX_FLAGS_INIT "-stdlib=libc++")


# Use our definitions for compiler tools
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)

# Search for libraries and headers in the target directories only
#SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
#SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
#SET(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# This must be set or compiler checks fail when linking
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

#include_directories("${CROSS_OPENJDK_PATH}/include/linux")

SET(JAVA_HOME "/usr/lib/jvm/default-java/")
SET(JAVA_CROSS_HOME "/usr/lib/jvm/java-1.8.0-openjdk-arm64")
SET(JAVA_INCLUDE_PATH "${JAVA_HOME}/include")
SET(JAVA_AWT_INCLUDE_PATH "${JAVA_HOME}/include")
SET(JAVA_INCLUDE_PATH2 "${JAVA_HOME}/include/linux")

SET(JAVA_JVM_LIBRARY "${JAVA_CROSS_HOME}/jre/lib/aarch64/server/libjvm.so")
SET(JAVA_AWT_LIBRARY "${JAVA_CROSS_HOME}/jre/lib/aarch64/libawt.so")


# Only on aarch64 & armhf architecture
set(CMAKE_THREAD_LIBS_INIT "-lpthread")
set(CMAKE_HAVE_THREADS_LIBRARY 1)
set(CMAKE_USE_WIN32_THREADS_INIT 0)
set(CMAKE_USE_PTHREADS_INIT 1)
set(THREADS_PREFER_PTHREAD_FLAG ON)

# Use LLD on linux
#add_link_options("-fuse-ld=lld" "-rtlib=compiler-rt" "-unwindlib=libunwind" "-Wl,--as-needed")
#add_link_options("-fuse-ld=lld")
