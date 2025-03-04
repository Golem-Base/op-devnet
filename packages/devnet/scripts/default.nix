{ pkgs, ... }:
{
  check-l1-ready = import ./check-l1-ready.nix { inherit pkgs; };
}
