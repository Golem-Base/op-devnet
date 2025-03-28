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
          self'.packages.op-geth-v1_101500_1
          self'.packages.op-node-v1_11_2
          self'.packages.op-batcher-v1_11_4
          self'.packages.op-proposer-v1_10_0
          self'.packages.prysm
          self'.packages.eth2-testnet-genesis
          self'.packages.kurtosis
          self'.packages.dora
          inputs.withdrawer.packages.${system}.default
          self'.packages.op-deployer-v0_3_0_rc5

          go
          go-tools
          gopls
          gotools

          process-compose
        ])
        ++ (with self'.packages; [
          eth2-testnet-genesis
          kurtosis
          op-batcher-v1_11_4
          op-deployer-v0_2_0_rc1
          op-geth-v1_101500_1
          op-node-v1_11_2
          op-proposer-v1_10_0
        ])
        ++ (with inputs; [
          withdrawer.packages.${system}.default
        ]);
    };
  };
}
