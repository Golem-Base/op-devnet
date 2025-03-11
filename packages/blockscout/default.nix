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

  mixFodDeps = beamPackages.fetchMixDeps {
    pname = "mix-deps-${pname}";
    inherit src version;
    # nix will complain and tell you the right value to replace this with
    hash = "sha256-oaJoG2MFbxtWAlSB7uAMbrWyzoF4si21JwIFVLerBII=";
    # mixEnv = ""; # default is "prod", when empty includes all dependencies, such as "dev", "test".
    # if you have build time environment variables add them here
    # MY_ENV_VAR = "my_value";
  };

  mixNixDeps = import ./mix_deps.nix {
    inherit lib beamPackages;

    overrides = final: prev: {
      # https://github.com/blockscout/absinthe_plug.git?90a8188e94e2650f13259fb16462075a87f98e18
      # ^ This is their forked version
      absinthe_plug = beamPackages.buildMix rec {
        name = "absinthe_plug";
        version = "1.5.8";
        src = beamPackages.fetchHex {
          pkg = "absinthe_plug";
          version = "${version}";
          sha256 = "sha256-u7BBdmR7c1gohh57JwVGXlPiz1TM9ac93R69hV+Zblo=";
        };
        beamDeps = with final; [absinthe plug];
      };

      coerce = beamPackages.buildMix rec {
        name = "coerce";
        version = "1.0.1";
        src = beamPackages.fetchHex {
          pkg = "coerce";
          version = "${version}";
          sha256 = "sha256-tEppFwD3oaFbS34v8fowvr1mmSmsiqQ8/+ni+L8FHPE=";
        };
      };

      prometheus_ex = beamPackages.buildMix rec {
        name = "prometeus_ex";
        version = "3.1.0";
        src = beamPackages.fetchHex {
          pkg = "prometheus_ex";
          version = "${version}";
          sha256 = "sha256-ke9yMqX8CBbE+oGniK6kqT5A7/gklmIjsJZEWJW1liI=";
        };
        beamDeps = with final; [prometheus];
      };

      prometheus_process_collector = beamPackages.buildMix rec {
        name = "prometheus_process_collector";
        version = "1.6.1";
        src = beamPackages.fetchHex {
          pkg = "prometheus_process_collector";
          version = "${version}";
          sha256 = lib.fakeHash;
        };
        beamDeps = with final; [prometheus];
      };
    };
  };
in
  beamPackages.mixRelease {
    inherit src pname version;
    inherit mixNixDeps;
    # inherit mixFodDeps;
    # if you have build time environment variables add them here
    # MY_ENV_VAR = "my_value";

    # postBuild = ''
    #   # for external task you need a workaround for the no deps check flag
    #   # https://github.com/phoenixframework/phoenix/issues/2690
    #   mix do deps.loadpaths --no-deps-check, phx.digest
    #   mix phx.digest --no-deps-check
    # '';
  }
