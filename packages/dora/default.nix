{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:
stdenv.mkDerivation rec {
  pname = "dora";
  version = "1.14.0";

  nativeBuildInputs = [autoPatchelfHook];

  src = fetchurl {
    url = "https://github.com/ethpandaops/dora/releases/download/v${version}/dora_${version}_linux_amd64.tar.gz";
    sha256 = "sha256-RjqoCluPzXc214m3IKh09Aw0+scGqQpC2HCLteAtnMc=";
  };

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
    platforms = platforms.linux;
    mainProgram = "dora-explorer";
  };
}
