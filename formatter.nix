{inputs, ...}: {
  perSystem = {system, ...}: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [
        inputs.foundry.overlay
        inputs.solc.overlay
      ];
    };

    treefmt.config = {
      flakeFormatter = true;
      flakeCheck = true;
      projectRootFile = "flake.nix";
      programs = {
        alejandra.enable = true;
        deadnix.enable = true;
        mdformat.enable = true;
        shellcheck.enable = true;
        shfmt.enable = true;
        statix.enable = true;
        yamlfmt.enable = true;
        jsonfmt.enable = true;
      };
      settings.formatter = {
        alejandra.priority = 3;
        deadnix.priority = 1;
        statix.priority = 2;
      };
    };
  };
}
