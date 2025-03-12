{
  pkgs,
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
        name = "prometheus_ex";
        version = "3.1.0";
        src = beamPackages.fetchHex {
          pkg = "prometheus_ex";
          version = "${version}";
          sha256 = "sha256-vFhNM6q66UznXUd+tmxxeHVbRaCa+3rdslPZDrZgId4=";
        };
        beamDeps = with final; [prometheus];
      };

      prometheus_process_collector = beamPackages.buildRebar3 rec {
        name = "prometheus_process_collector";
        version = "1.6.1";
        src = beamPackages.fetchHex {
          pkg = "prometheus_process_collector";
          version = "${version}";
          sha256 = "sha256-ke9yMqX8CBbE+oGniK6kqT5A7/gklmIjsJZEWJW1liI=";
        };
        beamDeps = with final; [prometheus];
      };

      ex_keccak = prev.ex_keccak.override {
        preBuild = let
          tarball = builtins.fetchurl {
            url = "https://github.com/ExWeb3/ex_keccak/releases/download/v0.7.6/libexkeccak-v0.7.6-nif-2.16-x86_64-unknown-linux-gnu.so.tar.gz";
            sha256 = "065zn88b6a6ih8zzhxlh1l8cpx3wpdbmjshpz30gg6c1ykv81j9k";
          };
        in ''
          export RUSTLER_PRECOMPILED_GLOBAL_CACHE_PATH=./.rustler_precompiled
          mkdir -p $RUSTLER_PRECOMPILED_GLOBAL_CACHE_PATH/metadata

          mkdir -p priv/native/ex_keccak
          cd priv/native/ex_keccak
          tar -xzvf ${tarball}
          cd -
        '';
      };

      ex_secp256k1 = prev.ex_secp256k1.override {
        preBuild = let
          tarball = builtins.fetchurl {
            url = "https://github.com/ayrat555/ex_secp256k1/releases/download/v0.7.4/libex_secp256k1-v0.7.4-nif-2.16-x86_64-unknown-linux-gnu.so.tar.gz";
            sha256 = "0bd8jx3gdx7dkhs9q8vqgh4kifv0k3alxflm0qll2zs7cy20qxiz";
          };
        in ''
          export RUSTLER_PRECOMPILED_GLOBAL_CACHE_PATH=./.rustler_precompiled
          mkdir -p $RUSTLER_PRECOMPILED_GLOBAL_CACHE_PATH/metadata

          mkdir -p priv/native/ex_secp256k1
          cd priv/native/ex_secp256k1
          tar -xzvf ${tarball}
          cd -
        '';
      };

      ex_brotli = prev.ex_brotli.override {
        preBuild = let
          tarball = builtins.fetchurl {
            url = "https://github.com/mfeckie/ex_brotli/releases/download/0.5.0/libex_brotli-v0.5.0-nif-2.15-x86_64-unknown-linux-gnu.so.tar.gz";
            sha256 = "18hjhaqx5py57l94cnsjr6csv0gk467was5svzr68qq8hbbjpqjf";
          };
        in ''
          export RUSTLER_PRECOMPILED_GLOBAL_CACHE_PATH=./.rustler_precompiled
          mkdir -p $RUSTLER_PRECOMPILED_GLOBAL_CACHE_PATH/metadata

          mkdir -p priv/native/ex_brotli
          cd priv/native/ex_brotli
          tar -xzvf ${tarball}
          cd -
        '';
      };
    };
  };
in
  beamPackages.mixRelease {
    inherit src pname version;
    inherit mixNixDeps;
    patches = [./removed_nft_media_handler.patch];
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
