cmake_minimum_required(VERSION 3.16)

project(freecad_pipeline LANGUAGES CXX)

add_executable(freecad_pipeline main.cpp)

target_compile_features(freecad_pipeline PRIVATE cxx_std_17)
