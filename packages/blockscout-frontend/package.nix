{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  yarnConfigHook,
  yarnBuildHook,
  yarnInstallHook,
  nodejs_22,
  makeWrapper,
  jq,
  bash,
  coreutils,
  gnugrep,
  gnused,
  findutils,
  writeText,
  envFile ? ./envs/devnet-l1/env,
}: let
  nodejs = nodejs_22;
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "blockscout-frontend";
    version = "1.38.1";

    src = fetchFromGitHub {
      owner = "blockscout";
      repo = "frontend";
      rev = "v${finalAttrs.version}";
      hash = "sha256-89nfcW9G6Cu8OVc9sCXeLcNGhT1OUVauyzqljRuxrK4=";
    };

    # Patch the package.json before the build starts
    postPatch = ''
      ${jq}/bin/jq --arg version ">=${nodejs.version}" '.engines.node = $version' package.json > package.json.new
      mv package.json.new package.json
    '';

    yarnOfflineCache = fetchYarnDeps {
      yarnLock = finalAttrs.src + "/yarn.lock";
      hash = "sha256-rByh4k1DpF2OESTMl9K3Rd/0yuwJtJEOhS3FSFUiYyc=";
    };

    nativeBuildInputs = [
      nodejs
      yarnConfigHook
      yarnBuildHook
      yarnInstallHook
      makeWrapper
      bash
      jq
      coreutils
      gnugrep
      gnused
      findutils
    ];

    # Skip removing dev dependencies - Next.js needs them for proper builds
    yarnKeepDevDeps = true;
    yarnBuildScript = "build";

    env = {
      NODE_ENV = "production";
      # Required for the build_sprite.sh script
      NEXT_PUBLIC_APP_ENV = "development";
    };

    preBuild = ''
      # Make sure public/assets directory exists
      mkdir -p ./public/assets

      # Copy env file
      cp ${envFile} ./.env

      # Build env.js
      if [ -f ./deploy/scripts/make_envs_script.sh ]; then
        PATH="${lib.makeBinPath [coreutils gnugrep gnused findutils jq]}:$PATH" bash ./deploy/scripts/make_envs_script.sh
      fi

      # Build SVG sprites
      if [ -f ./deploy/scripts/build_sprite.sh ]; then
        mkdir -p ./public/icons
        PATH="${lib.makeBinPath [coreutils gnugrep gnused findutils jq]}:$PATH" bash ./deploy/scripts/build_sprite.sh
      fi

    '';

    # Install phase following exactly the Next.js standalone docs
    installPhase = ''
      runHook preInstall

      # Create base output directory
      mkdir -p $out

      # Copy standalone directory contents (server.js and node_modules)
      cp -r .next/standalone/. $out/

      # Copy public directory to standalone output
      cp -r public $out/public

      mkdir -p $out/public/icons
      cp -r ${./ethereum.svg} $out/public/icons/sprite.svg

      mkdir -p $out/public/assets/configs
      cp -r ${./ethereum.svg} $out/public/assets/configs/network_logo_dark.svg
      cp -r ${./ethereum.png} $out/public/assets/configs/network_icon_dark.png

      # Copy .next/static to standalone/.next/static
      mkdir -p $out/.next/static
      cp -r .next/static/. $out/.next/static/

      # Create the executable script
      mkdir -p $out/bin

      # Create wrapper
      makeWrapper ${nodejs}/bin/node $out/bin/blockscout-frontend \
        --add-flags "$out/server.js" \
        --set NEXT_TELEMETRY_DISABLED "1" \
        --set NODE_ENV "production" \
        --chdir "$out"

      runHook postInstall
    '';

    meta = with lib; {
      description = "Blockscout frontend application";
      homepage = "https://github.com/blockscout/frontend";
      license = licenses.gpl3;
      maintainers = with maintainers; [aldoborrero];
      mainProgram = "blockscout-frontend";
    };
  })
