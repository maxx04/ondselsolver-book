cmake_minimum_required(VERSION 3.16)

project(solver_data_model LANGUAGES CXX)

add_executable(solver_data_model main.cpp)

target_compile_features(solver_data_model PRIVATE cxx_std_17)
