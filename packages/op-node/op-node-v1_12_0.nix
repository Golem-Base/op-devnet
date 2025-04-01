{
  buildGoModule,
  fetchFromGitHub,
  lib,
  libpcap,
  ...
}:
buildGoModule rec {
  pname = "op-node";
  version = "1.12.0";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "optimism";
    rev = "op-node/v${version}";
    hash = "sha256-5rZgf0SZ9KzO0SPBGBtdp0FGM1afg2824q79mRsZMSQ=";
    fetchSubmodules = true;
  };
  vendorHash = "sha256-x+2TL/TAl1xGYUmlGWt/i1XOuCB2R++WMByx7cee+4c=";

  postInstall = ''
    mv $out/bin/cmd $out/bin/op-node
  '';

  doCheck = false;

  subPackages = ["op-node/cmd"];

  buildInputs = [libpcap];

  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    description = "Optimism is Ethereum, scaled.";
    homepage = "https://optimism.io/";
    license = with licenses; [mit];
    mainProgram = "op-node";
    platforms = ["x86_64-linux"];
  };
}
