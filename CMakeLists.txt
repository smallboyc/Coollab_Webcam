cmake_minimum_required(VERSION 3.10)

# Set the project name and version
project(WebcamInfo VERSION 1.0)

# Specify the C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# Add an executable for your project using .mm extension for Objective-C++
add_executable(WebcamInfo src/main.cpp src/webcam.mm)

# Link the AVFoundation and CoreMedia frameworks
find_library(COREMEDIA_FRAMEWORK CoreMedia)
find_library(COREVIDEO_FRAMEWORK CoreVideo)
find_library(AVFOUNDATION_FRAMEWORK AVFoundation)

target_link_libraries(WebcamInfo
    ${COREMEDIA_FRAMEWORK}
    ${COREVIDEO_FRAMEWORK}
    ${AVFOUNDATION_FRAMEWORK}
)

# Specify the include directories
target_include_directories(WebcamInfo PRIVATE ${CMAKE_SOURCE_DIR})

# Optionally, you can set compile options
target_compile_options(WebcamInfo PRIVATE -Wall -Wextra -pedantic)

# Link frameworks
# Link necessary frameworks directly
target_link_libraries(WebcamInfo
    "-framework AVFoundation"
    "-framework CoreMedia"
    "-framework Foundation"
)

# ---Add img library---
add_subdirectory(img)
target_link_libraries(WebcamInfo img::img)
