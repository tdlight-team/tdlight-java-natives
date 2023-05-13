set(CMAKE_CROSSCOMPILING TRUE)
SET(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR i386)
set(TARGET_TRIPLE i386-linux-gnu)

if(EXISTS "/usr/bin/clang-10")
  set(CMAKE_C_COMPILER /usr/bin/clang-10)
  set(CMAKE_CXX_COMPILER /usr/bin/clang++-10)
  set(CMAKE_ASM_COMPILER /usr/bin/clang-10)
  set(CMAKE_AR "/usr/bin/llvm-ar-10" CACHE FILEPATH "" FORCE)
elseif(EXISTS "/usr/bin/clang-15")
  set(CMAKE_C_COMPILER /usr/bin/clang-15)
  set(CMAKE_CXX_COMPILER /usr/bin/clang++-15)
  set(CMAKE_ASM_COMPILER /usr/bin/clang-15)
  set(CMAKE_AR "/usr/bin/llvm-ar-15" CACHE FILEPATH "" FORCE)
else()
  set(CMAKE_C_COMPILER /usr/bin/clang)
  set(CMAKE_CXX_COMPILER /usr/bin/clang++)
  set(CMAKE_ASM_COMPILER /usr/bin/clang)
  set(CMAKE_AR "/usr/bin/llvm-ar" CACHE FILEPATH "" FORCE)
endif()

set(CMAKE_C_COMPILER_TARGET ${TARGET_TRIPLE})
set(CMAKE_CXX_COMPILER_TARGET ${TARGET_TRIPLE})
set(CMAKE_ASM_COMPILER_TARGET ${TARGET_TRIPLE})

set(CMAKE_FIND_ROOT_PATH /usr/i386-linux-gnu /usr/lib/i386-linux-gnu /usr/include/i386-linux-gnu /usr/bin/i386-linux-gnu)
set(CMAKE_INCLUDE_PATH  /usr/include/i386-linux-gnu)
set(CMAKE_LIBRARY_PATH  /usr/lib/i386-linux-gnu)
set(CMAKE_PROGRAM_PATH  /usr/bin/i386-linux-gnu)
#set(CMAKE_SYSROOT /usr/lib/i386-linux-gnu)
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
if(EXISTS "/usr/lib/jvm/java-17-openjdk-i386")
  SET(JAVA_CROSS_HOME "/usr/lib/jvm/java-8-openjdk-i386")
else()
  SET(JAVA_CROSS_HOME "/usr/lib/jvm/java-8-openjdk-i386")
endif()
SET(JAVA_INCLUDE_PATH "${JAVA_HOME}/include")
SET(JAVA_AWT_INCLUDE_PATH "${JAVA_HOME}/include")
SET(JAVA_INCLUDE_PATH2 "${JAVA_HOME}/include/linux")

SET(JAVA_JVM_LIBRARY "${JAVA_CROSS_HOME}/lib/server/libjvm.so")
SET(JAVA_AWT_LIBRARY "${JAVA_CROSS_HOME}/lib/libawt.so")

# Use LLD on linux
#add_link_options("-fuse-ld=lld" "-rtlib=compiler-rt" "-unwindlib=libunwind" "-Wl,--as-needed")
#add_link_options("-fuse-ld=lld")
