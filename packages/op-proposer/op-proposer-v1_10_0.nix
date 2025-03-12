{
  buildGoModule,
  fetchFromGitHub,
  lib,
  libpcap,
  ...
}:
buildGoModule rec {
  pname = "op-proposer";
  version = "1.10.0";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "optimism";
    rev = "op-node/v${version}";
    hash = "sha256-+16dXUAlEnw3A+F5H9CyoR0UJslKUvGgxXHixfWESho=";
    fetchSubmodules = true;
  };
  vendorHash = "sha256-nh6bDZdHO2MCz7F2HWBCnOxaEB0fz64RXUtjASEg9Js=";

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
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
  };
}
