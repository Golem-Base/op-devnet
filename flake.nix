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
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {

      debug = true;

      imports = [
        inputs.devshell.flakeModule
        ./shell.nix
        ./packages
      ];

      systems = [ "x86_64-linux" ];

      flake =
        let
          lib = inputs.nixpkgs.lib;

        in
        {
          inherit lib;
        };

      perSystem =
        { pkgs, system, ... }:
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              inputs.foundry.overlay
              inputs.solc.overlay

              # (final: prev: {
              #   inherit (final.callPackage ./buildSolidityPackage.nix { }) buildRemoteFoundryPackage;
              # })
            ];
          };

          # packages.optimism-contracts-v1_6_0 = pkgs.buildRemoteFoundryPackage rec {
          #   pname = "contracts-bedrock";
          #   version = "1.6.0";
          #   owner = "ethereum-optimism";
          #   repo = "optimism";
          #   rev = "op-contracts/v${version}";
          #   hash = "sha256-VhdFZrzXTza28r9cA0DzOH57kPPLjzKdOzcZZJSdEnc=";
          #   foundryTomlDir = "./packages/contracts-bedrock";
          # };
        };
    };
}
