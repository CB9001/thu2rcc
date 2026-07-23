cmake_minimum_required(VERSION 3.18)

if(NOT CMAKE_CUDA_ARCHITECTURES)
    set(CMAKE_CUDA_ARCHITECTURES native)
endif()

project(thu2rcc LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CUDA_STANDARD 17)

set(SOURCES src/cheat_cracker.cu)

if(WIN32)
    list(APPEND SOURCES res/resource.rc)
endif()

add_executable(thu2rcc ${SOURCES})

set_target_properties(thu2rcc PROPERTIES
    CUDA_SEPARABLE_COMPILATION ON
)
