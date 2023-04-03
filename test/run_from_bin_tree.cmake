#!/usr/bin/env cmake

# CMake requirements.
cmake_minimum_required(VERSION 3.7...3.26.1)

# ============================================================================ #
#
#                 		Add test: Run from build tree
#
# ============================================================================ #

# does the application run
add_test(NAME Runs COMMAND node ${PROJECT_NAME})
