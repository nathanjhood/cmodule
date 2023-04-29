# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

#[=======================================================================[.rst:
FindCMakeJs
--------

Find the native CMakeJs includes, source, and library

This module defines

::

  CMAKE_JS_INC, where to find node.h, etc.
  CMAKE_JS_LIB, the libraries required to use CMakeJs.
  CMAKE_JS_SRC, where to find required *.cpp files, if any
  CMAKE_JS_FOUND, If false, do not try to use CMakeJs.

also defined, but not for general use are

::

  MPEG_mpeg2_LIBRARY, where to find the MPEG library.
  MPEG_vo_LIBRARY, where to find the vo library.
#]=======================================================================]

# CMAKE_JS_INC is defined on all platforms when calling from cmake-js.
# By checking whether this var is pre-defined, we can determine if we are
# running from an npm script (via cmake-js), or from CMake directly...

# include(FindNode)

if (NOT DEFINED CMAKE_JS_INC)

    # ...and if we're calling from CMake directly, we need to set up some vars
    # that our build step depends on (these are predefined when calling via npm/cmake-js).
    message(STATUS "CMake Calling...")

    # Check for cmake-js installations
    find_program(CMAKE_JS_EXECUTABLE
        NAMES "cmake-js" "cmake-js.exe"
        PATHS "$ENV{PATH}" "$ENV{ProgramFiles}/cmake-js"
        DOC "cmake-js system executable binary"
        REQUIRED
    )
    if (NOT CMAKE_JS_EXECUTABLE)
        message(FATAL_ERROR "cmake-js system installation not found! Please run 'npm -g install cmake-js@latest' and try again.")
    endif()

    find_program(CMAKE_JS_NPM_PACKAGE
        NAMES "cmake-js" "cmake-js.exe"
        PATHS "${CMAKE_CURRENT_LIST_DIR}/node_modules/cmake-js/bin"
        DOC "cmake-js project-local npm package binary"
        REQUIRED
    )
    if (NOT CMAKE_JS_NPM_PACKAGE)
        message(FATAL_ERROR "cmake-js project-local npm package not found! Please run 'npm install' and try again.")
    endif()

    # Create and initialize the vars we need, and store them in the CMakeCache file
    # set(CMAKE_JS_INC "" CACHE STRING "cmake-js include directory.")
    # set(CMAKE_JS_SRC "" CACHE STRING "cmake-js source file.")
    # set(CMAKE_JS_LIB "" CACHE STRING "cmake-js lib file.")

    # Set up some handy defines for some of cmake-js' CLI commands, which can gives us the vars we need...
    set(CMAKE_JS_PRINT_INC_COMMAND ${NODE_EXECUTABLE} ./node_modules/cmake-js/bin/cmake-js print-cmakejs-include CACHE STRING "Get cmake-js includes here.")
    set(CMAKE_JS_PRINT_SRC_COMMAND ${NODE_EXECUTABLE} ./node_modules/cmake-js/bin/cmake-js print-cmakejs-src CACHE STRING "Get cmake-js sources here.")
    set(CMAKE_JS_PRINT_LIB_COMMAND ${NODE_EXECUTABLE} ./node_modules/cmake-js/bin/cmake-js print-cmakejs-lib CACHE STRING "Get cmake-js libs here.")


    # Execute the CLI commands we aliased above, and write their outputs into the cached vars
    # where the remaining build processes expect them to be...
    execute_process(
        COMMAND ${CMAKE_JS_PRINT_INC_COMMAND}
        WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
        OUTPUT_VARIABLE CMAKE_JS_INC
    )

    execute_process(
        COMMAND ${CMAKE_JS_PRINT_SRC_COMMAND}
        WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
        OUTPUT_VARIABLE CMAKE_JS_SRC
    )

    execute_process(
        COMMAND ${CMAKE_JS_PRINT_LIB_COMMAND}
        WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
        OUTPUT_VARIABLE CMAKE_JS_LIB
    )


    # Strip the vars of any unusual chars that might break the paths...
    string(REGEX REPLACE "[\r\n\"]" "" CMAKE_JS_INC ${CMAKE_JS_INC})
    string(REGEX REPLACE "[\r\n\"]" "" CMAKE_JS_SRC ${CMAKE_JS_SRC})
    string(REGEX REPLACE "[\r\n\"]" "" CMAKE_JS_LIB ${CMAKE_JS_LIB})

    set(CMAKE_JS_INC ${CMAKE_JS_INC} CACHE STRING "cmake-js include directory.")
    set(CMAKE_JS_SRC ${CMAKE_JS_SRC} CACHE STRING "cmake-js source file.")
    set(CMAKE_JS_LIB ${CMAKE_JS_LIB} CACHE STRING "cmake-js lib file.")


    # Log the vars to the console for sanity...
    message(STATUS "CMAKE_JS_INC = ${CMAKE_JS_INC}")
    message(STATUS "CMAKE_JS_SRC = ${CMAKE_JS_SRC}")
    message(STATUS "CMAKE_JS_LIB = ${CMAKE_JS_LIB}")

    # At this point, some warnings may occur re: the below (still investigating);
    # Define either NAPI_CPP_EXCEPTIONS or NAPI_DISABLE_CPP_EXCEPTIONS.
    #set (NAPI_CPP_EXCEPTIONS TRUE CACHE STRING "Define either NAPI_CPP_EXCEPTIONS or NAPI_DISABLE_CPP_EXCEPTIONS")
    add_definitions(-DNAPI_CPP_EXCEPTIONS) # Also needs /EHsc
    # add_definitions(-DNAPI_DISABLE_CPP_EXCEPTIONS)
else ()

    # ... we already are calling via npm/cmake-js, so we should already have all the vars we need!
    message(STATUS "CMakeJs Calling...")

    # Notwithstanding a quick sanity check, of course.
    message(STATUS "CMAKE_JS_LIB = ${CMAKE_JS_LIB}")
    message(STATUS "CMAKE_JS_INC = ${CMAKE_JS_INC}")
    message(STATUS "CMAKE_JS_SRC = ${CMAKE_JS_SRC}")

endif ()
