{ ... }:
{
  perSystem =
    { pkgs, system, ... }:
    let
      inherit (pkgs) callPackage;
    in
    {
      packages = {
        op-node = callPackage ./op-node { };
        op-proposer = callPackage ./op-proposer { };
        op-batcher = callPackage ./op-batcher { };
        op-geth = callPackage ./op-geth { };
        contracts-bedrock = callPackage ./contracts-bedrock { };
        createL1Genesis = callPackage ./createL1Genesis { };
      };
    };
}
