{buildGoModule}:
buildGoModule {
  pname = "probe";
  version = "0.0.0";

  src = ./.;

  vendorHash = "sha256-P/K0OCUxbbfKoPpVkVyTdH1uEoykAJC3nPkWRSL/7hc=";

  doCheck = false;

  meta.mainProgram = "probe";
}
