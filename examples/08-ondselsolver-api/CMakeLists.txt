cmake_minimum_required(VERSION 3.16)

project(ondselsolver_api_example LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(REPOSITORY_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../..")
get_filename_component(REPOSITORY_ROOT "${REPOSITORY_ROOT}" ABSOLUTE)
set(ONDSELSOLVER_SOURCE_DIR "${REPOSITORY_ROOT}/vendor/OndselSolver")
if(NOT EXISTS "${ONDSELSOLVER_SOURCE_DIR}/CMakeLists.txt")
    message(FATAL_ERROR "OndselSolver submodule missing. Run: git submodule update --init --recursive")
endif()
set(ONDSELSOLVER_BUILD_SHARED ON CACHE BOOL "Build OndselSolver as a shared library" FORCE)
set(ONDSELSOLVER_BUILD_EXE OFF CACHE BOOL "Do not build the upstream test executable" FORCE)
set(ONDSELSOLVER_BUILD_TESTS OFF CACHE BOOL "Do not build the upstream test suite" FORCE)
add_subdirectory("${ONDSELSOLVER_SOURCE_DIR}" "${CMAKE_CURRENT_BINARY_DIR}/OndselSolver")

set(FIXTURE_DIR "${CMAKE_CURRENT_BINARY_DIR}/fixtures")
file(MAKE_DIRECTORY "${FIXTURE_DIR}")
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/../07-ondselsolver-real-asmt/__cubes.asmt"
    "${FIXTURE_DIR}/__cubes.asmt"
    COPYONLY)

add_executable(ondselsolver_api main.cpp)
target_include_directories(ondselsolver_api PRIVATE "${ONDSELSOLVER_SOURCE_DIR}/OndselSolver")
target_link_libraries(ondselsolver_api PRIVATE OndselSolver)
target_compile_definitions(ondselsolver_api PRIVATE DEFAULT_ASMT_FILE="${FIXTURE_DIR}/__cubes.asmt")
