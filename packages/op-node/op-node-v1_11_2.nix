{
  buildGoModule,
  fetchFromGitHub,
  lib,
  libpcap,
  ...
}:
buildGoModule rec {
  pname = "op-node";
  version = "1.11.2";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "optimism";
    rev = "op-node/v${version}";
    hash = "sha256-daxOrdRbx2tClRNlNbslez/2aIKe0CJ3W4XHf8Lrxj0=";
    fetchSubmodules = true;
  };
  vendorHash = "sha256-8V2m+hWZ1m4Zv+QKXMDJmM7SDo1Lpo5FrnxLpWbGkPw=";

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
