{inputs, ...}: {
  perSystem = {
    self',
    pkgs,
    system,
    ...
  }: {
    devShells.default = pkgs.mkShellNoCC {
      packages =
        (with pkgs; [
          foundry
          sops
          ssh-to-age
          go-ethereum
          alejandra

          go
          go-tools
          gopls
          gotools

          process-compose
        ])
        ++ (with self'.packages; [
          packages.eth2-testnet-genesis
          packages.kurtosis
          packages.op-batcher-v1_11_4
          packages.op-deployer-v0_2_0_rc1
          packages.op-geth-v1_101500_1
          packages.op-node-v1_11_2
          packages.op-proposer-v1_10_0
        ]) ++ (with inputs; [
          withdrawer.packages.${system}.default
        ]);
    };
  };
}
