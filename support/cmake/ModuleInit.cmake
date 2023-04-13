#!/usr/bin/env cmake


function(get_version)
# Write CMake project version info to the cache, using external "VERSION" file
file(READ ${CMAKE_CURRENT_SOURCE_DIR}/VERSION.txt ${PROJECT_NAME}_VERSION_FILE)
string(REGEX MATCH "([0-999]*).[0-999].[0-999].[0-999]" _ ${PROJECT_NAME}_VERSION_FILE)
set(${PROJECT_NAME}_VERSION_FILE_MAJOR ${CMAKE_MATCH_1} CACHE STRING "Project version (major)")
string(REGEX MATCH "[0-999].([0-999]*).[0-999].[0-999]" _ ${PROJECT_NAME}_VERSION_FILE)
set(${PROJECT_NAME}_VERSION_FILE_MINOR ${CMAKE_MATCH_1} CACHE STRING "Project version (minor)")
string(REGEX MATCH "[0-999].[0-999].([0-999]*).[0-999]" _ ${PROJECT_NAME}_VERSION_FILE)
set(${PROJECT_NAME}_VERSION_FILE_PATCH ${CMAKE_MATCH_1} CACHE STRING "Project version (patch)")
string(REGEX MATCH "[0-999].[0-999].[0-999].([0-999]*)" _ ${PROJECT_NAME}_VERSION_FILE)
set(${PROJECT_NAME}_VERSION_FILE_TWEAK ${CMAKE_MATCH_1} CACHE STRING "Project version (tweak)")
set(_ "")
endfunction()

function(get_version)
  # Write CMake project version info to the cache, using external "VERSION" file
  file(READ ${PROJECT_SOURCE_DIR}/package.json ${PROJECT_NAME}_NPM_FILE)
  string(REGEX MATCH "([0-999]*).[0-999].[0-999].[0-999]" _ ${PROJECT_NAME}_VERSION_FILE)
  set(${PROJECT_NAME}_VERSION_FILE_MAJOR ${CMAKE_MATCH_1} CACHE STRING "Project version (major)")
  string(REGEX MATCH "[0-999].([0-999]*).[0-999].[0-999]" _ ${PROJECT_NAME}_VERSION_FILE)
  set(${PROJECT_NAME}_VERSION_FILE_MINOR ${CMAKE_MATCH_1} CACHE STRING "Project version (minor)")
  string(REGEX MATCH "[0-999].[0-999].([0-999]*).[0-999]" _ ${PROJECT_NAME}_VERSION_FILE)
  set(${PROJECT_NAME}_VERSION_FILE_PATCH ${CMAKE_MATCH_1} CACHE STRING "Project version (patch)")
  set(_ "")
endfunction()

function(add_node_defines)
  add_compile_definitions(UNICODE)
  add_compile_definitions(_UNICODE)

  # Host handling:
  if(WIN32)
    add_compile_definitions(WINDOWS=1)
    message(STATUS "Setting Compile Definition WINDOWS=1")
  endif ()

  if (UNIX AND NOT APPLE)
    add_compile_definitions(LINUX=1)
    message(STATUS "Setting Compile Definition LINUX=1")
  endif ()

  if (APPLE)
    add_compile_definitions(APPLE=1)
    message(STATUS "Setting Compile Definition APPLE=1")
  endif ()

  # Debug definitions:
  if (${CMAKE_BUILD_TYPE} MATCHES Debug OR RelWithDebInfo)
    add_compile_definitions(_DEBUG=1)
    message(STATUS "Setting Compile Definition _DEBUG=1")
  else ()
    add_compile_definitions(NDEBUG=1)
    message(STATUS "Setting Compile Definition NDEBUG=1")
  endif ()

  # Set the require pre-processor defines for NAPI_VERSION and BUILDING_NODE_EXTENSION
  if (WIN32)
    set(CMAKE_SHARED_LINKER_FLAGS /DELAYLOAD:NODE.EXE)
    set(CMAKE_CXX_FLAGS -DNAPI_VERSION=5 -DBUILDING_NODE_EXTENSION)
  endif ()

  if (UNIX AND NOT APPLE)
    set(CMAKE_CXX_FLAGS -DNAPI_VERSION=5 -DBUILDING_NODE_EXTENSION)
  endif ()

  if (APPLE)
    set(CMAKE_CXX_FLAGS -DNAPI_VERSION=5 -DBUILDING_NODE_EXTENSION -D_DARWIN_USE_64_BIT_INODE=1 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 ${CMAKE_CXX_FLAGS})
    set(CMAKE_SHARED_LINKER_FLAGS dynamic_lookup)
  endif ()

endfunction()
