cmake_minimum_required(VERSION 3.16)

project(distance_constraint LANGUAGES CXX)

add_executable(distance_constraint main.cpp)

target_compile_features(distance_constraint PRIVATE cxx_std_17)
