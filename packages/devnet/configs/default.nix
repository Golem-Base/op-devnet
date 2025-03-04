{ pkgs, ... }:
{
  mkDoraConfig = args: import ./dora.nix ({ inherit pkgs; } // args);
  mkGenesis = args: import ./genesis.nix ({ inherit pkgs; } // args);
  mkChainConfig = args: import ./chain.nix ({ inherit pkgs; } // args);
}
