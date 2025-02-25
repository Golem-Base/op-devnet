{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "op-geth";
  version = "1.101311.0";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "op-geth";
    rev = "v${version}";
    hash = "sha256-6BSaFtOAdOCnYexHB1d69ixNTYUO0e+Qn2A2+PICutQ";
    fetchSubmodules = true;
  };

  subPackages = [
    "cmd/abidump"
    "cmd/abigen"
    "cmd/bootnode"
    "cmd/clef"
    "cmd/devp2p"
    "cmd/ethkey"
    "cmd/evm"
    # "cmd/faucet"
    "cmd/geth"
    "cmd/p2psim"
    "cmd/rlpdump"
    "cmd/utils"
  ];

  vendorHash = "sha256-cWMIqQSEr+MjFF8qJzdhnXxSLNu0/G7RsyfpeBzugxY";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    description = "";
    homepage = "https://github.com/ethereum-optimism/op-geth";
    license = licenses.gpl3Only;
  };
}
