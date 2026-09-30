cmake_minimum_required(VERSION 3.16)

project(iterative_solver LANGUAGES CXX)

add_executable(iterative_solver main.cpp)

target_compile_features(iterative_solver PRIVATE cxx_std_17)
