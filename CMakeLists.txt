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
# Single-threaded build-runs only for compatible behaviour
set(CMAKE_BUILD_PARALLEL_LEVEL 1)
# Set the host architecture to build with
if (CMAKE_SIZEOF_VOID_P EQUAL 8)
  set(USE_X64 TRUE)
else ()
  set(USE_X64 FALSE)
endif ()
set(CMAKE_INSTALL_MODE SYMLINK)

# Joins arguments and places the results in ${result_var}.
function(join result_var)
  set(result "")
  foreach (arg ${ARGN})
    set(result "${result}${arg}")
  endforeach ()
  set(${result_var} "${result}" PARENT_SCOPE)
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

# Sets a cache variable with a docstring joined from multiple arguments:
#   set(<variable> <value>... CACHE <type> <docstring>...)
# This allows splitting a long docstring for readability.
function(set_verbose)
  # cmake_parse_arguments is broken in CMake 3.4 (cannot parse CACHE) so use
  # list instead.
  list(GET ARGN 0 var)
  list(REMOVE_AT ARGN 0)
  list(GET ARGN 0 val)
  list(REMOVE_AT ARGN 0)
  list(REMOVE_AT ARGN 0)
  list(GET ARGN 0 type)
  list(REMOVE_AT ARGN 0)
  join(doc ${ARGN})
  set(${var} ${val} CACHE ${type} ${doc})
endfunction()



# Set the binary output dir, if not set
if (NOT CMAKE_RUNTIME_OUTPUT_DIRECTORY)
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY  "${CMAKE_BINARY_DIR}/bin" CACHE PATH "Executable/dll output dir.")
endif ()
# Set the archive output dir, if not set
if (NOT CMAKE_ARCHIVE_OUTPUT_DIRECTORY)
  set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY  "${CMAKE_BINARY_DIR}/lib" CACHE PATH "Archive output dir.")
endif ()
# Set the library output dir, if not set
if (NOT CMAKE_LIBRARY_OUTPUT_DIRECTORY)
  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY  "${CMAKE_BINARY_DIR}/lib" CACHE PATH "Library output dir.")
endif ()
# Set the MSVC debug symbol output dir, if not set
if (NOT CMAKE_PDB_OUTPUT_DIRECTORY)
  set(CMAKE_PDB_OUTPUT_DIRECTORY      "${CMAKE_BINARY_DIR}/bin" CACHE PATH "PDB (MSVC debug symbol)output dir.")
endif ()
set(CMAKE_CFG_INTDIR                  "${CMAKE_BINARY_DIR}"     CACHE PATH "CMake build artefacts directory.")


# Build using shared libraries. if this is set to ON, then all libraries are built as shared libraries by default.
option(BUILD_SHARED_LIBS "Build using shared libraries." OFF)
# option for outputting compiler information at runtime
option(OUTPUT_COMPILER_INFO "Output compiler information when launching the main executable." ON)
# Build with Address Sanitizer
option(ASAN_ENABLED "Build with Address Sanitizer" OFF)
# Use the target 'FOLDER' property to organize targets into folders
set(USE_FOLDERS OFF)
# https://stackoverflow.com/questions/48580399/how-to-ensure-a-generated-config-h-file-is-in-the-include-path
set(CMAKE_INCLUDE_CURRENT_DIR ON)
# export symbols on Windows for shared libraries to work
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)


## Create Project
project("cmodule"
  VERSION 1.0.0.0
  DESCRIPTION "NodeJS module written in C++"
  HOMEPAGE_URL "https://github.com/StoneyDSP/cmodule"
  LANGUAGES CXX
)


message(STATUS "Detected ${PROJECT_NAME} version: v${${PROJECT_NAME}_VERSION_MAJOR}.${${PROJECT_NAME}_VERSION_MINOR}.${${PROJECT_NAME}_VERSION_PATCH}.${${PROJECT_NAME}_VERSION_TWEAK}")

# Parse the project name into vars
string(TOUPPER ${PROJECT_NAME} PROJECT_NAME_UPPER)
string(TOLOWER ${PROJECT_NAME} PROJECT_NAME_LOWER)
set(${PROJECT_NAME_UPPER}_DEBUG_POSTFIX d CACHE STRING "Debug library postfix.")


# Generate CMAKE_INSTALL_<DIR> etc...
if (NOT CMAKE_INSTALL_BINDIR)
  set(CMAKE_INSTALL_BINDIR /bin CACHE PATH "User executables (bin)")
endif ()
if (NOT CMAKE_INSTALL_DATADIR)
  set(CMAKE_INSTALL_DATADIR /share CACHE PATH "Read-only architecture-independent data (DATAROOTDIR)")
endif ()
if (NOT CMAKE_INSTALL_DATAROOTDIR)
  set(CMAKE_INSTALL_DATAROOTDIR "/" CACHE PATH "Read-only architecture-independent data root (share)")
endif ()
if (NOT CMAKE_INSTALL_DOCDIR)
  set(CMAKE_INSTALL_DOCDIR ${CMAKE_INSTALL_DATAROOTDIR}/doc/${PROJECT_NAME} CACHE PATH "Documentation root (DATAROOTDIR/doc/PROJECT_NAME)")
endif ()
if (NOT CMAKE_INSTALL_INCLUDEDIR)
  set(CMAKE_INSTALL_INCLUDEDIR /include CACHE PATH "C/C++ header files (include)")
endif ()
if (NOT CMAKE_INSTALL_INFODIR)
  set(CMAKE_INSTALL_INFODIR ${CMAKE_INSTALL_DATAROOTDIR}/info CACHE PATH "Info documentation (DATAROOTDIR/info)")
endif ()
if (NOT CMAKE_INSTALL_LIBDIR)
  set(CMAKE_INSTALL_LIBDIR /lib CACHE PATH "Object code libraries (lib)")
endif ()
if (NOT CMAKE_INSTALL_LIBEXECDIR)
  set(CMAKE_INSTALL_LIBEXECDIR /libexec CACHE PATH "Program executables (libexec)")
endif ()
if (NOT CMAKE_INSTALL_LOCALEDIR)
  set(CMAKE_INSTALL_LOCALEDIR ${CMAKE_INSTALL_DATAROOTDIR}/locale CACHE PATH "Locale-dependent data (DATAROOTDIR/locale)")
endif ()
if (NOT CMAKE_INSTALL_LOCALSTATEDIR)
  set(CMAKE_INSTALL_LOCALSTATEDIR /var CACHE PATH "Modifiable single-machine data (var)")
endif ()
if (NOT CMAKE_INSTALL_MANDIR)
  set(CMAKE_INSTALL_MANDIR ${CMAKE_INSTALL_DATAROOTDIR}/man CACHE PATH "Man documentation (DATAROOTDIR/man)")
endif ()
if (NOT CMAKE_INSTALL_RUNSTATEDIR)
  set(CMAKE_INSTALL_RUNSTATEDIR ${CMAKE_INSTALL_LOCALSTATEDIR}/run CACHE PATH "Run-time variable data (LOCALSTATEDIR/run)")
endif ()
if (NOT CMAKE_INSTALL_SBINDIR)
  set(CMAKE_INSTALL_SBINDIR /sbin CACHE PATH "System admin executables (sbin)")
endif ()
if (NOT CMAKE_INSTALL_SHAREDSTATEDIR)
  set(CMAKE_INSTALL_SHAREDSTATEDIR /com CACHE PATH "Modifiable architecture-independent data (com)")
endif ()
if (NOT CMAKE_INSTALL_SYSCONFDIR)
  set(CMAKE_INSTALL_SYSCONFDIR /etc CACHE PATH "Read-only single-machine data (etc)")
endif ()
include(GNUInstallDirs)

# get access to helper functions for creating config files
include(CMakePackageConfigHelpers)

## Configure folder structure.
set(${PROJECT_NAME_UPPER}_LIB_DIR              ${CMAKE_INSTALL_LIBDIR}                       CACHE PATH "Installation directory for libraries, a relative path that will be joined to ${CMAKE_INSTALL_PREFIX} or an absolute path.")
set(${PROJECT_NAME_UPPER}_INC_DIR         	   ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}   CACHE PATH "Installation directory for include files, a relative path that will be joined with ${CMAKE_INSTALL_PREFIX} or an absolute path.")
set(${PROJECT_NAME_UPPER}_SRC_DIR              ${CMAKE_INSTALL_LIBDIR}                       CACHE PATH "Installation directory for libraries, a relative path that will be joined to ${CMAKE_INSTALL_PREFIX} or an absolute path.")
set(${PROJECT_NAME_UPPER}_CMAKE_DIR            ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME} CACHE PATH "Installation directory for CMake (.cmake) files, a relative path that will be joined with ${CMAKE_INSTALL_PREFIX} or an absolute path.")
set(${PROJECT_NAME_UPPER}_PKGCONFIG_DIR   		 ${CMAKE_INSTALL_LIBDIR}/pkgconfig             CACHE PATH "Installation directory for pkgconfig (.pc) files, a relative path that will be joined with ${CMAKE_INSTALL_PREFIX} or an absolute path.")
set(CMAKE_MODULE_PATH
  ${CMAKE_MODULE_PATH}
  ${CMAKE_CURRENT_SOURCE_DIR}/support/cmake
)

## Configure files.
set(${PROJECT_NAME_UPPER}_VERSION_CONFIG       ${PROJECT_SOURCE_DIR}/share/${PROJECT_NAME}ConfigVersion.cmake CACHE STRING "Location of generated <project_name>ConfigVersion.cmake file")
set(${PROJECT_NAME_UPPER}_PROJECT_CONFIG       ${PROJECT_SOURCE_DIR}/share/${PROJECT_NAME}Config.cmake CACHE STRING "Location of generated <project_name>Config.cmake file")
set(${PROJECT_NAME_UPPER}_CM_VARS_CONFIG       ${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.h CACHE STRING "Location of generated <project_name>Config.h file")
# set(${PROJECT_NAME_UPPER}_PACKAGE_CONFIG       ${PROJECT_BINARY_DIR}/${PROJECT_NAME_LOWER}.pc CACHE STRING "Location of generated <project_name>.pc file")
set(${PROJECT_NAME_UPPER}_PACKAGE_CONFIG       ${PROJECT_SOURCE_DIR}/lib/pkgconfig/${PROJECT_NAME_LOWER}.pc CACHE STRING "Location of generated <project_name>.pc file")
set(${PROJECT_NAME_UPPER}_VCPKG_MNFST          ${PROJECT_BINARY_DIR}/vcpkg.json CACHE STRING "Location of generated vcpkg.json file")
set(${PROJECT_NAME_UPPER}_VCPKG_CONFIG         ${PROJECT_BINARY_DIR}/vcpkg-configuration.json CACHE STRING "Location of generated vcpkg-configuration.json file")
set(${PROJECT_NAME_UPPER}_PORT_FILE            ${PROJECT_BINARY_DIR}/${PROJECT_NAME_LOWER}-portfile.cmake CACHE STRING "Location of generated <project_name>-portfile.cmake file")
set(TARGETS_EXPORT_NAME  											 ${PROJECT_NAME}Targets CACHE STRING "Name generated <project_name>Targets variable")
# Read the .gitignore file, if found
if (${CMAKE_CURRENT_SOURCE_DIR}/.gitignore)
  file(READ ${CMAKE_CURRENT_SOURCE_DIR}/.gitignore ${PROJECT_NAME}_GITIGNORE_FILE)
endif()
# Read the .gitattributes file, if found
if (${CMAKE_CURRENT_SOURCE_DIR}/.gitattributes)
  file(READ ${CMAKE_CURRENT_SOURCE_DIR}/.gitattributes ${PROJECT_NAME}_GITATTRIBUTES_FILE)
endif()

# Determine if built as a subproject (using add_subdirectory), or if it is the master project.
if (NOT DEFINED ${PROJECT_NAME_UPPER}_MASTER_PROJECT)
  set(${PROJECT_NAME_UPPER}_MASTER_PROJECT OFF)
  if (CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
    set(${PROJECT_NAME_UPPER}_MASTER_PROJECT ON)
    message(STATUS "${PROJECT_NAME} is a top-level CMake project\n")
  else ()
    message(STATUS "${PROJECT_NAME} is a sub-project of ${CMAKE_PROJECT_NAME}\n")
  endif ()
endif ()

# Ensure a valid build type is set
if (NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  if (${PROJECT_NAME_UPPER}_MASTER_PROJECT)
    set(DEFAULT_BUILD_TYPE Debug)
  else ()
    message(WARNING "Default build type is not set (CMAKE_BUILD_TYPE)")
  endif ()
  message(STATUS "Setting build type to '${DEFAULT_BUILD_TYPE}' as none was specified.")
  set(CMAKE_BUILD_TYPE "${DEFAULT_BUILD_TYPE}" CACHE STRING "Choose the type of build." FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif ()

# Print the flags for the user
if (DEFINED CMAKE_BUILD_TYPE)
  message(STATUS "Generated CMake build type: ${CMAKE_BUILD_TYPE}")
else ()
  message(STATUS "Generated CMake config types: ${CMAKE_CONFIGURATION_TYPES}")
endif ()

option(${PROJECT_NAME_UPPER}_PEDANTIC "Enable extra warnings and expensive tests." OFF)
option(${PROJECT_NAME_UPPER}_WERROR "Halt the compilation with an error on compiler warnings." OFF)
# Options that control generation of various targets.
option(${PROJECT_NAME_UPPER}_DOC "Generate the doc target." ${${PROJECT_NAME_UPPER}_MASTER_PROJECT})
option(${PROJECT_NAME_UPPER}_INSTALL "Generate the install target." ON)
option(${PROJECT_NAME_UPPER}_TEST "Generate the test target." ${${PROJECT_NAME_UPPER}_MASTER_PROJECT})
# option(${PROJECT_NAME_UPPER}_FUZZ "Generate the fuzz target." OFF)
# option(${PROJECT_NAME_UPPER}_MODULE "Build a module instead of a traditional library." OFF)
option(${PROJECT_NAME_UPPER}_SYSTEM_HEADERS "Expose headers with marking them as system." OFF)

if (${PROJECT_NAME}_MASTER_PROJECT AND NOT DEFINED CMAKE_CXX_VISIBILITY_PRESET)
  set(CMAKE_CXX_VISIBILITY_PRESET hidden CACHE STRING "Preset for the export of private symbols")
  set_property(CACHE CMAKE_CXX_VISIBILITY_PRESET PROPERTY STRINGS hidden default)
endif ()

if (${PROJECT_NAME}_MASTER_PROJECT AND NOT DEFINED CMAKE_VISIBILITY_INLINES_HIDDEN)
  set(CMAKE_VISIBILITY_INLINES_HIDDEN ON CACHE BOOL "Whether to add a compile flag to hide symbols of inline functions")
endif ()

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
  if (HAS_NULLPTR_WARNING)
    set(PEDANTIC_COMPILE_FLAGS ${PEDANTIC_COMPILE_FLAGS}
        -Wzero-as-null-pointer-constant)
  endif ()
  set(WERROR_FLAG -Werror)
endif ()

if (MSVC)
  set(PEDANTIC_COMPILE_FLAGS /W3)
  set(WERROR_FLAG /WX)
endif ()

if (${PROJECT_NAME_UPPER}_MASTER_PROJECT AND CMAKE_GENERATOR MATCHES "Visual Studio")
  # If Microsoft SDK is installed create script run-msbuild.bat that
  # calls SetEnv.cmd to set up build environment and runs msbuild.
  # It is useful when building Visual Studio projects with the SDK
  # toolchain rather than Visual Studio.
  find_program(WINSDK_SETENV NAMES SetEnv.cmd
    PATHS "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Microsoft SDKs\\Windows;CurrentInstallFolder]/bin")
  if (WINSDK_SETENV AND PRINT_PATH)
    execute_process(COMMAND ${CMAKE_COMMAND} -E echo "${WINSDK_SETENV}")
  endif ()
  if (WINSDK_SETENV)
    set(MSBUILD_SETUP "call \"${WINSDK_SETENV}\"")
  endif ()
  # Set FrameworkPathOverride to get rid of MSB3644 warnings.
  join(netfxpath
       "C:\\Program Files\\Reference Assemblies\\Microsoft\\Framework\\"
       ".NETFramework\\v4.0")
  file(WRITE run-msbuild.bat "
    ${MSBUILD_SETUP}
    ${CMAKE_MAKE_PROGRAM} -p:FrameworkPathOverride=\"${netfxpath}\" %*")
endif ()

# Copyright 2020 Jan Tojnar (MIT)
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
join_paths(libdir_for_pc_file "\${exec_prefix}" "${CMAKE_INSTALL_LIBDIR}")
join_paths(includedir_for_pc_file "\${prefix}" "${CMAKE_INSTALL_INCLUDEDIR}")

# create config header
message(STATUS "Creating config header file...")
configure_file(
  ${PROJECT_SOURCE_DIR}/support/cmake/${PROJECT_NAME}Config.h.in
  ${${PROJECT_NAME_UPPER}_CM_VARS_CONFIG})
message(STATUS "Created config header file at ${${PROJECT_NAME_UPPER}_CM_VARS_CONFIG}\n")

# create config file
message(STATUS "Creating project config file...")
configure_package_config_file(
    ${PROJECT_SOURCE_DIR}/support/cmake/${PROJECT_NAME}Config.cmake.in
    ${${PROJECT_NAME_UPPER}_PROJECT_CONFIG}
  INSTALL_DESTINATION
    ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}
)
message(STATUS "Created project config file at ${${PROJECT_NAME_UPPER}_PROJECT_CONFIG}\n")

# create version config file
message(STATUS "Creating the version file for the config file...")
write_basic_package_version_file(
  ${${PROJECT_NAME_UPPER}_VERSION_CONFIG}
  VERSION ${${PROJECT_NAME}_VERSION}
  COMPATIBILITY AnyNewerVersion
)
message(STATUS "Created version file for the config file at ${${PROJECT_NAME_UPPER}_VERSION_CONFIG}\n")

# create pkgconfig file
message(STATUS "Creating pkgconfig file...")
configure_file(
  ${PROJECT_SOURCE_DIR}/support/cmake/${PROJECT_NAME}.pc.in
  ${${PROJECT_NAME_UPPER}_PACKAGE_CONFIG}
  @ONLY
)
message(STATUS "Created pkgconfig file at ${${PROJECT_NAME_UPPER}_PACKAGE_CONFIG}\n")

# create vcpkg manifest file
message(STATUS "Creating vcpkg manifest...")
configure_file(
  ${PROJECT_SOURCE_DIR}/support/vcpkg/vcpkg.in.json
  ${${PROJECT_NAME_UPPER}_VCPKG_MNFST}
)
message(STATUS "Created vcpkg manifest at ${${PROJECT_NAME_UPPER}_VCPKG_MNFST}\n")

# create vcpkg configuration file
message(STATUS "Creating vcpkg configuration...")
configure_file(
  ${PROJECT_SOURCE_DIR}/support/vcpkg/vcpkg-configuration.in.json
  ${${PROJECT_NAME_UPPER}_VCPKG_CONFIG}
)
message(STATUS "Created vcpkg configuration at ${${PROJECT_NAME_UPPER}_VCPKG_CONFIG}\n")

# create vcpkg portfile
message(STATUS "Creating vcpkg portfile...")
configure_file(
  ${PROJECT_SOURCE_DIR}/support/vcpkg/portfile.in.cmake
  ${${PROJECT_NAME_UPPER}_PORT_FILE}
)
message(STATUS "Created vcpkg portfile at ${${PROJECT_NAME_UPPER}_PORT_FILE}\n")



include_directories(${CMAKE_JS_INC} include/${PROJECT_NAME})

# Collect header include files
function(add_headers VAR)
	set(headers ${${VAR}})
	foreach (header ${ARGN})
		set(headers ${headers} include/${PROJECT_NAME}/${header})
	endforeach()
	set(${VAR} ${headers} PARENT_SCOPE)
endfunction()
add_headers(${PROJECT_NAME_UPPER}_HEADERS "cmodule.h")
# Collect source files
function(add_sources VAR)
	set(sources ${${VAR}})
	foreach (source ${ARGN})
		set(sources ${sources} src/${source})
	endforeach()
	set(${VAR} ${sources} PARENT_SCOPE)
endfunction()
add_sources(${PROJECT_NAME_UPPER}_SOURCES "cmodule.cc")
# file(GLOB ${PROJECT_NAME_UPPER}_SOURCES ${CMAKE_JS_SRC} "./src/cmodule.cc")
# Add the library as an output target
add_library(${PROJECT_NAME} SHARED ${CMAKE_JS_SRC} README.rst LICENSE VERSION.txt index.js .gitignore)
add_library(${PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME})
set_target_properties(${PROJECT_NAME} PROPERTIES PREFIX "" SUFFIX ".node")
target_link_libraries(${PROJECT_NAME} ${CMAKE_JS_LIB})

if(MSVC AND CMAKE_JS_NODELIB_DEF AND CMAKE_JS_NODELIB_TARGET)
  # Generate node.lib
  execute_process(COMMAND ${CMAKE_AR} /def:${CMAKE_JS_NODELIB_DEF} /out:${CMAKE_JS_NODELIB_TARGET} ${CMAKE_STATIC_LINKER_FLAGS})
endif()

# Add source files and headers to target.
target_sources(${PROJECT_NAME}
  PRIVATE
    ${${PROJECT_NAME_UPPER}_HEADERS}
    ${${PROJECT_NAME_UPPER}_SOURCES}
)

# Include Node-API wrappers
execute_process(
  COMMAND node -p "require('node-addon-api').include"
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
  OUTPUT_VARIABLE NODE_ADDON_API_DIR
)
string(REGEX REPLACE "[\r\n\"]" "" NODE_ADDON_API_DIR ${NODE_ADDON_API_DIR})
target_include_directories(${PROJECT_NAME} PRIVATE ${NODE_ADDON_API_DIR})
# define NAPI_VERSION
add_definitions(-DNAPI_VERSION=4)
# add include directories
target_include_directories(${PROJECT_NAME}
PUBLIC
  $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include/${PROJECT_NAME}>
  $<INSTALL_INTERFACE:${PROJECT_NAME_UPPER}_INC_DIR>
)
# Set compiler flags
if (${PROJECT_NAME_UPPER}_WERROR)
  target_compile_options(${PROJECT_NAME} PRIVATE ${WERROR_FLAG})
endif ()
if (${PROJECT_NAME_UPPER}_PEDANTIC)
  target_compile_options(${PROJECT_NAME} PRIVATE ${PEDANTIC_COMPILE_FLAGS})
endif ()
# if (${PROJECT_NAME}_MODULE)
#   enable_module(${PROJECT_NAME})
# endif ()
target_compile_features(${PROJECT_NAME} PUBLIC cxx_std_11)
# Set target version and properties.
set_target_properties(${PROJECT_NAME}
PROPERTIES
  RUNTIME_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/bin
  LIBRARY_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/lib
  ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/lib
  PDB_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/bin
  PUBLIC_HEADER ${PROJECT_NAME_UPPER}_HEADERS
  DEBUG_POSTFIX ${PROJECT_NAME_UPPER}_DEBUG_POSTFIX
  INTERFACE_${PROJECT_NAME_UPPER}_VERSION_MAJOR ${${PROJECT_NAME}_VERSION_MAJOR}
)
set_property(TARGET ${PROJECT_NAME} APPEND PROPERTY COMPATIBLE_INTERFACE_STRING ${PROJECT_NAME_UPPER}_VERSION_MAJOR)
# Dont define these two props on your targets!!
# They cause symlinks to be generated that node cannot parse
# VERSION "${${PROJECT_NAME}_VERSION_MAJOR}.${${PROJECT_NAME}_VERSION_MINOR}.${${PROJECT_NAME}_VERSION_PATCH}.${${PROJECT_NAME}_VERSION_TWEAK}"
# SOVERSION "${${PROJECT_NAME}_VERSION_MAJOR}"

# Set LIB_NAME for pkg-config fmt.pc. We cannot use the OUTPUT_NAME target
# property because it's not set by default.
set(${PROJECT_NAME_UPPER}_LIB_NAME ${PROJECT_NAME_LOWER})
if (CMAKE_BUILD_TYPE STREQUAL "Debug")
  set(${PROJECT_NAME_UPPER}_LIB_NAME ${${PROJECT_NAME_UPPER}_LIB_NAME}${${PROJECT_NAME_UPPER}_DEBUG_POSTFIX})
endif ()

# Configure CTest
enable_testing()
add_test(NAME Runs COMMAND node "${PROJECT_SOURCE_DIR}/test/run.js")


# Configure CPack
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY ${PROJECT_DESCRIPTION})
set(CPACK_PACKAGE_VERSION_MAJOR ${${PROJECT_NAME}_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${${PROJECT_NAME}_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${${PROJECT_NAME}_VERSION_PATCH})
set(CPACK_RESOURCE_FILE_LICENSE ${CMAKE_CURRENT_LIST_DIR}/LICENSE)
set(CPACK_RESOURCE_FILE_README ${CMAKE_CURRENT_LIST_DIR}/README.rst)
set(CPACK_SOURCE_GENERATOR "TGZ;ZIP")
set(CPACK_SOURCE_IGNORE_FILES
  /.git/*
  /.github
  /.vs
  /.vscode
  /build
  /downloads
  /installed
  /node_modules
  /vcpkg
  /.*build.*
  /\\\\.DS_Store
)
include(CPack)

message("CPACK_PACKAGE_VENDOR = ${CPACK_PACKAGE_VENDOR}")
message("CPACK_PACKAGE_DESCRIPTION_SUMMARY = ${PROJECT_DESCRIPTION}")
message("CPACK_PACKAGE_VERSION_MAJOR = ${${PROJECT_NAME}_VERSION_MAJOR}")
message("CPACK_PACKAGE_VERSION_MINOR = ${${PROJECT_NAME}_VERSION_MINOR}")
message("CPACK_PACKAGE_VERSION_PATCH = ${${PROJECT_NAME}_VERSION_PATCH}")
message("CPACK_RESOURCE_FILE_LICENSE = ${CMAKE_CURRENT_LIST_DIR}/LICENCE")
message("CPACK_RESOURCE_FILE_README = ${CMAKE_CURRENT_LIST_DIR}/README.md")
message("CPACK_SOURCE_GENERATOR = ${CPACK_SOURCE_GENERATOR}")
message("CPack ignores: ${CPACK_SOURCE_IGNORE_FILES}\n")

# Install the library and headers.
install(
  TARGETS ${PROJECT_NAME}
  EXPORT ${TARGETS_EXPORT_NAME}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}
  PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}
  FRAMEWORK DESTINATION "."
)

# Use a namespace because CMake provides better diagnostics for namespaced
# imported targets.
export(
  TARGETS ${PROJECT_NAME}
  NAMESPACE ${PROJECT_NAME}::
  FILE ${PROJECT_SOURCE_DIR}/share/${TARGETS_EXPORT_NAME}.cmake
)

# Install version, config and target files.
install(
  FILES
    ${${PROJECT_NAME_UPPER}_PROJECT_CONFIG}
    ${${PROJECT_NAME_UPPER}_VERSION_CONFIG}
  DESTINATION
    share/${PROJECT_NAME}
)

install(
  EXPORT ${TARGETS_EXPORT_NAME}
  DESTINATION share/${PROJECT_NAME}
  NAMESPACE ${PROJECT_NAME}::
)

install(
  FILES ${${PROJECT_NAME_UPPER}_PACKAGE_CONFIG}
  DESTINATION ${${PROJECT_NAME_UPPER}_PKGCONFIG_DIR}
)
