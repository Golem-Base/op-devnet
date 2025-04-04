{
  description = "op.nix / Optimism dev environment with Nix!";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devshell.url = "github:numtide/devshell";
    foundry.url = "github:shazow/foundry.nix/stable";
    withdrawer.url = "git+ssh://git@github.com/Golem-Base/withdrawer";

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
      ];

      systems = ["x86_64-linux"];
      perSystem = {system, ...}: {
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
