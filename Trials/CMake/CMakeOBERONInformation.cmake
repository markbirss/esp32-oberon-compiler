# This file sets the basic flags for the OberonESP32 compiler
if(NOT CMAKE_OBERON_COMPILE_OBJECT)
    set(CMAKE_OBERON_COMPILE_OBJECT 
           "<CMAKE_OBERON_COMPILER> -s <SOURCE> -o <CMAKE_CURRENT_BINARY_DIR>")
endif()
set(CMAKE_OBERON_INFORMATION_LOADED 1)