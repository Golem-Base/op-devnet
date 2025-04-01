{lib, ...}: {
  perSystem = {
    pkgs,
    self',
    ...
  }: let
    inherit (pkgs) callPackage;
  in {
    packages = rec {
      bls = callPackage ./prysm/bls.nix {};
      blst = callPackage ./prysm/blst.nix {};
      prysm = callPackage ./prysm {inherit bls blst;};
      kurtosis = callPackage ./kurtosis {};
      dora = callPackage ./dora {};

      blockscout = callPackage ./blockscout {};
      blockscout-frontend = callPackage ./blockscout-frontend/package.nix {};

      eth2-testnet-genesis = callPackage ./eth2-testnet-genesis {inherit bls;};

      op-node = callPackage ./op-node {};
      op-proposer = callPackage ./op-proposer {};
      op-batcher = callPackage ./op-batcher {};
      op-geth = callPackage ./op-geth {};

      contracts-bedrock-v3_0_0-rc2 = callPackage ./contracts-bedrock/v3.0.0-rc.2 {};
      contracts-bedrock-v2_0_0-rc1 = callPackage ./contracts-bedrock/v2.0.0-rc.1 {};
      contracts-bedrock-v1_7_0-beta_1_l2-contracts = callPackage ./contracts-bedrock/v1.7.0-beta.1+l2-contracts {};

      op-config = import ./op-config {inherit pkgs;};

      probe = callPackage ../probe {};

      op-batcher-v1_11_4 = callPackage ./op-batcher/op-batcher-v1_11_4.nix {};

      op-deployer-v0_2_0-rc2 = callPackage ./op-deployer/op-deployer-v0.2.0-rc.2.nix {};

      op-geth-v1_101500_1 = callPackage ./op-geth/op-geth-v1_101500_1.nix {};
      op-node-v1_11_2 = callPackage ./op-node/op-node-v1_11_2.nix {};
      op-node-v1_12_0 = callPackage ./op-node/op-node-v1_12_0.nix {};
      op-proposer-v1_10_0 = callPackage ./op-proposer/op-proposer-v1_10_0.nix {};
    };

    apps =
      lib.mapAttrs (_name: package: {
        type = "app";
        program = lib.getExe package;
      }) (lib.filterAttrs (
          _name: package:
            lib.isDerivation package && package ? meta.mainProgram
        )
        self'.packages);
  };
}
