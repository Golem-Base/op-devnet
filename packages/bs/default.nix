{
  beam,
  lib,
  fetchFromGitHub,
  rustPlatform,
  ...
}: let
  pname = "bs";
  version = "7.0.2";

  buildMix = lib.makeOverridable beamPackages.buildMix;
  beamPackages = beam.packagesWith beam.interpreters.erlang_26;

  src = fetchFromGitHub {
    owner = "aldoborrero";
    repo = "blockscout";
    rev = "v${version}-nix";
    hash = "sha256-vNTQVIRDFwXH30MFI12g+Ge1oVxyd0Fk1gBMJRyaiNI=";
  };

  secp256k1Nif = rustPlatform.buildRustPackage {
    pname = "ex_secp256k1";
    version = "0.7.4";
    src = fetchFromGitHub {
      owner = "ayrat555";
      repo = "ex_secp256k1";
      rev = "v0.7.4";
      hash = "sha256-BvrAu0t5XLMS4h+uZRPbH/S6HrLB9WOnkEm1D/x1j3w=";
    };
    sourceRoot = "source/native/ex_secp256k1";
    cargoHash = "sha256-opH2UZU+OKzOBXW0bPBoKr0wq+vSwM4n6Wc2+0tshr0=";
    useFetchCargoVendor = true;
    doCheck = false;
  };

  keccakNif = rustPlatform.buildRustPackage {
    pname = "ex_keccak";
    version = "0.7.6";
    src = fetchFromGitHub {
      owner = "ExWeb3";
      repo = "ex_keccak";
      rev = "v0.7.6";
      hash = "sha256-IsMMxlOunuUt3Vfvd+1qF/HQ9UScbOLw6cIW+ZbHXsk=";
    };
    sourceRoot = "source/native/exkeccak";
    cargoHash = "sha256-vO9c7KbfblqvWqFoFAAfYk+AVISTfj+VEsYpF1iJlZA=";
    useFetchCargoVendor = true;
    doCheck = false;
  };

  brotliNif = rustPlatform.buildRustPackage {
    pname = "ex_brotli";
    version = "0.5.0";
    src = fetchFromGitHub {
      owner = "mfeckie";
      repo = "ex_brotli";
      rev = "0.5.0";
      hash = "sha256-KbVllG4EAGaSrxbkaIKm68htNTsBx9HHxD59e89NDK8=";
    };
    sourceRoot = "source/native/ex_brotli";
    cargoHash = "sha256-VjQFay3JcKxWyr1jpNUOVJekpZsbafINWD6kFY0Bi6Q=";
    useFetchCargoVendor = true;
    doCheck = false;
  };

  siweNif = rustPlatform.buildRustPackage {
    pname = "siwe";
    version = "0.1.0";
    src = fetchFromGitHub {
      owner = "royal-markets";
      repo = "siwe-ex";
      rev = "51c9c08240eb7eea3c35693011f8d260cd9bb3be";
      hash = "sha256-ltxJSmHAfz2oJBGYt/kPa6pOHu40TxsFZ0KtstD+5U0=";
    };
    sourceRoot = "source/native/siwe_native";
    cargoHash = "sha256-qe4DSNVlqJbB3+1X/2G9Ufyi2K8RqOyesvUxF6Nv418=";
    useFetchCargoVendor = true;
    doCheck = false;
  };

  # evisionNif = let
  #   opencv = callPackage ./opencv.nix {};
  #   python = pkgs.python3.withPackages (ps: with ps; [setuptools]);
  # in
  #   pkgs.stdenv.mkDerivation rec {
  #     pname = "evision";
  #     version = "0.1.31";

  #     src = fetchFromGitHub {
  #       owner = "cocoa-xu";
  #       repo = "evision";
  #       rev = "v${version}";
  #       hash = "sha256-+YRlzRam8yKLBLNAJc8b5d3d4JVIZhPt7KssHIhwU0M=";
  #     };

  #     nativeBuildInputs = [
  #       pkgs.cmake
  #       pkgs.pkg-config
  #       python
  #     ];

  #     buildInputs = [
  #       opencv
  #       beam.interpreters.erlang_26
  #     ];

  #     preConfigure = ''
  #       # Copy OpenCV headers to match the expected structure
  #       mkdir -p $NIX_BUILD_TOP/source/modules
  #       cp -r ${opencv}/include/opencv4/* $NIX_BUILD_TOP/source/modules/
  #       # Copy headers.txt to the expected location
  #       cp ${opencv}/share/opencv4/headers.txt $NIX_BUILD_TOP/source/c_src/headers.txt
  #     '';

  #     cmakeFlags = [
  #       "-DCMAKE_BUILD_TYPE=Release"
  #       "-DOpenCV_DIR=${opencv}/lib/cmake/opencv4"
  #       "-DPRIV_DIR=${placeholder "out"}/priv"
  #       "-DC_SRC=$NIX_BUILD_TOP/source/c_src"
  #       "-DPY_SRC=$NIX_BUILD_TOP/source/py_src"
  #       "-DERTS_INCLUDE_DIR=${beam.interpreters.erlang_26}/lib/erlang/usr/include"
  #       "-DEVISION_GENERATE_LANG=elixir"
  #       (lib.cmakeBool "EVISION_ENABLE_CONTRIB" true)
  #       (lib.cmakeBool "EVISION_PREFER_PRECOMPILED" false)
  #     ];

  #     enableParallelBuilding = true;

  #     installPhase = ''
  #       runHook preInstall
  #       mkdir -p $out/priv/native
  #       mkdir -p $out/priv/lib
  #       cp evision.so $out/priv/native/libevision-v${version}-nif-2.16-x86_64-unknown-linux-gnu.so
  #       cp evision.so $out/priv/lib/evision.so
  #       runHook postInstall
  #     '';
  #   };

  mixNixDeps = import ./mix_deps.nix {
    inherit lib beamPackages;
    overrides = final: _prev: {
      rustler_precompiled = beamPackages.buildMix rec {
        name = "rustler_precompiled";
        version = "0.8.2";
        src = beamPackages.fetchHex {
          pkg = "rustler_precompiled";
          version = "${version}";
          sha256 = "63d1bd5f8e23096d1ff851839923162096364bac8656a4a3c00d1fff8e83ee0a";
        };
        beamDeps = with final; [castore];
        patches = [./002_mix_rustler_skip_download.patch];
      };

      # ex_keccak = let
      #   drv = buildMix rec {
      #     name = "ex_keccak";
      #     version = "0.7.6";
      #     src = beamPackages.fetchHex {
      #       pkg = "ex_keccak";
      #       version = "0.7.6";
      #       sha256 = "9d1568424eb7b995e480d1b7f0c1e914226ee625496600abb922bba6f5cdc5e4";
      #     };
      #     beamDeps = with final; [rustler_precompiled];
      #     preBuild = ''
      #       mkdir -p config
      #       echo 'import Config' > config/prod.exs
      #       echo "config :ex_keccak, ExKeccak, skip_compilation?: true" >> config/prod.exs
      #     '';
      #   };
      # in
      #   drv.override (workarounds.rustlerPrecompiled {} drv);

      # ex_brotli = let
      #   drv = buildMix rec {
      #     name = "ex_brotli";
      #     version = "0.5.0";
      #     src = beamPackages.fetchHex {
      #       pkg = "ex_brotli";
      #       version = "${version}";
      #       sha256 = "8447d98d51f8f312629fd38619d4f564507dcf3a03d175c3f8f4ddf98e46dd92";
      #     };
      #     beamDeps = with final; [phoenix rustler_precompiled];
      #   };
      # in
      #   drv.override (workarounds.rustlerPrecompiled {} drv);

      # ex_secp256k1 = let
      #   drv = buildMix rec {
      #     name = "ex_secp256k1";
      #     version = "0.7.4";
      #     src = beamPackages.fetchHex {
      #       pkg = "ex_secp256k1";
      #       version = "${version}";
      #       sha256 = "465fd788c83c24d2df47f302e8fb1011054c81a905345e377c957b159a783bfc";
      #     };
      #     beamDeps = with final; [rustler_precompiled];
      #   };
      # in
      #   drv.override (workarounds.rustlerPrecompiled {} drv);

      ex_keccak = beamPackages.buildMix rec {
        name = "ex_keccak";
        version = "0.7.6";
        src = beamPackages.fetchHex {
          pkg = "ex_keccak";
          version = "${version}";
          sha256 = "9d1568424eb7b995e480d1b7f0c1e914226ee625496600abb922bba6f5cdc5e4";
        };
        beamDeps = with final; [rustler_precompiled];
        env = {
          RUSTLER_PRECOMPILED_FORCE_BUILD_ALL = "false";
          RUSTLER_PRECOMPILED_GLOBAL_CACHE_PATH = "unused-but-required";
        };
        preBuild = ''
          # Create directory structure that matches what the module is looking for
          mkdir -p _build/prod/lib/ex_keccak/priv/native

          # Copy the NIF file with the exact name expected
          for lib in ${keccakNif}/lib/*
          do
            file=''${lib##*/}
            cp "$lib" _build/prod/lib/ex_keccak/priv/native/libexkeccak-v${version}-nif-2.16-x86_64-unknown-linux-gnu.so

            # Also maintain the standard location
            mkdir -p priv/native/ex_keccak
            ln -s "$lib" priv/native/ex_keccak/libexkeccak.so
          done
        '';
      };

      ex_brotli = beamPackages.buildMix rec {
        name = "ex_brotli";
        version = "0.5.0";
        src = beamPackages.fetchHex {
          pkg = "ex_brotli";
          version = "${version}";
          sha256 = "8447d98d51f8f312629fd38619d4f564507dcf3a03d175c3f8f4ddf98e46dd92";
        };
        beamDeps = with final; [phoenix rustler_precompiled];
        env = {
          RUSTLER_PRECOMPILED_FORCE_BUILD_ALL = "false";
          RUSTLER_PRECOMPILED_GLOBAL_CACHE_PATH = "unused-but-required";
        };
        preBuild = ''
          # Create the standard location
          mkdir -p priv/native/ex_brotli

          # Create the expected path for runtime
          mkdir -p _build/prod/lib/ex_brotli/priv/native

          for lib in ${brotliNif}/lib/*
          do
            file=''${lib##*/}
            base=''${file%.*}

            # Copy to the expected path with the exact filename
            cp "$lib" _build/prod/lib/ex_brotli/priv/native/libex_brotli-v${version}-nif-2.15-x86_64-unknown-linux-gnu.so

            # Also link to standard location
            ln -s "$lib" priv/native/ex_brotli/$base.so
          done
        '';
      };

      ex_secp256k1 = beamPackages.buildMix rec {
        name = "ex_secp256k1";
        version = "0.7.4";
        src = beamPackages.fetchHex {
          pkg = "ex_secp256k1";
          version = "${version}";
          sha256 = "465fd788c83c24d2df47f302e8fb1011054c81a905345e377c957b159a783bfc";
        };
        beamDeps = with final; [rustler_precompiled];
        env = {
          RUSTLER_PRECOMPILED_FORCE_BUILD_ALL = "false";
          RUSTLER_PRECOMPILED_GLOBAL_CACHE_PATH = "unused-but-required";
        };
        preBuild = ''
          # Create the standard location
          mkdir -p priv/native/ex_secp256k1

          # Create the expected path for runtime
          mkdir -p _build/prod/lib/ex_secp256k1/priv/native

          for lib in ${secp256k1Nif}/lib/*
          do
            file=''${lib##*/}
            base=''${file%.*}

            # Copy to the expected path with the exact filename
            cp "$lib" _build/prod/lib/ex_secp256k1/priv/native/libex_secp256k1-v${version}-nif-2.15-x86_64-unknown-linux-gnu.so

            # Also link to standard location
            ln -s "$lib" priv/native/ex_secp256k1/$base.so
          done
        '';
      };

      # https://github.com/blockscout/absinthe_plug.git?90a8188e94e2650f13259fb16462075a87f98e18
      # ^ This is their forked version
      absinthe_plug = beamPackages.buildMix rec {
        name = "absinthe_plug";
        version = "1.5.8";
        src = beamPackages.fetchHex {
          pkg = "absinthe_plug";
          version = "${version}";
          sha256 = "sha256-u7BBdmR7c1gohh57JwVGXlPiz1TM9ac93R69hV+Zblo=";
        };
        beamDeps = with final; [absinthe plug];
      };

      coerce = beamPackages.buildMix rec {
        name = "coerce";
        version = "1.0.1";
        src = beamPackages.fetchHex {
          pkg = "coerce";
          version = "${version}";
          sha256 = "sha256-tEppFwD3oaFbS34v8fowvr1mmSmsiqQ8/+ni+L8FHPE=";
        };
      };

      prometheus_phoenix = beamPackages.buildMix rec {
        name = "prometheus_phoenix";
        version = "1.3.0";
        src = beamPackages.fetchHex {
          pkg = "prometheus_phoenix";
          version = "${version}";
          sha256 = "c4d1404ac4e9d3d963da601db2a7d8ea31194f0017057fabf0cfb9bf5a6c8c75";
        };
        patches = [./001_mix_prometheus_phoenix_controller.patch];
        beamDeps = with final; [phoenix prometheus_ex];
      };

      prometheus_ex = beamPackages.buildMix rec {
        name = "prometheus_ex";
        version = "3.1.0";
        src = fetchFromGitHub {
          owner = "lanodan";
          repo = "prometheus.ex";
          rev = "fix/elixir-1.14";
          sha256 = "sha256-2PZP+YnwnHt69HtIAQvjMBqBbfdbkRSoMzb1AL2Zsyc=";
        };
        beamDeps = with final; [prometheus];
      };

      prometheus_process_collector = beamPackages.buildRebar3 rec {
        name = "prometheus_process_collector";
        version = "1.6.1";
        src = fetchFromGitHub {
          owner = "Phybbit";
          repo = "prometheus_process_collector";
          rev = "3dc94dcff422d7b9cbd7ddf6bf2a896446705f3f";
          sha256 = "sha256-cmZiq0kROUiDQsd3EBIN7tcfB73E61/h/aNILh/NjXs=";
        };
        beamDeps = with final; [prometheus];
      };

      ex_cldr_lists = beamPackages.buildMix rec {
        name = "ex_cldr_lists";
        version = "2.11.1";
        src = beamPackages.fetchHex {
          pkg = "ex_cldr_lists";
          version = "${version}";
          sha256 = "00161c04510ccb3f18b19a6b8562e50c21f1e9c15b8ff4c934bea5aad0b4ade2";
        };
        beamDeps = with final; [ex_cldr_numbers ex_doc jason];
        # Create the missing prod.exs file with the same content as dev.exs
        preBuild = ''
          mkdir -p config
          echo 'import Config' > config/prod.exs
        '';
      };

      ex_cldr_units = beamPackages.buildMix rec {
        name = "ex_cldr_units";
        version = "3.17.2";
        src = beamPackages.fetchHex {
          pkg = "ex_cldr_units";
          version = "${version}";
          sha256 = "457d76c6e3b548bd7aba3c7b5d157213be2842d1162c2283abf81d9e2f1e1fc7";
        };
        beamDeps = with final; [cldr_utils decimal ex_cldr_lists ex_cldr_numbers ex_doc jason];
        preBuild = ''
          mkdir -p config
          echo 'import Config' > config/prod.exs
        '';
      };

      # siwe = let
      #   drv = buildMix rec {
      #     name = "siwe";
      #     version = "0.1.0";
      #     src = fetchFromGitHub {
      #       owner = "royal-markets";
      #       repo = "siwe-ex";
      #       rev = "51c9c08240eb7eea3c35693011f8d260cd9bb3be";
      #       hash = "sha256-ltxJSmHAfz2oJBGYt/kPa6pOHu40TxsFZ0KtstD+5U0=";
      #     };
      #     beamDeps = with final; [
      #       ex_abi
      #       ex_rlp
      #       ex_secp256k1
      #       jason
      #       rustler_precompiled
      #     ];
      #   };
      # in
      #   drv.override (workarounds.rustlerPrecompiled {} drv);

      siwe = beamPackages.buildMix rec {
        name = "siwe";
        version = "0.1.0";
        src = fetchFromGitHub {
          owner = "royal-markets";
          repo = "siwe-ex";
          rev = "51c9c08240eb7eea3c35693011f8d260cd9bb3be";
          hash = "sha256-ltxJSmHAfz2oJBGYt/kPa6pOHu40TxsFZ0KtstD+5U0=";
        };
        beamDeps = with final; [
          ex_abi
          ex_rlp
          ex_secp256k1
          jason
          rustler_precompiled
        ];
        env = {
          RUSTLER_PRECOMPILED_FORCE_BUILD_ALL = "false";
          RUSTLER_PRECOMPILED_GLOBAL_CACHE_PATH = "unused-but-required";
        };
        preBuild = ''
          mkdir -p _build/prod/lib/siwe/priv/native
          # Copy with the specific filename the module is looking for
          for lib in ${siweNif}/lib/*
          do
            cp "$lib" _build/prod/lib/siwe/priv/native/libsiwe_native-v0.6.0-nif-2.15-x86_64-unknown-linux-gnu.so
            mkdir -p priv/native
            cp "$lib" priv/native/libsiwe_native.so
          done
        '';
      };

      briefly = beamPackages.buildMix rec {
        name = "briefly";
        version = "0.4.1";
        src = fetchFromGitHub {
          owner = "CargoSense";
          repo = "briefly";
          rev = "a533393826195e640f24089fca751826858ebe53";
          hash = "sha256-Hm8zPvWeUqXaV/axEmffA9UJTxCskvF3JqUZG1PJze4=";
        };
        beamDeps = [];
      };
    };
  };
in
  beamPackages.mixRelease {
    inherit src pname version;
    inherit mixNixDeps;
  }
