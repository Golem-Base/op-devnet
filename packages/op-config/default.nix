{ pkgs }:

pkgs.symlinkJoin {
  name = "op-config";
  paths =
    [
      ((pkgs.writeScriptBin "op-config" (builtins.readFile ./config.sh)).overrideAttrs (old: {
        buildCommand = "${old.buildCommand}\n patchShebangs $out";
      }))
    ]
    ++ (with pkgs; [
      foundry
      jq
    ]);
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = "wrapProgram $out/bin/op-config --prefix PATH : $out/bin";
}
