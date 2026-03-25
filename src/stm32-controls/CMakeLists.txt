cmake_minimum_required(VERSION 3.10)
project(stm32-controls)

find_package(PkgConfig REQUIRED)
pkg_search_module(ALSA REQUIRED alsa)

add_executable(stm32-controls main.c)
target_include_directories(stm32-controls PRIVATE ${ALSA_INCLUDE_DIRS})
target_link_libraries(stm32-controls ${ALSA_LIBRARIES})
