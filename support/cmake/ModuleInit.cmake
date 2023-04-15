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

function(init_module)
  set(CMAKE_CXX_STANDARD 11)
  set(CMAKE_CXX_STANDARD_REQUIRED True)
  # Set the host architecture to build with
  if (CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(USE_X64 TRUE)
  else ()
    set(USE_X64 FALSE)
  endif ()
  # Single-threaded build-runs only for compatible behaviour
  set(CMAKE_BUILD_PARALLEL_LEVEL 1)
  set(CMAKE_INCLUDE_CURRENT_DIR OFF)
  # Use the target 'FOLDER' property to organize targets into folders
  set(USE_FOLDERS ON)
  set(BUILD_SHARED_LIBS ON)
  set(CMAKE_ENABLE_EXPORTS ON)
  set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
  set(CMAKE_INSTALL_MODE SYMLINK_OR_COPY)
  set(CMAKE_INSTALL_MESSAGE ALWAYS)
  set(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION ON)
  set(CPACK_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION ON)

endfunction()


# Copyright 2020 Jan Tojnar - MIT
# https://github.com/jtojnar/cmake-snips
function(join_paths joined_path first_path_segment)
  set(temp_path "${first_path_segment}")
  foreach(current_segment IN LISTS ARGN)
    if (NOT ("${current_segment}" STREQUAL ""))
      if (IS_ABSOLUTE "${current_segment}")
        set(temp_path "${current_segment}")
      else ()
        set(temp_path "${temp_path}/${current_segment}")
      endif ()
    endif ()
  endforeach()
  set(${joined_path} "${temp_path}" PARENT_SCOPE)
endfunction()

function(get_version)
  # Write CMake project version info to the cache, using external "VERSION" file
  file(READ ${CMAKE_CURRENT_SOURCE_DIR}/VERSION.txt ${PROJECT_NAME}_VERSION_FILE)
  string(REGEX MATCH "([0-999]*).[0-999].[0-999].[0-999]" version ${PROJECT_NAME}_VERSION_FILE)
  set(${PROJECT_NAME}_VERSION_FILE_MAJOR ${CMAKE_MATCH_1} CACHE STRING "Project version (major)")
  string(REGEX MATCH "[0-999].([0-999]*).[0-999].[0-999]" version ${PROJECT_NAME}_VERSION_FILE)
  set(${PROJECT_NAME}_VERSION_FILE_MINOR ${CMAKE_MATCH_1} CACHE STRING "Project version (minor)")
  string(REGEX MATCH "[0-999].[0-999].([0-999]*).[0-999]" version ${PROJECT_NAME}_VERSION_FILE)
  set(${PROJECT_NAME}_VERSION_FILE_PATCH ${CMAKE_MATCH_1} CACHE STRING "Project version (patch)")
  string(REGEX MATCH "[0-999].[0-999].[0-999].([0-999]*)" version ${PROJECT_NAME}_VERSION_FILE)
  set(${PROJECT_NAME}_VERSION_FILE_TWEAK ${CMAKE_MATCH_1} CACHE STRING "Project version (tweak)")
  set(version "")
endfunction()


# Generate CMAKE_INSTALL_<DIR> etc...
function(set_install_dirs)
  # Don't set this var! https://cmake.org/cmake/help/latest/command/install.html#installing-files
  if (NOT DEFINED CMAKE_INSTALL_DATAROOTDIR)
    set(CMAKE_INSTALL_DATAROOTDIR share CACHE PATH "Read-only architecture-independent data root (share)")
  endif ()
  if (NOT DEFINED CMAKE_INSTALL_INCLUDEDIR)
    set(CMAKE_INSTALL_INCLUDEDIR include CACHE PATH "C/C++ header files (include)")
  endif ()
  if (NOT DEFINED CMAKE_INSTALL_BINDIR)
    set(CMAKE_INSTALL_BINDIR bin CACHE PATH "User executables (bin)")
  endif ()
  if (NOT DEFINED CMAKE_INSTALL_SBINDIR)
    set(CMAKE_INSTALL_SBINDIR sbin CACHE PATH "System admin executables (sbin)")
  endif ()
  if (NOT DEFINED CMAKE_INSTALL_LIBDIR)
    set(CMAKE_INSTALL_LIBDIR lib CACHE PATH "Object code libraries (lib)")
  endif ()
  if (NOT DEFINED CMAKE_INSTALL_LIBEXECDIR)
    set(CMAKE_INSTALL_LIBEXECDIR libexec CACHE PATH "Program executables (libexec)")
  endif ()
  if (NOT DEFINED CMAKE_INSTALL_SHAREDSTATEDIR)
    set(CMAKE_INSTALL_SHAREDSTATEDIR com CACHE PATH "Modifiable architecture-independent data (com)")
  endif ()
  if (NOT DEFINED CMAKE_INSTALL_DATADIR)
    set(CMAKE_INSTALL_DATADIR ${CMAKE_INSTALL_DATAROOTDIR} CACHE PATH "Read-only architecture-independent data (DATAROOTDIR)")
  endif ()
  if (NOT DEFINED CMAKE_INSTALL_LOCALSTATEDIR)
    set(CMAKE_INSTALL_LOCALSTATEDIR var CACHE PATH "Modifiable single-machine data (var)")
  endif ()
  if (NOT DEFINED CMAKE_INSTALL_SYSCONFDIR)
    set(CMAKE_INSTALL_SYSCONFDIR etc CACHE PATH "Read-only single-machine data (etc)")
  endif ()
  if (NOT DEFINED CMAKE_INSTALL_RUNSTATEDIR)
    set(CMAKE_INSTALL_RUNSTATEDIR ${CMAKE_INSTALL_LOCALSTATEDIR}/run CACHE PATH "Run-time variable data (LOCALSTATEDIR/run)")
  endif ()
  if (NOT DEFINED CMAKE_INSTALL_LOCALEDIR)
    set(CMAKE_INSTALL_LOCALEDIR ${CMAKE_INSTALL_DATAROOTDIR}/locale CACHE PATH "Locale-dependent data (DATAROOTDIR/locale)")
  endif ()
  if (NOT DEFINED CMAKE_INSTALL_DOCDIR)
    set(CMAKE_INSTALL_DOCDIR ${CMAKE_INSTALL_DATAROOTDIR}/doc/${PROJECT_NAME} CACHE PATH "Documentation root (DATAROOTDIR/doc/PROJECT_NAME)")
  endif ()
  if (NOT DEFINED CMAKE_INSTALL_INFODIR)
    set(CMAKE_INSTALL_INFODIR ${CMAKE_INSTALL_DATAROOTDIR}/info CACHE PATH "Info documentation (DATAROOTDIR/info)")
  endif ()
  if (NOT DEFINED CMAKE_INSTALL_MANDIR)
    set(CMAKE_INSTALL_MANDIR ${CMAKE_INSTALL_DATAROOTDIR}/man CACHE PATH "Man documentation (DATAROOTDIR/man)")
  endif ()
  # get access to helper functions for creating config files
  include(GNUInstallDirs)
endfunction()

function(enable_module target)
  if (MSVC)
    set(BMI ${CMAKE_CURRENT_BINARY_DIR}/${target}.ifc)
    target_compile_options(${target}
      PRIVATE /interface /ifcOutput ${BMI}
      INTERFACE /reference fmt=${BMI})
  endif ()
  set_target_properties(${target} PROPERTIES ADDITIONAL_CLEAN_FILES ${BMI})
  set_source_files_properties(${BMI} PROPERTIES GENERATED ON)
endfunction()

# function(add_node_defines)
#   add_compile_definitions(UNICODE)
#   add_compile_definitions(_UNICODE)

#   # Host handling:
#   if(WIN32)
#     add_compile_definitions(WINDOWS=1)
#     message(STATUS "Setting Compile Definition WINDOWS=1")
#   endif ()

#   if (UNIX AND NOT APPLE)
#     add_compile_definitions(LINUX=1)
#     message(STATUS "Setting Compile Definition LINUX=1")
#   endif ()

#   if (APPLE)
#     add_compile_definitions(APPLE=1)
#     message(STATUS "Setting Compile Definition APPLE=1")
#   endif ()

#   # Debug definitions:
#   if (${CMAKE_BUILD_TYPE} MATCHES Debug OR RelWithDebInfo)
#     add_compile_definitions(_DEBUG=1)
#     message(STATUS "Setting Compile Definition _DEBUG=1")
#   else ()
#     add_compile_definitions(NDEBUG=1)
#     message(STATUS "Setting Compile Definition NDEBUG=1")
#   endif ()

#   # Set the require pre-processor defines for NAPI_VERSION and BUILDING_NODE_EXTENSION
#   if (WIN32)
#     set(CMAKE_CXX_FLAGS -DNAPI_VERSION=8 -DBUILDING_NODE_EXTENSION)
#     # add_compile_definitions(NAPI_VERSION=${napi_build_version})
#     # add_compile_definitions(BUILDING_NODE_EXTENSION)
#     target_compile_definitions(${PROJECT_NAME}
#       PUBLIC
#         -DNAPI_VERSION=8
#         -DBUILDING_NODE_EXTENSION
#     )
#     target_link_options(${PROJECT_NAME}
#       PUBLIC
#         /DELAYLOAD:NODE.EXE
#     )
#     set(CMAKE_SHARED_LINKER_FLAGS /DELAYLOAD:NODE.EXE)
#   endif ()

#   if (UNIX AND NOT APPLE)
#     set(CMAKE_CXX_FLAGS -DNAPI_VERSION=8 -DBUILDING_NODE_EXTENSION)
#     # add_compile_definitions(NAPI_VERSION=${napi_build_version})
#     # add_compile_definitions(BUILDING_NODE_EXTENSION)
#     target_compile_definitions(${PROJECT_NAME}
#       PUBLIC
#         -DNAPI_VERSION=8
#         -DBUILDING_NODE_EXTENSION
#     )
#   endif ()

#   if (APPLE)
#     set(CMAKE_CXX_FLAGS -DNAPI_VERSION=8 -DBUILDING_NODE_EXTENSION -D_DARWIN_USE_64_BIT_INODE=1 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 ${CMAKE_CXX_FLAGS})
#     # add_compile_definitions(NAPI_VERSION=${napi_build_version})
#     # add_compile_definitions(BUILDING_NODE_EXTENSION)
#     # add_compile_definitions(_DARWIN_USE_64_BIT_INODE=1)
#     # add_compile_definitions(_LARGEFILE_SOURCE)
#     # add_compile_definitions(_FILE_OFFSET_BITS=64)
#     set(CMAKE_SHARED_LINKER_FLAGS dynamic_lookup)
#     target_compile_definitions(${PROJECT_NAME}
#       PUBLIC
#         -DNAPI_VERSION=8
#         -DBUILDING_NODE_EXTENSION
#         -D_DARWIN_USE_64_BIT_INODE=1
#         -D_LARGEFILE_SOURCE
#         -D_FILE_OFFSET_BITS=64
#     )
#     target_link_options(${PROJECT_NAME}
#       PUBLIC
#         dynamic_lookup
#     )
#   endif ()

# endfunction()
