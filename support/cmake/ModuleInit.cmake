# SPDX-License-Identifier: (MIT OR CC0-1.0)
# Copyright 2020 Jan Tojnar
# https://github.com/jtojnar/cmake-snips
#
# Modelled after Python’s os.path.join
# https://docs.python.org/3.7/library/os.path.html#os.path.join
# Windows not supported
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
	# set version using external "VERSION" file
	file(READ ${CMAKE_CURRENT_SOURCE_DIR}/VERSION.txt LOCAL_VERSION)
	string(REGEX MATCH "([0-999]*).[0-999].[0-999].[0-999]" _ ${LOCAL_VERSION})
	set(LOCAL_VERSION_MAJOR ${CMAKE_MATCH_1})
	string(REGEX MATCH "[0-999].([0-999]*).[0-999].[0-999]" _ ${LOCAL_VERSION})
	set(LOCAL_VERSION_MINOR ${CMAKE_MATCH_1})
	string(REGEX MATCH "[0-999].[0-999].([0-999]*).[0-999]" _ ${LOCAL_VERSION})
	set(LOCAL_VERSION_PATCH ${CMAKE_MATCH_1})
	string(REGEX MATCH "[0-999].[0-999].[0-999].([0-999]*)" _ ${LOCAL_VERSION})
	set(LOCAL_VERSION_TWEAK ${CMAKE_MATCH_1})
	set(_ "")
	message(STATUS "Detected Project version: v${LOCAL_VERSION_MAJOR}.${LOCAL_VERSION_MINOR}.${LOCAL_VERSION_PATCH}.${LOCAL_VERSION_TWEAK}")
endfunction()

function(cmake_defaults)

	# Set the host architecture to build with
	if (CMAKE_SIZEOF_VOID_P EQUAL 8)
		set(USE_X64 TRUE)
	else ()
		set(USE_X64 FALSE)
	endif ()

	# Ensure a valid build type is set
	if (NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
		if (${PROJECT_NAME}_MASTER_PROJECT)
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

	# Set the binary output dir, if not set
	if (NOT CMAKE_RUNTIME_OUTPUT_DIRECTORY)
		set(CMAKE_RUNTIME_OUTPUT_DIRECTORY  "${CMAKE_BINARY_DIR}/bin" CACHE PATH "Executable/dll output dir.")
	endif ()

	if (NOT CMAKE_ARCHIVE_OUTPUT_DIRECTORY)
		set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY  "${CMAKE_BINARY_DIR}/lib" CACHE PATH "Archive output dir.")
	endif ()

	if (NOT CMAKE_LIBRARY_OUTPUT_DIRECTORY)
		set(CMAKE_LIBRARY_OUTPUT_DIRECTORY  "${CMAKE_BINARY_DIR}/lib" CACHE PATH "Library output dir.")
	endif ()

	if (NOT CMAKE_PDB_OUTPUT_DIRECTORY)
		set(CMAKE_PDB_OUTPUT_DIRECTORY      "${CMAKE_BINARY_DIR}/bin" CACHE PATH "PDB (MSVC debug symbol)output dir.")
	endif ()

	# export symbols on Windows for shared libraries to work
	set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)

endfunction()

function(project_defaults)

	string(TOUPPER ${PROJECT_NAME} PROJECT_NAME_UPPER)
	string(TOLOWER ${PROJECT_NAME} PROJECT_NAME_LOWER)
	set(${PROJECT_NAME}_DEBUG_POSTFIX d CACHE STRING "Debug library postfix.")

	# Determine if built as a subproject (using add_subdirectory)
	# or if it is the master project.
	if (NOT DEFINED ${PROJECT_NAME}_MASTER_PROJECT)
		set(${PROJECT_NAME}_MASTER_PROJECT OFF)
		if (CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
			set(${PROJECT_NAME}_MASTER_PROJECT ON)
			message(STATUS "${PROJECT_NAME} is a top-level project\n")
		else ()
			message(STATUS "${PROJECT_NAME} is a sub-project of ${CMAKE_PROJECT_NAME}\n")
		endif ()
	endif ()

	# Options that control generation of various targets.
	option(${PROJECT_NAME}_DOC "Generate the doc target." ${${PROJECT_NAME}_MASTER_PROJECT})
	option(${PROJECT_NAME}_INSTALL "Generate the install target." ON)
	option(${PROJECT_NAME}_TEST "Generate the test target." ${${PROJECT_NAME}_MASTER_PROJECT})
	option(${PROJECT_NAME}_FUZZ "Generate the fuzz target." OFF)
	option(${PROJECT_NAME}_OS "Include core requiring OS (Windows/Posix) " ON)
	option(${PROJECT_NAME}_MODULE "Build a module instead of a traditional library." OFF)
	option(${PROJECT_NAME}_SYSTEM_HEADERS "Expose headers with marking them as system." OFF)

	# Generate CMAKE_INSTALL_<DIR> etc...
	include(GNUInstallDirs)

	# Configure folder structure.
	set(${PROJECT_NAME}_INC_DIR         	   ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}   CACHE PATH "Installation directory for include files, a relative path that will be joined with ${CMAKE_INSTALL_PREFIX} or an absolute path.")
	set(${PROJECT_NAME}_LIB_DIR              ${CMAKE_INSTALL_LIBDIR}                       CACHE PATH "Installation directory for libraries, a relative path that will be joined to ${CMAKE_INSTALL_PREFIX} or an absolute path.")
	set(${PROJECT_NAME}_CMAKE_DIR            ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME} CACHE PATH "Installation directory for CMake (.cmake) files, a relative path that will be joined with ${CMAKE_INSTALL_PREFIX} or an absolute path.")
	set(${PROJECT_NAME}_PKGCONFIG_DIR   		 ${CMAKE_INSTALL_LIBDIR}/pkgconfig             CACHE PATH "Installation directory for pkgconfig (.pc) files, a relative path that will be joined with ${CMAKE_INSTALL_PREFIX} or an absolute path.")

	# Configure files.
	set(${PROJECT_NAME}_VERSION_CONFIG       ${PROJECT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake CACHE PATH "Location of generated <project_name>ConfigVersion.cmake file")
	set(${PROJECT_NAME}_PROJECT_CONFIG       ${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.cmake CACHE PATH "Location of generated <project_name>Config.cmake file")
	set(${PROJECT_NAME}_CM_VARS_CONFIG       ${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.h CACHE PATH "Location of generated <project_name>Config.h file")
	set(${PROJECT_NAME}_PACKAGE_CONFIG       ${PROJECT_BINARY_DIR}/${PROJECT_NAME_LOWER}.pc)
	set(${PROJECT_NAME}_VCPKG_MNFST          ${PROJECT_BINARY_DIR}/vcpkg.json)
	set(${PROJECT_NAME}_VCPKG_CONFIG         ${PROJECT_BINARY_DIR}/vcpkg-configuration.json)
	set(${PROJECT_NAME}_PORT_FILE            ${PROJECT_BINARY_DIR}/${PROJECT_NAME_LOWER}-portfile.cmake)
	set(${PROJECT_NAME}_TARGETS_EXPORT_NAME  ${PROJECT_NAME}Targets)

	if (${PROJECT_NAME}_MASTER_PROJECT AND NOT DEFINED CMAKE_CXX_VISIBILITY_PRESET)
		set(CMAKE_CXX_VISIBILITY_PRESET hidden CACHE STRING "Preset for the export of private symbols")
		set_property(CACHE CMAKE_CXX_VISIBILITY_PRESET PROPERTY STRINGS hidden default)
	endif ()

	if (${PROJECT_NAME}_MASTER_PROJECT AND NOT DEFINED CMAKE_VISIBILITY_INLINES_HIDDEN)
		set(CMAKE_VISIBILITY_INLINES_HIDDEN ON CACHE BOOL "Whether to add a compile flag to hide symbols of inline functions")
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

	include(InstallRequiredSystemLibraries)

	# set(CPACK_PACKAGE_VENDOR ${CMAKE_PROJECT_VENDOR})
	set(CPACK_PACKAGE_DESCRIPTION_SUMMARY ${PROJECT_DESCRIPTION})
	set(CPACK_PACKAGE_VERSION_MAJOR ${LOCAL_VERSION_MAJOR})
	set(CPACK_PACKAGE_VERSION_MINOR ${LOCAL_VERSION_MINOR})
	set(CPACK_PACKAGE_VERSION_PATCH ${LOCAL_VERSION_PATCH})
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

endfunction()



function(add_headers VAR)
set(headers ${${VAR}})
foreach (header ${ARGN})
	set(headers ${headers} include/${PROJECT_NAME}/${header})
endforeach()
set(${VAR} ${headers} PARENT_SCOPE)
endfunction()


	# get access to helper functions for creating config files
	include(CMakePackageConfigHelpers)
