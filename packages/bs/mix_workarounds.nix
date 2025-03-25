_: {
  # Taken from deps_nix project: https://github.com/code-supply/deps_nix
  rustlerPrecompiled = {toolchain ? null, ...}: old: let
    extendedPkgs = pkgs.extend fenixOverlay;
    fenixOverlay = import "${
      fetchTarball {
        url = "https://github.com/nix-community/fenix/archive/056c9393c821a4df356df6ce7f14c722dc8717ec.tar.gz";
        sha256 = "sha256:1cdfh6nj81gjmn689snigidyq7w98gd8hkl5rvhly6xj7vyppmnd";
      }
    }/overlay.nix";
    nativeDir = "${old.src}/native/${with builtins; head (attrNames (readDir "${old.src}/native"))}";
    fenix =
      if toolchain == null
      then extendedPkgs.fenix.stable
      else extendedPkgs.fenix.fromToolchainName toolchain;
    native =
      (extendedPkgs.makeRustPlatform {
        inherit (fenix) cargo rustc;
      })
      .buildRustPackage
      {
        pname = "${old.packageName}-native";
        inherit (old) version;
        src = nativeDir;
        cargoLock = {
          lockFile = "${nativeDir}/Cargo.lock";
        };
        nativeBuildInputs =
          [
            extendedPkgs.cmake
          ]
          ++ extendedPkgs.lib.lists.optional extendedPkgs.stdenv.isDarwin extendedPkgs.darwin.IOKit;
        doCheck = false;
      };
  in {
    nativeBuildInputs = [extendedPkgs.cargo];

    env.RUSTLER_PRECOMPILED_FORCE_BUILD_ALL = "true";
    env.RUSTLER_PRECOMPILED_GLOBAL_CACHE_PATH = "unused-but-required";

    preConfigure = ''
      mkdir -p priv/native
      for lib in ${native}/lib/*
      do
        ln -s "$lib" "priv/native/$(basename "$lib")"
      done
    '';

    buildPhase = ''
      suggestion() {
        echo "***********************************************"
        echo "                 deps_nix                      "
        echo
        echo " Rust dependency build failed.                 "
        echo
        echo " If you saw network errors, you might need     "
        echo " to disable compilation on the appropriate     "
        echo " RustlerPrecompiled module in your             "
        echo " application config.                           "
        echo
        echo " We think you need this:                       "
        echo
        echo -n " "
        grep -Rl 'use RustlerPrecompiled' lib \
          | xargs grep 'defmodule' \
          | sed 's/defmodule \(.*\) do/config :${old.packageName}, \1, skip_compilation?: true/'
        echo "***********************************************"
        exit 1
      }
      trap suggestion ERR
      ${old.buildPhase}
    '';
  };
}
