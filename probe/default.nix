{buildGoModule}:
buildGoModule {
  pname = "probe";
  version = "0.0.0";

  src = ./.;

  vendorHash = "sha256-eXAMN8JZGqSbRoXwkJSgGr+rGSc7IbCMEL6z0OKhg6g=";

  doCheck = false;

  meta.mainProgram = "probe";
}
