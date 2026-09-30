cmake_minimum_required(VERSION 3.16)

project(ondselsolver_real_asmt LANGUAGES CXX)

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

set(ASMT_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
set(ASMT_FIXTURE_DIR "${CMAKE_CURRENT_BINARY_DIR}/fixtures")
file(MAKE_DIRECTORY "${ASMT_FIXTURE_DIR}")

foreach(FIXTURE IN ITEMS __cubes.asmt fourbar.asmt piston.asmt)
    configure_file("${ASMT_SOURCE_DIR}/${FIXTURE}" "${ASMT_FIXTURE_DIR}/${FIXTURE}" COPYONLY)
endforeach()

add_executable(solve_asmt main.cpp)
target_include_directories(solve_asmt PRIVATE "${ONDSELSOLVER_SOURCE_DIR}/OndselSolver")
target_link_libraries(solve_asmt PRIVATE OndselSolver)
target_compile_definitions(solve_asmt PRIVATE DEFAULT_ASMT_FILE="${ASMT_FIXTURE_DIR}/__cubes.asmt")