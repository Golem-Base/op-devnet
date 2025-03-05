_: {
  perSystem = {pkgs, ...}: {
    packages.blockscout-backend = pkgs.callPackage ./backend.nix {};
  };
}
