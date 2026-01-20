$DepsPath = (Resolve-Path -Path .)
$BuildPath = "$DepsPath\build"
$InstallPath = "$DepsPath\install"

function GoToBuildDir($dep) {
    $DepBuildPath = "$BuildPath\$dep"
    if (Test-Path -LiteralPath "$DepBuildPath") {
        Remove-Item -LiteralPath "$DepBuildPath" -Force -Recurse
    }
    mkdir "$DepBuildPath" | Out-Null
    cd "$DepBuildPath"
}

if (-Not (Test-Path -LiteralPath "$InstallPath")) {
    mkdir "$InstallPath" | Out-Null
}

# zlib
if (-Not (Test-Path -LiteralPath "$InstallPath\zlib")) {
    echo "=== building zlib ==="
    pushd
    GoToBuildDir zlib
    cmake `
        -G "Visual Studio 17 2022" `
        -A x64 `
        -D CMAKE_POLICY_DEFAULT_CMP0091=NEW `
        -D CMAKE_POLICY_DEFAULT_CMP0074=NEW `
        -D CMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded `
        -D CMAKE_BUILD_TYPE=Release `
        -D CMAKE_DISABLE_FIND_PACKAGE_PkgConfig=ON `
        -D CMAKE_INSTALL_PREFIX="$InstallPath\zlib" `
        "$DepsPath\zlib"
    cmake --build . --config Release --target install
    popd
} else {
    echo "skipping zlib..."
}

# leptonica
if (-Not (Test-Path -LiteralPath "$InstallPath\leptonica")) {
    echo "=== building leptonica ==="
    pushd
    GoToBuildDir leptonica
    cmake `
        -G "Visual Studio 17 2022" `
        -A x64 `
        -D CMAKE_POLICY_DEFAULT_CMP0091=NEW `
        -D CMAKE_POLICY_DEFAULT_CMP0074=NEW `
        -D CMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded `
        -D CMAKE_BUILD_TYPE=Release `
        -D CMAKE_DISABLE_FIND_PACKAGE_PkgConfig=ON `
        -D SW_BUILD=OFF `
        -D BUILD_SHARED_LIBS=OFF `
        -D ZLIB_ROOT="$InstallPath\zlib" `
        -D CMAKE_INSTALL_PREFIX="$InstallPath\leptonica" `
        "$DepsPath\leptonica"
    cmake --build . --config Release --target install
    popd
} else {
    echo "skipping leptonica..."
}

# tesseract
if (-Not (Test-Path -LiteralPath "$InstallPath\tesseract")) {
    echo "=== building tesseract ==="
    pushd
    GoToBuildDir tesseract
    cmake `
        -G "Visual Studio 17 2022" `
        -A x64 `
        -D CMAKE_POLICY_DEFAULT_CMP0091=NEW `
        -D CMAKE_POLICY_DEFAULT_CMP0074=NEW `
        -D CMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded `
        -D CMAKE_BUILD_TYPE=Release `
        -D CMAKE_DISABLE_FIND_PACKAGE_PkgConfig=ON `
        -D BUILD_TESTS=OFF `
        -D BUILD_TRAINING_TOOLS=OFF `
        -D DISABLED_LEGACY_ENGINE=ON `
        -D SW_BUILD=OFF `
        -D WIN32_MT_BUILD=ON `
        -D Leptonica_ROOT="$InstallPath\leptonica" `
        -D CMAKE_INSTALL_PREFIX="$InstallPath\tesseract" `
        "$DepsPath\tesseract"
    cmake --build . --config Release --target install
    popd
} else {
    echo "skipping tesseract..."
}

# freetype
if (-Not (Test-Path -LiteralPath "$InstallPath\freetype")) {
    echo "=== building freetype ==="
    pushd
    GoToBuildDir freetype
    cmake `
        -G "Visual Studio 17 2022" `
        -A x64 `
        -D CMAKE_POLICY_DEFAULT_CMP0091=NEW `
        -D CMAKE_POLICY_DEFAULT_CMP0074=NEW `
        -D CMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded `
        -D CMAKE_BUILD_TYPE=Release `
        -D CMAKE_DISABLE_FIND_PACKAGE_PkgConfig=ON `
        -D ZLIB_ROOT="$InstallPath\zlib" `
        -D CMAKE_INSTALL_PREFIX="$InstallPath\freetype" `
        "$DepsPath\freetype"
    cmake --build . --config Release --target install
    popd
} else {
     echo "skipping freetype..."
}

# harfbuzz
if (-Not (Test-Path -LiteralPath "$InstallPath\harfbuzz")) {
    echo "=== building harfbuzz ==="
    pushd
    GoToBuildDir harfbuzz
    cmake `
        -G "Visual Studio 17 2022" `
        -A x64 `
        -D CMAKE_POLICY_DEFAULT_CMP0091=NEW `
        -D CMAKE_BUILD_TYPE=Release `
        -D CMAKE_DISABLE_FIND_PACKAGE_PkgConfig=ON `
        -D HB_HAVE_FREETYPE=ON `
        -D CMAKE_PREFIX_PATH="$InstallPath\freetype" `
        -D CMAKE_INSTALL_PREFIX="$InstallPath\harfbuzz" `
        "$DepsPath\harfbuzz"
    cmake --build . --config Release --target install
    popd
} else {
     echo "skipping harfbuzz..."
}

if (-Not (Test-Path -LiteralPath "$InstallPath\opencv")) {
    echo "patching opencv_contrib/modules/freetype/CMakeLists.txt..."
    cp "$DepsPath\opencv_contrib_freetype_patch\CMakeLists.txt" "$DepsPath\opencv_contrib\modules\freetype\CMakeLists.txt"

    $LinkerFlags = """/LIBPATH:$InstallPath\tesseract\lib\ $InstallPath\leptonica\lib\leptonica-1.82.0.lib"""

    echo "=== building opencv ==="
    pushd
    GoToBuildDir opencv
    cmake `
        -G "Visual Studio 17 2022" `
        -A x64 `
        -D CMAKE_POLICY_DEFAULT_CMP0091=NEW `
        -D CMAKE_POLICY_DEFAULT_CMP0074=NEW `
        -D BUILD_SHARED_LIBS=ON `
        -D CUDA_USE_STATIC_CUDA_RUNTIME=ON `
        -D ENABLE_CXX11=ON `
        -D BUILD_CUDA_STUBS=OFF `
        -D BUILD_TESTS=OFF `
        -D BUILD_PERF_TESTS=OFF `
        -D BUILD_JAVA=OFF `
        -D BUILD_EXAMPLES=OFF `
        -D INSTALL_C_EXAMPLES=OFF `
        -D WITH_CUBLAS=OFF `
        -D WITH_CUDA=ON `
        -D WITH_DIRECTX=ON `
        -D WITH_FFMPEG=OFF `
        -D WITH_IPP=OFF `
        -D WITH_JASPER=OFF `
        -D WITH_OPENCL_D3D11_NV=ON `
        -D WITH_OPENCL=ON `
        -D WITH_OPENEXR=OFF `
        -D WITH_OPENGL=ON `
        -D WITH_PROTOBUF=ON `
        -D WITH_QUIRC=OFF `
        -D WITH_TIFF=OFF `
        -D WITH_V4L=OFF `
        -D WITH_WEBP=OFF `
        -D WITH_WIN32UI=ON `
        -D BUILD_opencv_alphamat=OFF `
        -D BUILD_opencv_apps=OFF `
        -D BUILD_opencv_aruco=OFF `
        -D BUILD_opencv_barcode=OFF `
        -D BUILD_opencv_bgsegm=OFF `
        -D BUILD_opencv_bioinspired=OFF `
        -D BUILD_opencv_calib3d=OFF `
        -D BUILD_opencv_ccalib=OFF `
        -D BUILD_opencv_cnn_3dobj=OFF `
        -D BUILD_opencv_core=ON `
        -D BUILD_opencv_cudaarithm=OFF `
        -D BUILD_opencv_cudabgsegm=OFF `
        -D BUILD_opencv_cudacodec=OFF `
        -D BUILD_opencv_cudafeatures2d=OFF `
        -D BUILD_opencv_cudafilters=OFF `
        -D BUILD_opencv_cudaimgproc=OFF `
        -D BUILD_opencv_cudalegacy=OFF `
        -D BUILD_opencv_cudaobjdetect=OFF `
        -D BUILD_opencv_cudaoptflow=OFF `
        -D BUILD_opencv_cudastereo=OFF `
        -D BUILD_opencv_cudawarping=OFF `
        -D BUILD_opencv_cudev=ON `
        -D BUILD_opencv_cvv=OFF `
        -D BUILD_opencv_datasets=OFF `
        -D BUILD_opencv_dnn_objdetect=OFF `
        -D BUILD_opencv_dnn_superres=OFF `
        -D BUILD_opencv_dnn=OFF `
        -D BUILD_opencv_dnns_easily_fooled=OFF `
        -D BUILD_opencv_dpm=OFF `
        -D BUILD_opencv_face=OFF `
        -D BUILD_opencv_features2d=OFF `
        -D BUILD_opencv_flann=OFF `
        -D BUILD_opencv_freetype=ON `
        -D BUILD_opencv_fuzzy=OFF `
        -D BUILD_opencv_gapi=OFF `
        -D BUILD_opencv_hdf=OFF `
        -D BUILD_opencv_hfs=OFF `
        -D BUILD_opencv_highgui=ON `
        -D BUILD_opencv_img_hash=OFF `
        -D BUILD_opencv_imgcodecs=ON `
        -D BUILD_opencv_imgproc=ON `
        -D BUILD_opencv_intensity_transform=OFF `
        -D BUILD_opencv_java_bindings_generator=OFF `
        -D BUILD_opencv_java=OFF `
        -D BUILD_opencv_js_bindings_generator=OFF `
        -D BUILD_opencv_js=OFF `
        -D BUILD_opencv_julia=OFF `
        -D BUILD_opencv_line_descriptor=OFF `
        -D BUILD_opencv_matlab=OFF `
        -D BUILD_opencv_mcc=OFF `
        -D BUILD_opencv_ml=ON `
        -D BUILD_opencv_objc_bindings_generator=OFF `
        -D BUILD_opencv_objc=OFF `
        -D BUILD_opencv_objdetect=OFF `
        -D BUILD_opencv_optflow=OFF `
        -D BUILD_opencv_ovis=OFF `
        -D BUILD_opencv_phase_unwrapping=OFF `
        -D BUILD_opencv_photo=OFF `
        -D BUILD_opencv_plot=OFF `
        -D BUILD_opencv_python_bindings_generator=OFF `
        -D BUILD_opencv_python_tests=OFF `
        -D BUILD_opencv_python=OFF `
        -D BUILD_opencv_python2=OFF `
        -D BUILD_opencv_python3=ON `
        -D BUILD_opencv_quality=OFF `
        -D BUILD_opencv_rapid=OFF `
        -D BUILD_opencv_reg=OFF `
        -D BUILD_opencv_rgbd=OFF `
        -D BUILD_opencv_saliency=OFF `
        -D BUILD_opencv_sfm=OFF `
        -D BUILD_opencv_shape=OFF `
        -D BUILD_opencv_stereo=OFF `
        -D BUILD_opencv_stitching=OFF `
        -D BUILD_opencv_structured_light=OFF `
        -D BUILD_opencv_superres=OFF `
        -D BUILD_opencv_surface_matching=OFF `
        -D BUILD_opencv_text=ON `
        -D BUILD_opencv_tracking=OFF `
        -D BUILD_opencv_ts=OFF `
        -D BUILD_opencv_video=OFF `
        -D BUILD_opencv_videoio=OFF `
        -D BUILD_opencv_videostab=OFF `
        -D BUILD_opencv_viz=OFF `
        -D BUILD_opencv_wechat_qrcode=OFF `
        -D BUILD_opencv_world=ON `
        -D BUILD_opencv_xfeatures2d=OFF `
        -D BUILD_opencv_ximgproc=OFF `
        -D BUILD_opencv_xobjdetect=OFF `
        -D BUILD_opencv_xphoto=OFF `
        -D CMAKE_DISABLE_FIND_PACKAGE_PkgConfig=ON `
        -D LEPTONICA_DIR="$InstallPath\leptonica" `
        -D Leptonica_ROOT="$InstallPath\leptonica" `
        -D TESSERACT_DIR="$InstallPath\tesseract" `
        -D Tesseract_ROOT="$InstallPath\tesseract" `
        -D FREETYPE_DIR="$InstallPath\freetype" `
        -D FreeType_ROOT="$InstallPath\freetype" `
        -D HARFBUZZ_DIR="$InstallPath\harfbuzz" `
        -D HarfBuzz_ROOT="$InstallPath\harfbuzz" `
        -D HARFBUZZ_INCLUDE_DIRS="$InstallPath\harfbuzz\include\harfbuzz" `
        -D HARFBUZZ_LIBRARIES="$InstallPath\harfbuzz\lib\harfbuzz.lib" `
        -D CMAKE_STATIC_LINKER_FLAGS="$LinkerFlags" `
        -D CMAKE_SHARED_LINKER_FLAGS="$LinkerFlags" `
        -D CMAKE_EXE_LINKER_FLAGS="$LinkerFlags" `
        -D CMAKE_MODULE_LINKER_FLAGS="$LinkerFlags" `
        -D OPENCV_EXTRA_MODULES_PATH="$DepsPath\opencv_contrib\modules" `
        -D CMAKE_INSTALL_PREFIX="$InstallPath\opencv" `
        -D CMAKE_BUILD_TYPE=Release `
        "$DepsPath\opencv"
    cmake --build . --config Release --target install
    popd
} else {
    echo "skipping opencv..."
}
