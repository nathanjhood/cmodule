#!/usr/bin/env cmake

# StoneyDSP/cmodule - a public template for C++ modules for NodeJS (MIT 2023)

# CMake requirements.
cmake_minimum_required(VERSION 3.9...3.24.2)
# Cmake-js requirements
cmake_policy(SET CMP0091 NEW)
cmake_policy(SET CMP0042 NEW)
# Fallback for using newer policies on CMake < 3.12.
if(${CMAKE_VERSION} VERSION_LESS 3.12)
  cmake_policy(VERSION ${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION})
endif()
# Import some custom helpers to set up CMake
set(CMAKE_MODULE_PATH
  ${CMAKE_MODULE_PATH}
  ${CMAKE_CURRENT_SOURCE_DIR}/support/cmake
)
include("support/cmake/ModuleInit.cmake")

init_module()

# Collect Node Addon-API headers into NODE_ADDON_API_DIR
execute_process(
  COMMAND node -p "require('node-addon-api').include"
  WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
  OUTPUT_VARIABLE NODE_ADDON_API_DIR
)
string(REGEX REPLACE "[\r\n\"]" "" NODE_ADDON_API_DIR ${NODE_ADDON_API_DIR})
if (NOT DEFINED CMAKE_JS_INC)
  # Collect cmake-js library into CMAKE_JS_LIB
  unset(CMAKE_JS_LIB)
  execute_process(
    COMMAND cmake-js "print-cmakejs-lib"
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
    OUTPUT_VARIABLE CMAKE_JS_LIB
  )
  string(REGEX REPLACE "[\r\n\"]" "" CMAKE_JS_LIB ${CMAKE_JS_LIB})
  unset(CMAKE_JS_INC)
  # Collect cmake-js includes into CMAKE_JS_INC
  execute_process(
    COMMAND cmake-js "print-cmakejs-include"
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
    OUTPUT_VARIABLE CMAKE_JS_INC
  )
  string(REGEX REPLACE "[\r\n\"]" "" CMAKE_JS_INC ${CMAKE_JS_INC})
  unset(CMAKE_JS_SRC)
  # Collect cmake-js sources into CMAKE_JS_SRC
  execute_process(
    COMMAND cmake-js "print-cmakejs-src"
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
    OUTPUT_VARIABLE CMAKE_JS_SRC
  )
  string(REGEX REPLACE "[\r\n\"]" "" CMAKE_JS_SRC ${CMAKE_JS_SRC})
endif ()

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)

## Create Project
project("cmodule"
  VERSION "1.0.0.1"
  DESCRIPTION "NodeJS module written in C++"
  HOMEPAGE_URL "https://github.com/StoneyDSP/cmodule"
  LANGUAGES CXX
)

# Parse the project name into vars
string(TOUPPER ${PROJECT_NAME} PROJECT_NAME_UPPER)
string(TOLOWER ${PROJECT_NAME} PROJECT_NAME_LOWER)
# Set DEBUG_POSTFIX and LIB_NAME for output files.
set(${PROJECT_NAME_UPPER}_DEBUG_POSTFIX d CACHE STRING "Debug library postfix.")
set(${PROJECT_NAME_UPPER}_LIB_NAME ${PROJECT_NAME_LOWER})
if (CMAKE_BUILD_TYPE STREQUAL "Debug")
  set(${PROJECT_NAME_UPPER}_LIB_NAME "${${PROJECT_NAME_UPPER}_LIB_NAME}.${${PROJECT_NAME_UPPER}_DEBUG_POSTFIX}")
endif ()


# Generate CMAKE_INSTALL_<DIR> etc...
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



option(${PROJECT_NAME_UPPER}_PEDANTIC "Enable extra warnings and expensive tests." ON)
option(${PROJECT_NAME_UPPER}_WERROR "Halt the compilation with an error on compiler warnings." OFF)
# Options that control generation of various targets.
option(${PROJECT_NAME_UPPER}_DOC "Generate the doc target." OFF)
option(${PROJECT_NAME_UPPER}_INSTALL "Generate the install target." ON)
option(${PROJECT_NAME_UPPER}_VCPKG "Integrate vcpkg for c++ packages." OFF)
option(${PROJECT_NAME_UPPER}_TEST "Generate the test target." ON)
option(${PROJECT_NAME_UPPER}_INC_NODE_HEADERS "Include Node API headers in build project" ON)
option(${PROJECT_NAME_UPPER}_MODULE "Build a C++ module instead of a NodeJS library." OFF)


## Configure directories.
# set(${PROJECT_NAME_UPPER}_DIR                  ${CMAKE_BINARY_DIR}                           CACHE PATH "Installation directory for binaries, a relative path that will be joined to ${CMAKE_INSTALL_PREFIX} or an absolute path.")
# set(${PROJECT_NAME_UPPER}_BIN_DIR              ${CMAKE_BINARY_DIR}/bin                       CACHE PATH "Installation directory for binaries, a relative path that will be joined to ${CMAKE_INSTALL_PREFIX} or an absolute path.")
# set(${PROJECT_NAME_UPPER}_LIB_DIR              ${CMAKE_BINARY_DIR}/lib                       CACHE PATH "Installation directory for libraries, a relative path that will be joined to ${CMAKE_INSTALL_PREFIX} or an absolute path.")
# set(${PROJECT_NAME_UPPER}_INC_DIR              ${CMAKE_BINARY_DIR}/include/${PROJECT_NAME}   CACHE PATH "Installation directory for include files, a relative path that will be joined with ${CMAKE_INSTALL_PREFIX} or an absolute path.")
# set(${PROJECT_NAME_UPPER}_CMAKE_DIR            ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME} CACHE PATH "Installation directory for CMake (.cmake) files, a relative path that will be joined with ${CMAKE_INSTALL_PREFIX} or an absolute path.")
# set(${PROJECT_NAME_UPPER}_PKGCONFIG_DIR   		 ${CMAKE_INSTALL_LIBDIR}/pkgconfig             CACHE PATH "Installation directory for pkgconfig (.pc) files, a relative path that will be joined with ${CMAKE_INSTALL_PREFIX} or an absolute path.")

## Configure files.
# set(${PROJECT_NAME_UPPER}_VERSION_CONFIG       ${PROJECT_BINARY_DIR}/share/${PROJECT_NAME}ConfigVersion.cmake CACHE STRING "Location of generated <project_name>ConfigVersion.cmake file")
# set(${PROJECT_NAME_UPPER}_PROJECT_CONFIG       ${PROJECT_BINARY_DIR}/share/${PROJECT_NAME}Config.cmake CACHE STRING "Location of generated <project_name>Config.cmake file")
# set(${PROJECT_NAME_UPPER}_PACKAGE_CONFIG       ${PROJECT_BINARY_DIR}/lib/pkgconfig/${PROJECT_NAME_LOWER}.pc CACHE STRING "Location of generated <project_name>.pc file")
# set(${PROJECT_NAME_UPPER}_CM_VARS_CONFIG       ${CMAKE_BINARY_DIR}/share/${PROJECT_NAME}Config.h CACHE STRING "Location of generated <project_name>Config.h file")
# set(${PROJECT_NAME_UPPER}_VCPKG_MNFST          ${PROJECT_BINARY_DIR}/vcpkg.json CACHE STRING "Location of generated vcpkg.json file")
# set(${PROJECT_NAME_UPPER}_VCPKG_CONFIG         ${PROJECT_BINARY_DIR}/vcpkg-configuration.json CACHE STRING "Location of generated vcpkg-configuration.json file")
# set(${PROJECT_NAME_UPPER}_PORT_FILE            ${PROJECT_BINARY_DIR}/${PROJECT_NAME_LOWER}-portfile.cmake CACHE STRING "Location of generated <project_name>-portfile.cmake file")
# set(TARGETS_EXPORT_NAME  							         ${PROJECT_NAME}Targets CACHE STRING "Name generated <project_name>Targets variable")


# create config header
message(STATUS "Creating config header file...")
configure_file(
  ${PROJECT_SOURCE_DIR}/support/cmake/cmoduleConfig.h.in
  ${CMAKE_BINARY_DIR}/share/${PROJECT_NAME}Config.h
)
message(STATUS "Created config header file at ${${PROJECT_NAME_UPPER}_CM_VARS_CONFIG}\n")

# create config file
message(STATUS "Creating project config file...")
include(CMakePackageConfigHelpers)
configure_package_config_file(
    ${PROJECT_SOURCE_DIR}/support/cmake/cmoduleConfig.cmake.in
    ${PROJECT_BINARY_DIR}/share/${PROJECT_NAME}Config.cmake
  INSTALL_DESTINATION
    ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}
)
message(STATUS "Created project config file at ${${PROJECT_NAME_UPPER}_PROJECT_CONFIG}\n")

# create version config file
message(STATUS "Creating the version file for the config file...")
write_basic_package_version_file(
  ${PROJECT_BINARY_DIR}/share/${PROJECT_NAME}ConfigVersion.cmake
  VERSION ${${PROJECT_NAME}_VERSION}
  COMPATIBILITY AnyNewerVersion
)
message(STATUS "Created version file for the config file at ${${PROJECT_NAME_UPPER}_VERSION_CONFIG}\n")


if (${${PROJECT_NAME_UPPER}_VCPKG})
  # create vcpkg manifest file
  message(STATUS "Creating vcpkg manifest...")
  configure_file(
    ${PROJECT_SOURCE_DIR}/support/vcpkg/vcpkg.in.json
    ${PROJECT_BINARY_DIR}/vcpkg.json
  )
  message(STATUS "Created vcpkg manifest at ${${PROJECT_NAME_UPPER}_VCPKG_MNFST}\n")

  # create vcpkg configuration file
  message(STATUS "Creating vcpkg configuration...")
  configure_file(
    ${PROJECT_SOURCE_DIR}/support/vcpkg/vcpkg-configuration.in.json
    ${PROJECT_BINARY_DIR}/vcpkg-configuration.json
  )
  message(STATUS "Created vcpkg configuration at ${${PROJECT_NAME_UPPER}_VCPKG_CONFIG}\n")

  # create vcpkg portfile
  message(STATUS "Creating vcpkg portfile...")
  configure_file(
    ${PROJECT_SOURCE_DIR}/support/vcpkg/portfile.in.cmake
    ${PROJECT_BINARY_DIR}/${PROJECT_NAME_LOWER}-portfile.cmake
  )
  message(STATUS "Created vcpkg portfile at ${${PROJECT_NAME_UPPER}_PORT_FILE}\n")
endif ()


# Add the library as an output target
add_library(${PROJECT_NAME} SHARED)
add_library(${PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME})
target_link_libraries(${PROJECT_NAME} ${CMAKE_JS_LIB})

target_sources(${PROJECT_NAME}
  PRIVATE
    package.json
    README.rst
    LICENSE
    VERSION.txt
    index.js
)

# Glob all files with all extensions in 'src/' and pass them to ${PROJECT_NAME_UPPER}_SRC_FILES
file(GLOB ${PROJECT_NAME_UPPER}_SRC_FILES "${PROJECT_SOURCE_DIR}/src/*")
target_sources(${PROJECT_NAME}
  PRIVATE
    ${${PROJECT_NAME_UPPER}_SRC_FILES}
)
# # Glob all files with all extensions in 'include/${PROJECT_NAME}' and pass them to ${PROJECT_NAME_UPPER}_INC_FILES
# file(GLOB ${PROJECT_NAME_UPPER}_INC_FILES "${PROJECT_SOURCE_DIR}/include/${PROJECT_NAME}/*")
# target_sources(${PROJECT_NAME}
#   PRIVATE
#     ${${PROJECT_NAME_UPPER}_INC_FILES}
# )

# Glob all files with all extensions in 'include/${PROJECT_NAME}' and pass them to ${PROJECT_NAME_UPPER}_INC_FILES
file(GLOB ${PROJECT_NAME_UPPER}_INC_FILES "${PROJECT_SOURCE_DIR}/include/${PROJECT_NAME}/*")
target_sources(${PROJECT_NAME}
  PUBLIC
    FILE_SET ${PROJECT_NAME_LOWER}_HEADERS
    TYPE HEADERS
    BASE_DIRS ${PROJECT_SOURCE_DIR}/include/${PROJECT_NAME}
    FILES ${${PROJECT_NAME_UPPER}_INC_FILES}
)

if (${PROJECT_NAME_UPPER}_INC_NODE_HEADERS)
  # Glob all files with all extensions in 'include/${PROJECT_NAME}' and pass them to ${PROJECT_NAME_UPPER}_INC_FILES
  file(GLOB ${PROJECT_NAME_UPPER}_PRIVATE_INC_FILES "${CMAKE_JS_INC}/*.h" "${NODE_ADDON_API_DIR}/*.h")
  target_sources(${PROJECT_NAME}
    PRIVATE
      FILE_SET ${PROJECT_NAME_LOWER}_PRIVATE_HEADERS
      TYPE HEADERS
      BASE_DIRS ${CMAKE_JS_INC} ${NODE_ADDON_API_DIR}
      FILES
        ${${PROJECT_NAME_UPPER}_PRIVATE_INC_FILES}
  )
endif ()
target_include_directories(${PROJECT_NAME}
  PUBLIC
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include/${PROJECT_NAME}>
    $<INSTALL_INTERFACE:include/${PROJECT_NAME}>
  PRIVATE
    ${PROJECT_BINARY_DIR}
    ${CMAKE_JS_INC}
    ${NODE_ADDON_API_DIR}
)
# Set target output file properties.
set_target_properties(${PROJECT_NAME}
PROPERTIES
  CXX_STANDARD 11
  CXX_STANDARD_REQUIRED TRUE
  RUNTIME_OUTPUT_DIRECTORY bin
  LIBRARY_OUTPUT_DIRECTORY lib
  ARCHIVE_OUTPUT_DIRECTORY lib
  PDB_OUTPUT_DIRECTORY bin
  PREFIX ""
  SUFFIX ".node"
  DEBUG_POSTFIX ${${PROJECT_NAME_UPPER}_DEBUG_POSTFIX}
  # Add an interface compatibility check, to check linkage against (increasing VERSION_MAJOR is by definition a 'breaking change')
  COMPATIBLE_INTERFACE_STRING ${PROJECT_NAME_UPPER}_VERSION_MAJOR
  INTERFACE_${PROJECT_NAME_UPPER}_VERSION_MAJOR ${${PROJECT_NAME}_VERSION_MAJOR}
  # PUBLIC_HEADER ${PROJECT_NAME_LOWER}_HEADERS
  # PRIVATE_HEADER ${PROJECT_NAME_LOWER}_PRIVATE_HEADERS
)

source_group("${PROJECT_NAME}" FILES ${${PROJECT_NAME_UPPER}_INC_FILES} ${${PROJECT_NAME_UPPER}_SRC_FILES})
source_group("Node API" FILES ${${PROJECT_NAME_UPPER}_PRIVATE_INC_FILES})


if (CMAKE_CXX_COMPILER_ID MATCHES "GNU")
  set(PEDANTIC_COMPILE_FLAGS -pedantic-errors -Wall -Wextra -pedantic
      -Wold-style-cast -Wundef
      -Wredundant-decls -Wwrite-strings -Wpointer-arith
      -Wcast-qual -Wformat=2 -Wmissing-include-dirs
      -Wcast-align
      -Wctor-dtor-privacy -Wdisabled-optimization
      -Winvalid-pch -Woverloaded-virtual
      -Wconversion -Wundef
      -Wno-ctor-dtor-privacy -Wno-format-nonliteral)
  if (NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 4.6)
      set(PEDANTIC_COMPILE_FLAGS ${PEDANTIC_COMPILE_FLAGS}
         -Wno-dangling-else -Wno-unused-local-typedefs)
  endif ()
  if (NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 5.0)
      set(PEDANTIC_COMPILE_FLAGS ${PEDANTIC_COMPILE_FLAGS} -Wdouble-promotion
          -Wtrampolines -Wzero-as-null-pointer-constant -Wuseless-cast
          -Wvector-operation-performance -Wsized-deallocation -Wshadow)
  endif ()
  if (NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 6.0)
      set(PEDANTIC_COMPILE_FLAGS ${PEDANTIC_COMPILE_FLAGS} -Wshift-overflow=2
          -Wnull-dereference -Wduplicated-cond)
  endif ()
  set(WERROR_FLAG -Werror)
endif ()

if (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  set(PEDANTIC_COMPILE_FLAGS -Wall -Wextra -pedantic -Wconversion -Wundef
      -Wdeprecated -Wweak-vtables -Wshadow
      -Wno-gnu-zero-variadic-macro-arguments)
  # check_cxx_compiler_flag(-Wzero-as-null-pointer-constant HAS_NULLPTR_WARNING) // Crashing github workflows...
  # if (HAS_NULLPTR_WARNING)
  #   set(PEDANTIC_COMPILE_FLAGS ${PEDANTIC_COMPILE_FLAGS}
  #       -Wzero-as-null-pointer-constant)
  # endif ()
  set(WERROR_FLAG -Werror)
endif ()

if (MSVC)
  set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
  set(PEDANTIC_COMPILE_FLAGS /W3)
  set(WERROR_FLAG /WX)
  if (CMAKE_JS_NODELIB_DEF AND CMAKE_JS_NODELIB_TARGET)
  # Generate node.lib
    execute_process(COMMAND ${CMAKE_AR} /def:${CMAKE_JS_NODELIB_DEF} /out:${CMAKE_JS_NODELIB_TARGET} ${CMAKE_STATIC_LINKER_FLAGS})
  endif ()
  if (${CMAKE_BUILD_TYPE} STREQUAL "Debug")
    set(${CMAKE_INSTALL_DEBUG_LIBRARIES} TRUE)
  endif ()
endif ()
include(InstallRequiredSystemLibraries)
if (PROJECT_IS_TOP_LEVEL AND NOT DEFINED CMAKE_CXX_VISIBILITY_PRESET)
  set(CMAKE_CXX_VISIBILITY_PRESET hidden CACHE STRING "Preset for the export of private symbols (C++)")
  set_property(CACHE CMAKE_CXX_VISIBILITY_PRESET PROPERTY STRINGS hidden default)
endif ()
if (PROJECT_IS_TOP_LEVEL AND NOT DEFINED CMAKE_VISIBILITY_INLINES_HIDDEN)
  set(CMAKE_VISIBILITY_INLINES_HIDDEN ON CACHE BOOL "Whether to add a compile flag to hide symbols of inline functions")
endif ()
# Set the std lib standard to c++11, PUBLIC to affect both the lib and the interface
target_compile_features(${PROJECT_NAME} PUBLIC cxx_std_11)
# Set the require pre-processor defines for NAPI_VERSION and BUILDING_NODE_EXTENSION
# if (WIN32)
#   set(CMAKE_SHARED_LINKER_FLAGS /DELAYLOAD:NODE.EXE)
#   set(NODE_MODULE_FLAGS -DNAPI_VERSION=5 -DBUILDING_NODE_EXTENSION)
# endif ()
# if (UNIX)
#   set(NODE_MODULE_FLAGS -DNAPI_VERSION=5 -DBUILDING_NODE_EXTENSION)
#   if (APPLE)
#     set(NODE_MODULE_FLAGS ${NODE_MODULE_FLAGS} -D_DARWIN_USE_64_BIT_INODE=1 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 ${CMAKE_CXX_FLAGS})
#     set(CMAKE_SHARED_LINKER_FLAGS dynamic_lookup)
#   endif ()
# endif ()
# set(NODE_MODULE_FLAGS -DNAPI_VERSION=5 -DBUILDING_NODE_EXTENSION)
# # Apply the pre-processor defines, PUBLIC to affect both the lib and the interface
# target_compile_definitions(${PROJECT_NAME} PUBLIC ${NODE_MODULE_FLAGS})
# If ERROR option is set, apply the globbed ERROR compile options
add_node_defines()
if (${PROJECT_NAME_UPPER}_WERROR)
  target_compile_options(${PROJECT_NAME} PUBLIC ${WERROR_FLAG})
endif ()
# If PEDANTIC option is set, apply the globbed PEDANTIC compile options
if (${PROJECT_NAME_UPPER}_PEDANTIC)
  target_compile_options(${PROJECT_NAME} PUBLIC ${PEDANTIC_COMPILE_FLAGS})
endif ()
if (${PROJECT_NAME_UPPER}_MODULE)
  enable_module(${PROJECT_NAME})
endif ()

export(
  TARGETS ${PROJECT_NAME}
  FILE ${PROJECT_BINARY_DIR}/share/${PROJECT_NAME}Targets.cmake
  NAMESPACE ${PROJECT_NAME}::
)

if (PROJECT_IS_TOP_LEVEL)
# if (${PROJECT_NAME_UPPER}_TEST)
  #---------------
  # CTEST
  #---------------
  # Configure CTest
  enable_testing()
  add_test(NAME Runs COMMAND node "${PROJECT_SOURCE_DIR}/test/run.js")
  # include(CTest)
# endif ()
endif ()

if (${${PROJECT_NAME_UPPER}_INSTALL})
  #---------------
  # CPACK
  #---------------

  join_paths(libdir_for_pc_file "\${exec_prefix}" "${CMAKE_INSTALL_LIBDIR}")
  join_paths(includedir_for_pc_file "\${prefix}" "${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}")

  message(STATUS "Creating pkgconfig file...")
  configure_file(
    ${PROJECT_SOURCE_DIR}/support/cmake/cmodule.pc.in
    ${PROJECT_BINARY_DIR}/lib/pkgconfig/${PROJECT_NAME_LOWER}.pc
    @ONLY
  )
  message(STATUS "Created pkgconfig file at ${${PROJECT_NAME_UPPER}_PACKAGE_CONFIG}\n")

  # Configure CPack
  set(CPACK_SOURCE_PACKAGE_FILE_NAME ${${PROJECT_NAME}-${PROJECT_VERSION}})
  set(CPACK_PACKAGE_DESCRIPTION_SUMMARY ${PROJECT_DESCRIPTION})
  set(CPACK_PACKAGE_VERSION_MAJOR ${${PROJECT_NAME}_VERSION_MAJOR})
  set(CPACK_PACKAGE_VERSION_MINOR ${${PROJECT_NAME}_VERSION_MINOR})
  set(CPACK_PACKAGE_VERSION_PATCH ${${PROJECT_NAME}_VERSION_PATCH})
  set(CPACK_PACKAGE_VERSION_TWEAK ${${PROJECT_NAME}_VERSION_TWEAK})
  set(CPACK_RESOURCE_FILE_LICENSE ${CMAKE_CURRENT_LIST_DIR}/LICENSE)
  set(CPACK_RESOURCE_FILE_README ${CMAKE_CURRENT_LIST_DIR}/README.rst)
  set(CPACK_SOURCE_GENERATOR "TGZ;ZIP")
  set(CPACK_SOURCE_IGNORE_FILES
    /.git/*
    /.github
    /.vs
    /.vscode
    /bin
    /lib
    /share
    /etc
    /build
    /downloads
    /installed
    /node_modules
    /vcpkg
    /.*build.*
    /\\\\.DS_Store
  )
  include(CPack)


  #---------------
  # INSTALL TARGETS
  #---------------

  # Install the library and headers.
  install(
    TARGETS ${PROJECT_NAME}
    EXPORT ${PROJECT_NAME}Targets
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}
    # PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}
    # PRIVATE_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}
    FRAMEWORK DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}
    FILE_SET ${PROJECT_NAME_LOWER}_HEADERS DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}
    FILE_SET ${PROJECT_NAME_LOWER}_PRIVATE_HEADERS DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}
  )

  install(
    EXPORT ${PROJECT_NAME}Targets
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}
    NAMESPACE ${PROJECT_NAME}::
  )

  install(
    FILES
      ${PROJECT_BINARY_DIR}/share/${PROJECT_NAME}Config.cmake
      ${PROJECT_BINARY_DIR}/share/${PROJECT_NAME}ConfigVersion.cmake
    DESTINATION
      ${CMAKE_INSTALL_DATADIR}/${PROJECT_NAME}
  )

  install(
    FILES
      ${PROJECT_BINARY_DIR}/lib/pkgconfig/${PROJECT_NAME_LOWER}.pc
    DESTINATION
      ${CMAKE_INSTALL_LIBDIR}/pkgconfig
  )

  # # To install other/non-system 3rd party required libraries:
  # configure_file(
  #   ${PROJECT_SOURCE_DIR}/support/cmake/FixBundle.cmake.in
  #   ${PROJECT_BINARY_DIR}/FixBundle.cmake
  #   @ONLY
  # )

  # install(SCRIPT ${CMAKE_BINARY_DIR}/FixBundle.cmake)

endif ()

get_target_property(_aliased ${PROJECT_NAME}::${PROJECT_NAME} ALIASED_TARGET)
if(_aliased)
  message(STATUS "The name '${PROJECT_NAME}::${PROJECT_NAME}' is an ALIAS for ${_aliased}.")
  message(STATUS "This package can be found by importing (or requiring) '@${PROJECT_NAME}/${PROJECT_NAME}' in a local Javascript project.")
endif()
