_: {
  imports = [./deploy-optimism];
  perSystem = {pkgs, ...}: let
    inherit (pkgs) callPackage;
  in {
    packages = rec {
      bls = callPackage ./prysm/bls.nix {};
      blst = callPackage ./prysm/blst.nix {};
      prysm = callPackage ./prysm {inherit bls blst;};
      kurtosis = callPackage ./kurtosis {};
      dora = callPackage ./dora {};
      blockscout = callPackage ./blockscout {};
      eth2-testnet-genesis = callPackage ./eth2-testnet-genesis {inherit bls;};
      op-node = callPackage ./op-node {};
      op-proposer = callPackage ./op-proposer {};
      op-batcher = callPackage ./op-batcher {};
      op-geth = callPackage ./op-geth {};

      contracts-bedrock-v1_8_0 = callPackage ./contracts-bedrock/v1_8_0.nix {};
      contracts-bedrock-v1_3_0 = callPackage ./contracts-bedrock/v1_3_0.nix {};

      op-config = import ./op-config {inherit pkgs;};
    };
  };
}
