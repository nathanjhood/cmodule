#!/usr/bin/env cmake

# CMake requirements.
cmake_minimum_required(VERSION 3.7...3.24.2)
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
