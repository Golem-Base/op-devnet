{ inputs, ... }:
{
  perSystem =
    {
      config,
      self',
      pkgs,
      system,
      ...
    }:
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          nixfmt-rfc-style
          foundry-bin
          nodePackages.prettier
          sops
          ssh-to-age
        ];
      };
    };
}
