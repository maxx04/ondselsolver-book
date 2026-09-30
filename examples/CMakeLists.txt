cmake_minimum_required(VERSION 3.16)

project(OndselSolverBookExamples LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_subdirectory(01-distance-constraint)
add_subdirectory(02-iterative-solver)
add_subdirectory(03-solver-data-model)
add_subdirectory(04-freecad-pipeline)
add_subdirectory(06-asmt-structure)
