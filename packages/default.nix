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
        contracts-bedrock_v1_8_0 = callPackage ./contracts-bedrock/v1_8_0.nix { };
        contracts-bedrock_v1_3_0 = callPackage ./contracts-bedrock/v1_3_0.nix { };
        # contracts-bedrock = callPackage ./contracts-bedrock { };

        op-config = pkgs.symlinkJoin {
          name = "op-config";
          paths =
            [
              ((pkgs.writeScriptBin "op-config" (builtins.readFile ./scripts/config.sh)).overrideAttrs (old: {
                buildCommand = "${old.buildCommand}\n patchShebangs $out";
              }))
            ]
            ++ (with pkgs; [
              foundry
              jq
            ]);
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = "wrapProgram $out/bin/op-config --prefix PATH : $out/bin";
        };
      };
    };
}
