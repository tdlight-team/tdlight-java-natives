cmake_minimum_required(VERSION 3.0.2 FATAL_ERROR)

project(JTDLib VERSION 1.0 LANGUAGES CXX)
set(CMAKE_BUILD_TYPE Release)
set(TD_ENABLE_JNI ON)

if (POLICY CMP0054)
  # do not expand quoted arguments
  cmake_policy(SET CMP0054 NEW)
endif()

find_package(Td REQUIRED)

if (NOT JNI_FOUND)
  SET(JNI_FIND_REQUIRED_AWT FALSE CACHE BOOL "" FORCE)
  find_package(JNI REQUIRED COMPONENTS JVM)
endif()
message(STATUS "Found JNI: ${JNI_INCLUDE_DIRS} ${JNI_LIBRARIES}")

if (NOT Java_FOUND)
  find_package(Java REQUIRED)
endif()
message(STATUS "Found Java: ${Java_JAVAC_EXECUTABLE} ${Java_JAVADOC_EXECUTABLE}")

message(STATUS "Java Source Directory: ${JAVA_SRC_DIR}")

# Generating TdApi.java
find_program(PHP_EXECUTABLE php)

message(STATUS "PHP Executable: ${PHP_EXECUTABLE}")

set(TD_API_JAVA_PACKAGE "it/tdlight/tdnative")
set(TD_API_SPEC_JAVA_PACKAGE "it/tdlight/jni")
set(TD_API_JAVA_PATH ${JAVA_SRC_DIR})
set(TD_API_TLO_PATH ${TD_SRC_DIR}/td/generate/auto/tlo/td_api.tlo)
set(TD_API_TL_PATH ${TD_SRC_DIR}/td/generate/scheme/td_api.tl)
set(JAVADOC_TL_DOCUMENTATION_GENERATOR_PATH ${TD_SRC_DIR}/td/generate/JavadocTlDocumentationGenerator.php)
set(GENERATE_JAVA_API_CMD ${TD_GENERATED_BINARIES_DIR}/td_generate_java_api TdApi ${TD_API_TLO_PATH} ${TD_API_JAVA_PATH} ${TD_API_SPEC_JAVA_PACKAGE})
if (PHP_EXECUTABLE)
  set(GENERATE_JAVA_API_CMD ${GENERATE_JAVA_API_CMD} && ${PHP_EXECUTABLE} ${JAVADOC_TL_DOCUMENTATION_GENERATOR_PATH} ${TD_API_TL_PATH} ${TD_API_JAVA_PATH}/${TD_API_SPEC_JAVA_PACKAGE}/TdApi.java)
endif()

add_custom_target(td_generate_java_api
  COMMAND ${GENERATE_JAVA_API_CMD}
  COMMENT "Generating Java TDLib API source files"
  DEPENDS ${TD_GENERATED_BINARIES_DIR}/td_generate_java_api ${TD_API_TLO_PATH} ${TD_API_TL_PATH} ${JAVADOC_TL_DOCUMENTATION_GENERATOR_PATH}
)

get_filename_component(JAVA_OUTPUT_DIRECTORY ${TDNATIVES_BIN_DIR}/java-classes REALPATH BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}")
file(MAKE_DIRECTORY ${JAVA_OUTPUT_DIRECTORY})
add_custom_target(build_java
  COMMAND ${Java_JAVAC_EXECUTABLE} -encoding UTF-8 -d ${JAVA_OUTPUT_DIRECTORY} @${TDNATIVES_CPP_SRC_DIR}/sources.txt
  COMMENT "Building Java code"
  DEPENDS td_generate_java_api
)

add_custom_target(generate_javadoc
  COMMAND ${Java_JAVADOC_EXECUTABLE} -encoding UTF-8 -charset UTF-8 -d ${TDNATIVES_DOCS_BIN_DIR} it.tdlight.jni
  WORKING_DIRECTORY ${TD_API_JAVA_PATH}
  COMMENT "Generating Javadoc documentation"
  DEPENDS td_generate_java_api
)

# Building shared library
add_library(tdjni SHARED
  td_jni.cpp
)
target_include_directories(tdjni PRIVATE ${JAVA_INCLUDE_PATH} ${JAVA_INCLUDE_PATH2})
target_link_libraries(tdjni PRIVATE Td::TdStatic ${JAVA_JVM_LIBRARY})
target_compile_definitions(tdjni PRIVATE PACKAGE_NAME="${TD_API_JAVA_PACKAGE}" API_PACKAGE_NAME="${TD_API_SPEC_JAVA_PACKAGE}")
set_property(TARGET tdjni PROPERTY CXX_STANDARD 14)

if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  set(GCC 1)
elseif (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  set(CLANG 1)
elseif (CMAKE_CXX_COMPILER_ID STREQUAL "Intel")
  set(INTEL 1)
elseif (NOT MSVC)
  message(FATAL_ERROR "Compiler isn't supported")
endif()

include(CheckCXXCompilerFlag)

if (GCC OR CLANG OR INTEL)
  if (WIN32 AND INTEL)
    set(STD14_FLAG /Qstd=c++14)
  else()
    set(STD14_FLAG -std=c++14)
  endif()
  check_cxx_compiler_flag(${STD14_FLAG} HAVE_STD14)
  if (NOT HAVE_STD14)
    string(REPLACE "c++14" "c++1y" STD14_FLAG "${STD14_FLAG}")
    check_cxx_compiler_flag(${STD14_FLAG} HAVE_STD1Y)
    set(HAVE_STD14 ${HAVE_STD1Y})
  endif()

  target_compile_options(tdjni PRIVATE "${STD14_FLAG}")
elseif (MSVC)
  set(HAVE_STD14 MSVC_VERSION>=1900)
endif()

if (NOT HAVE_STD14)
  message(FATAL_ERROR "No C++14 support in the compiler. Please upgrade the compiler.")
endif()

#add_dependencies(tdjni td_generate_java_api build_java generate_javadoc)
add_dependencies(tdjni td_generate_java_api build_java)

install(TARGETS tdjni
  LIBRARY DESTINATION ${TDNATIVES_BIN_DIR}
  RUNTIME DESTINATION ${TDNATIVES_BIN_DIR}
)
