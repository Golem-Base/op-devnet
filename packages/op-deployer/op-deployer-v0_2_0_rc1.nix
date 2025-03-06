{
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "op-deployer";
  version = "0.2.0-rc.1";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "optimism";
    rev = "op-deployer/v${version}";
    hash = "sha256-PyQLMm0JYbFfXEilPWeNwl6gaRZOhxUuoSBalr1gw58=";
  };

  patches = [./chain_id_2345.patch];

  vendorHash = "sha256-/jW5EPRGjUi5ZrOBS08bXfP0x1KHFgelY7WseDvGzFM=";

  doCheck = false;

  subPackages = ["op-deployer/cmd/op-deployer"];

  meta.mainProgram = "op-deployer";
}
