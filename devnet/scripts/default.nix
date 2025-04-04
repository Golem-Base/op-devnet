{
  pkgs,
  lib,
  withdrawer,
  ...
}:
lib.makeScope pkgs.newScope (self: {
  check-l1-ready = self.callPackage ./check-l1-ready.nix {};
  op-validator-init = self.callPackage {};
  seed-l1 = self.callPackage ./seed-l1.nix {};
  seed-l2 = self.callPackage ./seed-l2.nix {inherit withdrawer;};
})
