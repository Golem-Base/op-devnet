{ pkgs, ... }:
{
  mkDoraConfig = args: import ./dora.nix ({ inherit pkgs; } // args);
}
