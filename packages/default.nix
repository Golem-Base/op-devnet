_: {

  imports = [ ./deploy-optimism ];
  perSystem =
    {
      pkgs,
      lib,
      system,
      ...
    }:
    let
      inherit (pkgs) callPackage;
    in
    {
      packages = {
        op-node = callPackage ./op-node { };
        op-proposer = callPackage ./op-proposer { };
        op-batcher = callPackage ./op-batcher { };
        op-geth = callPackage ./op-geth { };

        contracts-bedrock-v1_8_0 = callPackage ./contracts-bedrock/v1_8_0.nix { };
        contracts-bedrock-v1_3_0 = callPackage ./contracts-bedrock/v1_3_0.nix { };

        op-config = import ./op-config { inherit pkgs; };
      };
    };
}
