{
  description = "op.nix / Optimism dev environment with Nix!";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devshell.url = "github:numtide/devshell";
    foundry.url = "github:shazow/foundry.nix/monthly"; # Use monthly branch for permanent releases
    solc = {
      url = "github:hellwolf/solc.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    process-compose.url = "github:Platonic-Systems/process-compose-flake";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      debug = true;

      imports = [
        inputs.devshell.flakeModule
        inputs.treefmt-nix.flakeModule
        ./shell.nix
        ./formatter.nix
        ./packages
        ./devnet
        ./devnet/devnet2.nix
      ];

      systems = ["x86_64-linux"];

      flake = let
        inherit (inputs.nixpkgs) lib;
        accounts = (import ./devnet/accounts.nix).accounts;
        accountAllocs =
          builtins.toJSON
          (lib.listToAttrs
            (lib.map (
                account: {
                  name = account.address;
                  value = {balance = "0x0";};
                }
              )
              accounts));
      in {
        inherit lib accountAllocs;
      };
    };
}
