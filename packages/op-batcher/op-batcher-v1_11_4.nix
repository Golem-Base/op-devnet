{
  buildGoModule,
  fetchFromGitHub,
  lib,
  libpcap,
  ...
}:
buildGoModule rec {
  pname = "op-node";
  version = "1.11.4";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "optimism";
    rev = "op-node/v${version}";
    hash = "sha256-m5dpYDWXoFml21unYJwC6SR4wmmeikya8ScNm9q1wK0=";
    fetchSubmodules = true;
  };
  vendorHash = "sha256-NbimgObAnbFCKTYYqLM0A5OWzvFYTDbbC0fBgyiCWck=";

  postInstall = ''
    mv $out/bin/cmd $out/bin/op-batcher
  '';

  doCheck = false;

  subPackages = ["op-batcher/cmd"];

  buildInputs = [libpcap];

  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    description = "Optimism is Ethereum, scaled.";
    homepage = "https://optimism.io/";
    license = with licenses; [mit];
    mainProgram = "op-batcher";
    platforms = ["x86_64-linux"];
  };
}
