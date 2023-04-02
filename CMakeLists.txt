#!/usr/bin/env cmake

# CMake requirements.
cmake_minimum_required(VERSION 3.9...3.24.2)
# Cmake-js requirements
cmake_policy(SET CMP0091 NEW)
cmake_policy(SET CMP0042 NEW)
# Fallback for using newer policies on CMake < 3.12.
if(${CMAKE_VERSION} VERSION_LESS 3.12)
  cmake_policy(VERSION ${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION})
endif()


project("cmodule" CXX)

set(CMAKE_MODULE_PATH
  ${CMAKE_MODULE_PATH}
  ${CMAKE_CURRENT_SOURCE_DIR}/support/cmake
)
include(ModuleInit)
get_version()
cmake_defaults()
project_defaults()



include_directories(${CMAKE_JS_INC})

# Define the library, its includes and the needed defines.
add_headers(${PROJECT_NAME}_HEADERS "cmodule.h")
# Add source files
file(GLOB ${PROJECT_NAME}_SOURCES "./src/cmodule.cc")

add_library(${PROJECT_NAME} SHARED ${${PROJECT_NAME}_HEADERS} ${${PROJECT_NAME}_SOURCES} ${CMAKE_JS_SRC} README.rst)
add_library(stoneydsp::${PROJECT_NAME} ALIAS ${PROJECT_NAME})
set_target_properties(${PROJECT_NAME} PROPERTIES PREFIX "" SUFFIX ".node")
target_link_libraries(${PROJECT_NAME} ${CMAKE_JS_LIB})

if(MSVC AND CMAKE_JS_NODELIB_DEF AND CMAKE_JS_NODELIB_TARGET)
# Generate node.lib
execute_process(COMMAND ${CMAKE_AR} /def:${CMAKE_JS_NODELIB_DEF} /out:${CMAKE_JS_NODELIB_TARGET} ${CMAKE_STATIC_LINKER_FLAGS})
endif()

set_target_properties(${PROJECT_NAME} PROPERTIES
VERSION ${${PROJECT_NAME}_VERSION}
SOVERSION ${CPACK_PACKAGE_VERSION_MAJOR}
PUBLIC_HEADER "${${PROJECT_NAME}_HEADERS}"
DEBUG_POSTFIX "${${PROJECT_NAME}_DEBUG_POSTFIX}")
