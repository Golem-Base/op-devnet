{
  buildGoModule,
  fetchFromGitHub,
  lib,
  libpcap,
  ...
}:
buildGoModule rec {
  pname = "op-node";
  version = "1.7.5";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "optimism";
    rev = "op-node/v${version}";
    hash = "sha256-ResHiLthkrSym9jZ/T+IJvO+RHCjT2zlb4v/vTqrdNo=";
    fetchSubmodules = true;
  };
  vendorHash = "sha256-P5Y/xOD05Nt59sQFZ9IOuztx9csidB7RLFUywlSamPc=";

  postInstall = ''
    mv $out/bin/cmd $out/bin/op-proposer
  '';

  doCheck = false;

  subPackages = ["op-proposer/cmd"];

  buildInputs = [libpcap];

  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    description = "Optimism is Ethereum, scaled.";
    homepage = "https://optimism.io/";
    license = with licenses; [mit];
    mainProgram = "op-proposer";
    platforms = ["x86_64-linux"];
  };
}
