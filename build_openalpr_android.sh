#!/bin/bash

#brew install curl
#make[1]: *** [misc_utilities/CMakeFiles/openalpr-utils-prepcharsfortraining.dir/all] Error 2

# You should tweak this section to adapt the paths to your need
export ANDROID_HOME=/Users/fracico/Library/Android/sdk
export NDK_ROOT=/Users/fracico/Library/Android/sdk/ndk/25.1.8937393
export CMAKE_ROOT=/Users/fracico/Library/Android/sdk/cmake/3.22.1/bin/cmake

export ANDROID_NDK_ROOT=$NDK_ROOT
#echo $HOME
#echo $ANDROID_HOME
#echo $NDK_ROOT
#echo $ANDROID_NDK_ROOT

export ANDROID_PLATFORM=28

# In my case, FindJNI.cmake does not find java, so i had to manually specify these
# You could try without it and remove the cmake variable specification at the bottom of this file
export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home
export JAVA_AWT_LIBRARY=$JAVA_HOME/jre/lib/amd64
export JAVA_JVM_LIBRARY=$JAVA_HOME/jre/lib/amd64
export JAVA_INCLUDE_PATH=$JAVA_HOME/include
export JAVA_INCLUDE_PATH2=$JAVA_HOME/include/darwin
#export JAVA_INCLUDE_PATH2=$JAVA_HOME/include/linux

export JAVA_AWT_INCLUDE_PATH=$JAVA_HOME/include

SCRIPTPATH=`pwd`
echo $SCRIPTPATH
####################################################################
# Prepare Tesseract and Leptonica, using rmtheis/tess-two repository
####################################################################

#git clone --recursive https://github.com/rmtheis/tess-two.git tess2
#git clone --recursive https://github.com/adaptech-cz/Tesseract4Android tess2

# cd tess2
# echo "ndk.dir=$NDK_ROOT
# sdk.dir=$ANDROID_HOME" > local.properties
# head local.properties
# ./gradlew assembleRelease
# cd ..

#/Users/fracico/Library/Android/sdk/cmake/3.22.1
####################################################################
# Download and extract OpenCV4Android
####################################################################

#curl https://sourceforge.net/projects/opencvlibrary/files/opencv-android/3.2.0/opencv-3.2.0-android-sdk.zip/download -o opencv-3.2.0-android-sdk.zip
                                        
#unzip opencv-3.2.0-android-sdk.zip
#rm opencv-3.2.0-android-sdk.zip

####################################################################
# Download and configure openalpr from jav974/openalpr forked repo
####################################################################

#git clone https://github.com/openalpr/openalpr openalpr
rm -rf openalpr/android-build
mkdir openalpr/android-build

rm -rf openalpr/src/openalpr/ocr/tesseract
mkdir openalpr/src/openalpr/ocr/tesseract

#"armeabi-v7a with NEON"
declare -a ANDROID_ABIS=("armeabi-v7a" "arm64-v8a" "x86" "x86_64")


for i in "${ANDROID_ABIS[@]}"
do
    if [ "$i" == "armeabi-v7a with NEON" ]; then abi="armeabi-v7a"; else abi="$i"; fi
    TESSERACT_LIB_DIR=$SCRIPTPATH/tess2/tess-two/libs/$abi
	TESSERACT_SRC_DIR_H=$SCRIPTPATH/tess2/tesseract4android/src/main/cpp/tesseract/src/include
	TESSERACT_SRC_DIR_2=$SCRIPTPATH/tess2/tesseract4android/.cxx/Release/6c6y675x/$abi/tesseract/CMakeFiles/tesseract.dir/src/src
	OPENCV_LIB_PATH=$SCRIPTPATH/OpenCV-android-sdk/sdk/native/libs/$abi
	OPENCV_INCLUDE_PATH=$SCRIPTPATH/OpenCV-android-sdk/sdk/native/jni/include
	OpenCV_DIR=$SCRIPTPATH/OpenCV-android-sdk/sdk/native/jni/abi-$abi
	TESSERACT_SO_FILES=$SCRIPTPATH/tess2/tesseract4android/build/intermediates/cxx/Release/6c6y675x/obj
	


	cd $TESSERACT_SRC_DIR_H
	find "$TESSERACT_SRC_DIR_H" -type f -name '*.h' -exec cp {} "$SCRIPTPATH/openalpr/src/openalpr/ocr/tesseract" \;
	cd $SCRIPTPATH
	cd openalpr/android-build





    if [[ "$i" == armeabi* ]];
    then
	ndk_arch="arm-linux-androideabi"
	lib="lib"
    elif [[ "$i" == arm64-v8a ]];
    then
	ndk_arch="aarch64-linux-android"
	lib="lib"
    elif [[ "$i" == mips ]] || [[ "$i" == x86 ]];
    then
	ndk_arch="i686-linux-android"
	lib="lib"
    elif [[ "$i" == mips64 ]] || [[ "$i" == x86_64 ]];
    then
	ndk_arch="x86_64-linux-android"
	lib="lib64"

    fi
    
    echo "
######################################
Generating project for arch $i
######################################
"
    rm -rf "$i" && mkdir "$i"
    cd "$i"
    #-DANDROID_STL=gnustl_static \
    $CMAKE_ROOT \
	-DCMAKE_TOOLCHAIN_FILE=$NDK_ROOT/build/cmake/android.toolchain.cmake \
        -DANDROID_TOOLCHAIN=clang \
	-DANDROID_NDK=$NDK_ROOT \
	-DCMAKE_BUILD_TYPE=Release \
	-DANDROID_PLATFORM=$ANDROID_PLATFORM \
	-DANDROID_ABI="$i" \
	-DANDROID_CPP_FEATURES="rtti exceptions" \
	-DANDROID_STL=c++_static \
	-DCMAKE_CXX_FLAGS="-std=c++11 -stdlib=libc++" \
	-DOpenCV_DIR=$OpenCV_DIR \
 	-DOpenCV_INCLUDE_DIRS=$OPENCV_INCLUDE_PATH \
	-DANDROID_COMPILER_FLAGS="-I$OPENCV_INCLUDE_PATH" \
	-DTesseract_INCLUDE_BASEAPI_DIR=$TESSERACT_SRC_DIR_2/api \
	-DTesseract_INCLUDE_CCSTRUCT_DIR=$TESSERACT_SRC_DIR_2/ccstruct \
	-DTesseract_INCLUDE_CCMAIN_DIR=$TESSERACT_SRC_DIR_2/ccmain \
	-DTesseract_INCLUDE_CCUTIL_DIR=$TESSERACT_SRC_DIR_2/ccutil \
	-DTesseract_INCLUDE_DIRS=$TESSERACT_SRC_DIR_H \
	-DTesseract_LIB=$TESSERACT_SO_FILES/$i/libtesseract.so \
	-DLeptonica_LIB=$TESSERACT_SO_FILES/$i/libleptonica.so \
	-DJAVA_AWT_LIBRARY=$JAVA_AWT_LIBRARY \
	-DJAVA_JVM_LIBRARY=$JAVA_JVM_LIBRARY \
	-DJAVA_INCLUDE_PATH=$JAVA_INCLUDE_PATH \
	-DJAVA_INCLUDE_PATH2=$JAVA_INCLUDE_PATH2 \
	-DJAVA_AWT_INCLUDE_PATH=$JAVA_AWT_INCLUDE_PATH \
	-DPngt_LIB=$TESSERACT_SO_FILES/$i/libpngx.so \
	-DJpgt_LIB=$TESSERACT_SO_FILES/$i/libjpeg.so \
	-DJnigraphics_LIB=$NDK_ROOT/toolchains/llvm/prebuilt/darwin-x86_64/sysroot/usr/lib/$ndk_arch/$ANDROID_PLATFORM/libjnigraphics.so \
	-DANDROID_LD="-latomic" \
	-DANDROID_ARM_MODE=arm \
	../../src/

    $CMAKE_ROOT --build . -- -j 17
    
    cd ..
done

echo "
All done !!!"
