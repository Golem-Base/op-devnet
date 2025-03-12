{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}: let
  version = "1.14.0";

  platforms = {
    "x86_64-linux" = {
      name = "linux_amd64";
      sha256 = "sha256-RjqoCluPzXc214m3IKh09Aw0+scGqQpC2HCLteAtnMc=";
    };

    "aarch64-linux" = {
      name = "linux_arm64";
      sha256 = "0vdyc8d2my15l7qa7v272k23vr31rbg35p9pw015r7d7hqm7xjr8";
    };

    "x86_64-darwin" = {
      name = "darwin_amd64";
      sha256 = "1w82bp1hs59yw88s7r6r6mlsq3i7jdpl3v89lzh8nkmjcrgm3vbf";
    };

    "aarch64-darwin" = {
      name = "darwin_arm64";
      sha256 = "13bb4gw7y2zdyvpmv4fcpvb3b5nmxhk80amwaw2w06qm3ck6112b";
    };
  };

  src = let
    inherit (builtins.getAttr stdenv.hostPlatform.system platforms) name sha256;
  in
    fetchurl {
      url = "https://github.com/ethpandaops/dora/releases/download/v${version}/dora_${version}_${name}.tar.gz";
      inherit sha256;
    };
in
  stdenv.mkDerivation {
    inherit src version;
    pname = "dora";

    nativeBuildInputs = [autoPatchelfHook];

    unpackPhase = ''
      tar -xzf $src
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp dora-explorer $out/bin/
      chmod +x $out/bin/dora-explorer
    '';

    meta = with lib; {
      description = "Dora the Explorer is a lightweight slot explorer for the ethereum beaconchain ";
      homepage = "https://github.com/ethpandaops/dora";
      license = licenses.gpl3;
      mainProgram = "dora-explorer";
    };
  }
