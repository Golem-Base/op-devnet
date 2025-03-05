{
  description = "Description for the project";

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
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {

      debug = true;

      imports = [
        inputs.devshell.flakeModule
        ./shell.nix
        ./packages
        ./devnet
      ];

      systems = [ "x86_64-linux" ];

      flake = {
        inherit (inputs.nixpkgs) lib;
      };

      perSystem =
        {
          self',
          pkgs,
          system,
          ...
        }:
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              inputs.foundry.overlay
              inputs.solc.overlay
            ];
          };
        };
    };
}
