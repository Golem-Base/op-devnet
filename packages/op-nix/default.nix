{buildGoModule}:
buildGoModule {
  pname = "op-nix";
  version = "0.0.0";

  src = ../../.;

  vendorHash = "sha256-9oM0nFf7ujoJMl5UXZWO4T/ENHO1JQyZx4ti9geKuQI=";

  doCheck = false;

  meta.mainProgram = "op-nix";
}
