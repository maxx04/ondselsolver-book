cmake_minimum_required(VERSION 3.16)

project(asmt_structure LANGUAGES CXX)

add_executable(asmt_structure main.cpp)

target_compile_features(asmt_structure PRIVATE cxx_std_17)
