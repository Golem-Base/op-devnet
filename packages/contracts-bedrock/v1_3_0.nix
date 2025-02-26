{ pkgs, fetchFromGitHub, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "contracts-bedrock";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "optimism";
    rev = "op-contracts/v${version}";
    hash = "sha256-Jw42QiFsQiCzgRJonr+w9cI/2WZKFSKYHiQTFit4Wts=";
    fetchSubmodules = true;
  };

  unpackPhase = ''
    mkdir -p $out/share
    cp $src/packages/contracts-bedrock/foundry.toml $out/share
    cp -r $src/packages/contracts-bedrock/src $out/share
    cp -r $src/packages/contracts-bedrock/test $out/share
    cp -r $src/packages/contracts-bedrock/scripts $out/share
    cp -r $src/packages/contracts-bedrock/lib $out/share
  '';
}
