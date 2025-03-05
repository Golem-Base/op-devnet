{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "op-geth";
  version = "1.101500.1";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "op-geth";
    rev = "v${version}";
    hash = "sha256-YlyWcTzzsMaezS17pziYkvpYtD565K5ukOuzPYf1xyo=";
    fetchSubmodules = true;
  };

  proxyVendor = true;
  vendorHash = "sha256-Fpx4cVUC7Gu1fpiVyRLbEDo6jI3Mx99t0hHImPS5pc0=";

  subPackages = [
    "cmd/geth"
  ];

  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    description = "";
    homepage = "https://github.com/ethereum-optimism/op-geth";
    license = licenses.gpl3Only;
    mainProgram = "geth";
  };
}
