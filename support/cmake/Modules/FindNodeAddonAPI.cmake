

# Add the library as an output target
add_library(NODE_ADDON_API SHARED)
add_library(NODE_ADDON_API::NODE_ADDON_API ALIAS ${NODE_ADDON_API})

# Collect Node Addon-API headers into NODE_ADDON_API_DIR
execute_process(
    COMMAND node -p "require('node-addon-api').include"
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
    OUTPUT_VARIABLE NODE_ADDON_API_DIR
)
string(REGEX REPLACE "[\r\n\"]" "" NODE_ADDON_API_DIR ${NODE_ADDON_API_DIR})
message(STATUS "NODE_ADDON_API_DIR = ${NODE_ADDON_API_DIR}")

# Glob all files with all extensions in 'include/${PROJECT_NAME}' and pass them to ${PROJECT_NAME_UPPER}_INC_FILES
file(GLOB NODE_ADDON_API_INC_FILES "${NODE_ADDON_API_DIR}/*.h")
target_sources(${PROJECT_NAME}
  PRIVATE
    FILE_SET NODE_ADDON_API_HEADERS
    TYPE HEADERS
    BASE_DIRS ${NODE_ADDON_API_DIR}
    FILES
        ${NODE_ADDON_API_INC_FILES}
)
source_group("Node Addon API" FILES ${NODE_ADDON_API_INC_FILES})
