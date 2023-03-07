cmake_minimum_required(VERSION 3.20)
project(pavolume)

set(CMAKE_C_STANDARD 99)

#find_package(M REQUIRED)
#if (NOT M_FOUND)
#    message(FATAL_ERROR "Not found development files of 'libx11' required for build. (Install libx11-dev or libx11-devel package.) CMake will exit.")
#elseif (NOT X11_Xkbfile_FOUND)
#    message(FATAL_ERROR "Not found development files of 'libxkbfile' required for build. (Install libxkbfile-dev or libxkbfile-devel package.) CMake will exit.")
#endif ()

#SET(MAJOR_VERSION 1)
#SET(MINOR_VERSION 8)
#SET(RELEASE_VERSION 5)
#SET(XKBSWITCH_VERSION ${MAJOR_VERSION}.${MINOR_VERSION}.${RELEASE_VERSION})
#ADD_DEFINITIONS(-DXKBSWITCH_VERSION="${XKBSWITCH_VERSION}")

set(pavolume_src
    src/pavolume.c
    src/pavolume.h
    src/options.h
    src/config.h
    src/usage.h
    )

set(lua_pavolume_src
    lua-pavolume.c
    luainc.c
    luainc.h
    )

add_library(libpavolume
            ${pavolume_src}
            )
target_link_libraries(libpavolume -lm -lpulse)

add_executable(pavolume
               src/main.c
               ${pavolume_src}
               )
target_link_libraries(pavolume PRIVATE
                      libpavolume)
