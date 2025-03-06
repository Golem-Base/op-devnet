_: {
  imports = [./deploy-optimism-script];
  perSystem = {pkgs, ...}: let
    inherit (pkgs) callPackage;
  in {
    packages = rec {
      bls = callPackage ./prysm/bls.nix {};
      blst = callPackage ./prysm/blst.nix {};
      prysm = callPackage ./prysm {inherit bls blst;};
      kurtosis = callPackage ./kurtosis {};
      dora = callPackage ./dora {};
      # blockscout = callPackage ./blockscout {};
      eth2-testnet-genesis = callPackage ./eth2-testnet-genesis {inherit bls;};

      # op stack (supports contracts v1_3_0 to v1_8_0)
      op-node = callPackage ./op-node {};
      op-proposer = callPackage ./op-proposer {};
      op-batcher = callPackage ./op-batcher {};
      op-geth = callPackage ./op-geth {};

      contracts-bedrock-v1_8_0 = callPackage ./contracts-bedrock/v1_8_0.nix {};
      contracts-bedrock-v1_3_0 = callPackage ./contracts-bedrock/v1_3_0.nix {};

      op-config = import ./op-config {inherit pkgs;};
      deploy-optimism = callPackage ./deploy-optimism {};

      # op stack (supports contracts v2.0.0)
      op-batcher-v1_11_4 = callPackage ./op-batcher/op-batcher-v1_11_4.nix {};
      op-deployer-v0_2_0_rc1 = callPackage ./op-deployer/op-deployer-v0_2_0_rc1.nix {};
      op-geth-v1_101500_1 = callPackage ./op-geth/op-geth-v1_101500_1.nix {};
      op-node-v1_11_2 = callPackage ./op-node/op-node-v1_11_2.nix {};
      op-proposer-v1_10_0 = callPackage ./op-proposer/op-proposer-v1_10_0.nix {};
    };
  };
}
