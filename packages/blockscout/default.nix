{
  pkgs,
  lib,
  fetchFromGitHub,
  ...
}:
pkgs.stdenv.mkDerivation rec {
  pname = "blockscout";
  version = "7.0.2";

  src = fetchFromGitHub {
    owner = "blockscout";
    repo = "blockscout";
    rev = "v${version}";
    hash = "sha256-cfAd58l+gJ9dY/XFYnnQorHLNAiXn//gi+iY17iWcsc=";
  };

  unpackPhase = ''
    mkdir -p $out
    cp -r $src/docker-compose $out/
  '';
}
