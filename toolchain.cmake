set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)

set(BUILDROOT_OUTPUT /home/valentijn/dev/buildroot/output)

set(CMAKE_C_COMPILER ${BUILDROOT_OUTPUT}/host/bin/arm-buildroot-linux-uclibcgnueabihf-gcc)
set(CMAKE_CXX_COMPILER ${BUILDROOT_OUTPUT}/host/bin/arm-buildroot-linux-uclibcgnueabihf-g++)

set(CMAKE_SYSROOT ${BUILDROOT_OUTPUT}/host/arm-buildroot-linux-uclibcgnueabihf/sysroot)

set(CMAKE_FIND_ROOT_PATH ${CMAKE_SYSROOT})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
