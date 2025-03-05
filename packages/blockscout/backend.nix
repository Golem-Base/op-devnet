{pkgs}: let
  pname = "blockscout";
  version = "7.0.2";

  src = builtins.fetchGit {
    url = "https://github.com/blockscout/blockscout.git";
    rev = "338c63422892e6f672824f26527fc60a14d788b3";
  };

  beamPackages = pkgs.beam.packagesWith pkgs.beam.interpreters.erlang_26;
in
  # "absinthe_plug": {:git, "https://github.com/blockscout/absinthe_plug.git", "90a8188e94e2650f13259fb16462075a87f98e18", [tag: "1.5.8"]},
  beamPackages.mixRelease {
    inherit src pname version;
    removeCookie = true;
    mixNixDeps = with pkgs;
      import ./deps.nix {
        inherit lib beamPackages;
        # overrides = self: super: {
        # };
      };
  }
