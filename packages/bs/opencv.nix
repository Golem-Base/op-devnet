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
  buildPackages,
  unzip,
}: let
  version = "4.11.0";

  src = fetchFromGitHub {
    owner = "opencv";
    repo = "opencv";
    rev = version;
    sha256 = "sha256-YNd96qFJ8SHBgDEEsoNps888myGZdELbbuYCae9pW3M=";
  };

  contribSrc = fetchFromGitHub {
    owner = "opencv";
    repo = "opencv_contrib";
    rev = version;
    sha256 = "sha256-YNd96qFJ8SHBgDEEsoNps888myGZdELbbuYCae9pW3M=";
  };

  # Required 3rd party downloads for contrib modules
  vgg = {
    src = fetchFromGitHub {
      owner = "opencv";
      repo = "opencv_3rdparty";
      rev = "fccf7cd6a4b12079f73bbfb21745f9babcd4eb1d";
      hash = "sha256-fjdGM+CxV1QX7zmF2AiR9NDknrP2PjyaxtjT21BVLmU=";
    };
    files = {
      "vgg_generated_48.i" = "e8d0dcd54d1bcfdc29203d011a797179";
      "vgg_generated_64.i" = "7126a5d9a8884ebca5aea5d63d677225";
      "vgg_generated_80.i" = "7cd47228edec52b6d82f46511af325c5";
      "vgg_generated_120.i" = "151805e03568c9f490a5e3a872777b75";
    };
    dst = ".cache/xfeatures2d/vgg";
  };

  boostdesc = {
    src = fetchFromGitHub {
      owner = "opencv";
      repo = "opencv_3rdparty";
      rev = "34e4206aef44d50e6bbcd0ab06354b52e7466d26";
      sha256 = "13yig1xhvgghvxspxmdidss5lqiikpjr0ddm83jsi0k85j92sn62";
    };
    files = {
      "boostdesc_bgm.i" = "0ea90e7a8f3f7876d450e4149c97c74f";
      "boostdesc_bgm_bi.i" = "232c966b13651bd0e46a1497b0852191";
      "boostdesc_bgm_hd.i" = "324426a24fa56ad9c5b8e3e0b3e5303e";
      "boostdesc_binboost_064.i" = "202e1b3e9fec871b04da31f7f016679f";
      "boostdesc_binboost_128.i" = "98ea99d399965c03d555cef3ea502a0b";
      "boostdesc_binboost_256.i" = "e6dcfa9f647779eb1ce446a8d759b6ea";
      "boostdesc_lbgm.i" = "0ae0675534aa318d9668f2a179c2a052";
    };
    dst = ".cache/xfeatures2d/boostdesc";
  };

  face = {
    src = fetchFromGitHub {
      owner = "opencv";
      repo = "opencv_3rdparty";
      rev = "8afa57abc8229d611c4937165d20e2a2d9fc5a12";
      hash = "sha256-m9yF4kfmpRJybohdRwUTmboeU+SbZQ6F6gm32PDWNBg=";
    };
    files = {
      "face_landmark_model.dat" = "7505c44ca4eb54b4ab1e4777cb96ac05";
    };
    dst = ".cache/data";
  };

  wechat_qrcode = {
    src = fetchFromGitHub {
      owner = "opencv";
      repo = "opencv_3rdparty";
      rev = "a8b69ccc738421293254aec5ddb38bd523503252";
      hash = "sha256-/n6zHwf0Rdc4v9o4rmETzow/HTv+81DnHP+nL56XiTY=";
    };
    files = {
      "detect.caffemodel" = "238e2b2d6f3c18d6c3a30de0c31e23cf";
      "detect.prototxt" = "6fb4976b32695f9f5c6305c19f12537d";
      "sr.caffemodel" = "cbfcd60361a73beb8c583eea7e8e6664";
      "sr.prototxt" = "69db99927a70df953b471daaba03fbef";
    };
    dst = ".cache/wechat_qrcode";
  };

  # Helper function to install extra files
  installExtraFiles = {
    dst,
    files,
    src,
    ...
  }:
    ''
      mkdir -p "${dst}"
    ''
    + lib.concatStrings (lib.mapAttrsToList (name: md5: ''
        ln -s "${src}/${name}" "${dst}/${md5}-${name}"
      '')
      files);
in
  stdenv.mkDerivation {
    pname = "opencv";
    inherit version src;

    outputs = ["out" "dev"];

    postUnpack = ''
      cp --no-preserve=mode -r "${contribSrc}/modules" "$NIX_BUILD_TOP/source/opencv_contrib"
    '';

    # This prevents cmake from using libraries in impure paths
    postPatch = ''
      sed -i '/Add these standard paths to the search paths for FIND_LIBRARY/,/^\s*$/{d}' CMakeLists.txt
    '';

    # Setup contrib module dependencies
    preConfigure = ''
      ${installExtraFiles vgg}
      ${installExtraFiles boostdesc}
      ${installExtraFiles face}
      ${installExtraFiles wechat_qrcode}
    '';

    postConfigure = ''
      [ -e modules/core/version_string.inc ]
      echo '"(build info elided)"' > modules/core/version_string.inc
    '';

    nativeBuildInputs = [
      cmake
      pkg-config
      python3
      unzip
    ];

    buildInputs = [
      zlib
      pcre2
      gflags
      protobuf_21
    ];

    cmakeFlags = [
      # Basic configuration
      "-DCMAKE_BUILD_TYPE=Release"
      "-DOPENCV_GENERATE_PKGCONFIG=ON"
      "-DBUILD_PROTOBUF=OFF"
      "-DPROTOBUF_UPDATE_FILES=ON"
      "-DPROTOBUF_PROTOC_EXECUTABLE=${buildPackages.protobuf_21}/bin/protoc"

      # Disable unnecessary features
      "-DBUILD_TESTS=OFF"
      "-DBUILD_PERF_TESTS=OFF"
      "-DBUILD_EXAMPLES=OFF"
      "-DBUILD_DOCS=OFF"
      "-DBUILD_opencv_apps=OFF"
      "-DBUILD_opencv_python2=OFF"
      "-DBUILD_opencv_python3=OFF"
      "-DBUILD_opencv_java=OFF"

      # Enable contrib modules
      "-DOPENCV_EXTRA_MODULES_PATH=$NIX_BUILD_TOP/source/opencv_contrib"
      "-DBUILD_opencv_gapi=OFF"

      # Make sure we build the modules needed by evision
      "-DBUILD_LIST=core,imgproc,imgcodecs,videoio,highgui,video,calib3d,features2d,objdetect,dnn,ml,flann,photo,stitching,wechat_qrcode,xfeatures2d"
    ];

    # Fix pkgconfig file
    postInstall = ''
      sed -i "s|{exec_prefix}/$out|{exec_prefix}|;s|{prefix}/$out|{prefix}|" \
        "$out/lib/pkgconfig/opencv4.pc"
    '';

    meta = {
      description = "Open Computer Vision Library with more than 500 algorithms";
      homepage = "https://opencv.org/";
      license = lib.licenses.bsd3;
      platforms = ["x86_64-linux"];
    };
  }
