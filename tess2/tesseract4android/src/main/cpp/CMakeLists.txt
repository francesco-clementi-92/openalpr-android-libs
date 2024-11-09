##
# Copyright (C) 2019 Adaptech s.r.o., Robert Pösel
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.
##

# For more information about using CMake with Android Studio, read the
# documentation: https://d.android.com/studio/projects/add-native-code.html

# Sets the minimum version of CMake required to build the native library.

cmake_minimum_required(VERSION 3.18.1)
project(Tesseract4Android)

# Tesseract requires newer C++ standard, so let's enable it for all libraries
cmake_minimum_required(VERSION 3.18.1)
project(Tesseract4Android)

# Set C++ standard and build options
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Enable shared libraries globally
set(BUILD_SHARED_LIBS ON)

# Add subdirectories for dependencies
add_subdirectory(libjpeg)
add_subdirectory(libpng)
add_subdirectory(leptonica)
add_subdirectory(tesseract)

# Set output directories for shared libraries
set_target_properties(tesseract PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
)

set_target_properties(leptonica PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
)

# Use actual target names for libjpeg and libpng
# Replace 'libjpeg' with the exact target name if it differs
target_link_libraries(tesseract 
    jpeg
    pngx
    leptonica
)

# Install rules
install(TARGETS tesseract leptonica jpeg pngx
    LIBRARY DESTINATION "${CMAKE_BINARY_DIR}/lib"
    RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/lib"
)


message(STATUS "Shared libraries for Tesseract and dependencies will be generated in ${CMAKE_BINARY_DIR}/lib")
