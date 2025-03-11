{
  stdenv,
  beam,
  lib,
  fetchFromGitHub,
  ...
}: let
  beamPackages = beam.packagesWith beam.interpreters.erlang_26;

  pname = "blockscout";

  version = "7.0.2";

  src = fetchFromGitHub {
    owner = "blockscout";
    repo = "blockscout";
    rev = "v${version}";
    hash = "sha256-cfAd58l+gJ9dY/XFYnnQorHLNAiXn//gi+iY17iWcsc=";
  };

  # mixFodDeps = packages.fetchMixDeps {
  #   pname = "mix-deps-${pname}";
  #   inherit src version;
  #   # nix will complain and tell you the right value to replace this with
  #   hash = "sha256-oaJoG2MFbxtWAlSB7uAMbrWyzoF4si21JwIFVLerBII=";
  #   # mixEnv = ""; # default is "prod", when empty includes all dependencies, such as "dev", "test".
  #   # if you have build time environment variables add them here
  #   # MY_ENV_VAR = "my_value";
  # };
  mixNixDeps = import ./mix_deps.nix {
    inherit lib beamPackages;
  };
in
  beamPackages.mixRelease {
    inherit src pname version mixNixDeps;
    # if you have build time environment variables add them here
    # MY_ENV_VAR = "my_value";

    postBuild = ''
      # for external task you need a workaround for the no deps check flag
      # https://github.com/phoenixframework/phoenix/issues/2690
      mix do deps.loadpaths --no-deps-check, phx.digest
      mix phx.digest --no-deps-check
    '';
  }
