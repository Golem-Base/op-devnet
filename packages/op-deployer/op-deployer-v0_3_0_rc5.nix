{
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "op-deployer";
  version = "0.3.0-rc.5";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "optimism";
    rev = "op-deployer/v${version}";
    hash = "sha256-QDD6o7YSEKG3Wm4oC3SeFnbupWike00BwWhbFZPQg3U=";
  };

  patches = [./op-deployer-v0_3_0_rc5.patch];

  vendorHash = "sha256-keiXoCvi2ZOdN3bPkwNo+jVPaWZRt21iODBy0EBIFMo=";

  doCheck = false;

  subPackages = ["op-deployer/cmd/op-deployer"];

  meta.mainProgram = "op-deployer";
}
