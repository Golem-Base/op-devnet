{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation rec {
  pname = "kurtosis-cli";
  version = "1.5.0";

  src = fetchurl {
    url = "https://github.com/kurtosis-tech/kurtosis-cli-release-artifacts/releases/download/${version}/kurtosis-cli_${version}_linux_amd64.tar.gz";
    sha256 = "sha256-hxyVeKcgvfX/pgHIoKoNVLOwwJ6Q5RKRe8eEN3dqRFs=";
  };

  unpackPhase = ''
    tar -xzf $src
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp kurtosis $out/bin/
    chmod +x $out/bin/kurtosis
  '';

  meta = with lib; {
    description = "CLI for Kurtosis, a framework for building and running distributed systems";
    homepage = "https://github.com/kurtosis-tech/kurtosis";
    license = licenses.asl20;
    platforms = platforms.linux;
  };
}
