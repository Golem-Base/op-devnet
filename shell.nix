_: {
  perSystem = {
    self',
    pkgs,
    ...
  }: {
    devShells.default = pkgs.mkShell {
      packages = with pkgs; [
        foundry
        sops
        ssh-to-age
        go-ethereum
        alejandra
        self'.packages.prysm
        self'.packages.eth2-testnet-genesis
        self'.packages.kurtosis
        self'.packages.dora
      ];
    };
  };
}
