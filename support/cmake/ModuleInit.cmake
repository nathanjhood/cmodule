#!/usr/bin/env cmake

function(get_version)

endfunction()

function(cmake_defaults)

	include(InstallRequiredSystemLibraries)

endfunction()

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




function(add_headers VAR)
set(headers ${${VAR}})
foreach (header ${ARGN})
	set(headers ${headers} include/${PROJECT_NAME}/${header})
endforeach()
set(${VAR} ${headers} PARENT_SCOPE)
endfunction()
