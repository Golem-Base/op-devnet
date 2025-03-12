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
        self'.packages.op-geth-v1_101500_1
        self'.packages.op-node-v1_11_2
        self'.packages.op-batcher-v1_11_4
        self'.packages.op-proposer-v1_10_0
        self'.packages.prysm
        self'.packages.eth2-testnet-genesis
        self'.packages.dora
        self'.packages.op-deployer-v0_2_0_rc1
      ];

      shellHook = ''
        export PRJ_ROOT="$PWD"
        mkdir -p "$PRJ_ROOT/.data"
        export PRJ_DATA="$PRJ_ROOT/.data"
      '';
    };
  };
}
