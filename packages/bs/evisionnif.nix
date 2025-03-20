{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  python3,
  zlib,
  pcre2,
  gflags,
  protobuf_21,
  beam,
  libjpeg,
  libpng,
  libtiff,
  libwebp,
  openjpeg,
  openexr,
  wget,
  which,
}: let
  opencv_ver = "4.11.0";

  opencv_src = fetchFromGitHub {
    owner = "opencv";
    repo = "opencv";
    rev = opencv_ver;
    sha256 = "sha256-YNd96qFJ8SHBgDEEsoNps888myGZdELbbuYCae9pW3M=";
  };
in
  stdenv.mkDerivation rec {
    pname = "evision";
    version = "0.1.31";

    src = fetchFromGitHub {
      owner = "cocoa-xu";
      repo = "evision";
      rev = "v${version}";
      hash = "sha256-+YRlzRam8yKLBLNAJc8b5d3d4JVIZhPt7KssHIhwU0M=";
    };

    nativeBuildInputs = [
      cmake
      pkg-config
      python3
      wget
      which
    ];

    buildInputs = [
      beam.interpreters.erlang_26
      zlib
      pcre2
      gflags
      protobuf_21
      libjpeg
      libpng
      libtiff
      libwebp
      openjpeg
      openexr
    ];

    # First configure and build OpenCV
    preConfigure = ''
      # Set up directories
      mkdir -p 3rd_party/opencv
      cp -r ${opencv_src}/* 3rd_party/opencv/opencv-${opencv_ver}/
      chmod -R u+w 3rd_party/opencv

      # Build OpenCV
      mkdir -p cmake_opencv_${opencv_ver}
      pushd cmake_opencv_${opencv_ver}
      cmake ../3rd_party/opencv/opencv-${opencv_ver} \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=$PWD/../priv \
        -DPYTHON3_EXECUTABLE=${python3}/bin/python3 \
        -DINSTALL_PYTHON_EXAMPLES=OFF \
        -DINSTALL_C_EXAMPLES=OFF \
        -DBUILD_EXAMPLES=OFF \
        -DBUILD_TESTS=OFF \
        -DBUILD_PERF_TESTS=OFF \
        -DOPENCV_ENABLE_NONFREE=OFF \
        -DOPENCV_GENERATE_PKGCONFIG=ON \
        -DOPENCV_PC_FILE_NAME=opencv4.pc \
        -DBUILD_ZLIB=OFF \
        -DBUILD_opencv_gapi=OFF \
        -DBUILD_opencv_apps=OFF \
        -DBUILD_opencv_java=OFF \
        -DBUILD_opencv_python2=OFF \
        -DBUILD_opencv_python3=OFF \
        -DWITH_JPEG=ON \
        -DWITH_PNG=ON \
        -DWITH_TIFF=ON \
        -DWITH_WEBP=ON \
        -DWITH_OPENJPEG=ON \
        -DWITH_JASPER=OFF \
        -DWITH_OPENEXR=ON \
        -DWITH_FFMPEG=OFF \
        -DWITH_GSTREAMER=OFF

      make -j$NIX_BUILD_CORES
      make install
      popd

      # Copy headers.txt
      cp cmake_opencv_${opencv_ver}/modules/python_bindings_generator/headers.txt c_src/headers.txt
    '';

    # Configure evision
    cmakeFlags = [
      "-DCMAKE_BUILD_TYPE=Release"
      "-DPRIV_DIR=${placeholder "out"}/priv"
      "-DERTS_INCLUDE_DIR=${beam.interpreters.erlang_26}/lib/erlang/usr/include"
      "-DC_SRC=${placeholder "out"}/c_src"
      "-DPY_SRC=${placeholder "out"}/py_src"
      "-DGENERATED_ELIXIR_SRC_DIR=${placeholder "out"}/lib/generated"
      "-DGENERATED_ERLANG_SRC_DIR=${placeholder "out"}/src/generated"
      "-DEVISION_GENERATE_LANG=elixir"
      "-DEVISION_ENABLE_CONTRIB=false"
      "-DEVISION_ENABLE_CUDA=false"
      "-DOpenCV_DIR=${placeholder "out"}/priv/lib/cmake/opencv4"
    ];

    # Make build parallel
    enableParallelBuilding = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/priv/native
      mkdir -p $out/priv/lib

      # Copy the built NIF files
      cp evision.so $out/priv/native/libevision-v${version}-nif-2.16-x86_64-unknown-linux-gnu.so
      cp evision.so $out/priv/lib/evision.so

      # Copy OpenCV libraries and includes
      cp -r priv/lib $out/priv/
      cp -r priv/include $out/priv/

      runHook postInstall
    '';

    meta = with lib; {
      description = "OpenCV-based Computer Vision library for Elixir";
      homepage = "https://github.com/cocoa-xu/evision";
      license = licenses.asl20;
      platforms = ["x86_64-linux"];
    };
  }
