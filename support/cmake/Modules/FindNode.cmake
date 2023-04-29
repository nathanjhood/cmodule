
if (NOT DEFINED NODE_ADDON_API_INCLUDED)

    set(NODE_ADDON_API_INCLUDED TRUE CACHE BOOL "Node Addon API included in project (use as an include guard)")

    find_program(NODE_EXECUTABLE
        NAMES "node" "node.exe"
        PATHS "$ENV{PATH}" "$ENV{ProgramFiles}/nodejs"
        DOC "NodeJs executable binary"
        REQUIRED
    )
    message(STATUS "NODE_EXECUTABLE = ${NODE_EXECUTABLE}")

    find_program(NPX_EXECUTABLE
        NAMES "npx" "npx.exe"
        PATHS "$ENV{PATH}" "$ENV{ProgramFiles}/nodejs"
        DOC "npx package executable binary"
        REQUIRED
    )
    message(STATUS "NPX_EXECUTABLE = ${NPX_EXECUTABLE}")

    # Collect Node Addon-API headers into NODE_ADDON_API_DIR
    execute_process(
        COMMAND ${NODE_EXECUTABLE} -p "require('node-addon-api').include"
        WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
        OUTPUT_VARIABLE NODE_ADDON_API_DIR
    )
    string(REGEX REPLACE "[\r\n\"]" "" NODE_ADDON_API_DIR ${NODE_ADDON_API_DIR})
    set(NODE_ADDON_API_DIR ${NODE_ADDON_API_DIR} CACHE STRING "Node Addon-API headers directory")
    message(STATUS "NODE_ADDON_API_DIR = ${NODE_ADDON_API_DIR}")




    # if(NODE_EXECUTABLE)
    #     message(STATUS "Found NodeJS")
    #     set(NODE_ADDON_API_DIR "" CACHE STRING "Node Addon API directory.")
    #     set(NODE_EXECUTABLE_COMMAND ${NODE_EXECUTABLE} CACHE STRING "Get Node Addon API dir here.")
    #     # Collect Node Addon-API headers into NODE_ADDON_API_DIR
    #     execute_process(
    #         COMMAND "${NODE_EXECUTABLE_COMMAND} -p require('node-addon-api').include"
    #         WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    #         OUTPUT_VARIABLE NODE_ADDON_API_DIR
    #     )
    #     set(NODE_ADDON_API_DIR ${NODE_ADDON_API_DIR})
    # else()
    #     message(FATAL_ERROR "NodeJs system installation not found! Please install NodeJs and try again.")
    # endif()


    # if(NOT NPX_EXECUTABLE)
    #     message(FATAL_ERROR "npx system installation not found! Please install npm and try again.")
    # endif()

    # # REGISTRY_VIEW (64|32|64_32|32_64|HOST|TARGET|BOTH)

endif ()
