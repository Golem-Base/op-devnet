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
}: let
  nodejs = nodejs_22;

  # Create a .env file with NEXT_PUBLIC_ prefixed variables
  envFile = writeText "blockscout-frontend-env" ''
    NEXT_PUBLIC_NETWORK_NAME="Op Dev"
    NEXT_PUBLIC_NETWORK_SHORT_NAME="OpDev"
    NEXT_PUBLIC_NETWORK_ID="2345"
    NEXT_PUBLIC_NETWORK_CURRENCY_NAME="Ether"
    NEXT_PUBLIC_NETWORK_CURRENCY_SYMBOL="ETH"
    NEXT_PUBLIC_NETWORK_CURRENCY_DECIMALS="18"
    NEXT_PUBLIC_NETWORK_VERIFICATION_TYPE="validation"
    NEXT_PUBLIC_IS_TESTNET="true"
    NEXT_PUBLIC_API_PROTOCOL="http"
    NEXT_PUBLIC_API_HOST="localhost"
    NEXT_PUBLIC_API_PORT="4040"
    NEXT_PUBLIC_APP_PROTOCOL="http"
    NEXT_PUBLIC_APP_HOST="localhost"
    NEXT_PUBLIC_APP_PORT="3000"
    NEXT_PUBLIC_VIEWS_ADDRESS_IDENTICON_TYPE="jazzicon"
    NEXT_PUBLIC_WEB3_WALLETS='["metamask"]'
    NEXT_PUBLIC_TRANSACTION_INTERPRETATION_PROVIDER="blockscout"
    NEXT_PUBLIC_HOMEPAGE_CHARTS='["daily_txs"]'
    NEXT_PUBLIC_HOMEPAGE_STATS='["total_blocks","average_block_time","total_txs","wallet_addresses","gas_tracker"]'
    NEXT_PUBLIC_PROMOTE_BLOCKSCOUT_IN_TITLE="false"
    NEXT_PUBLIC_OG_DESCRIPTION="Op Blockchain Explorer"
    NEXT_PUBLIC_APP_ENV="production"
  '';
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

      # Create the environment files at the source root during patching phase
      cp ${envFile} .env
      cp ${envFile} .env.production
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
      NEXT_TELEMETRY_DISABLED = "1";
      # Required for the build_sprite.sh script
      NEXT_PUBLIC_APP_ENV = "production";
    };

    preBuild = ''
      # Make sure public/assets directory exists
      mkdir -p ./public/assets

      # Run script to make environment variables script
      if [ -f ./deploy/scripts/make_envs_script.sh ]; then
        echo "Running make_envs_script.sh..."
        PATH="${lib.makeBinPath [ coreutils gnugrep gnused bash ]}:$PATH" \
        bash ./deploy/scripts/make_envs_script.sh ./public/assets/envs.js
      fi

      # Build SVG sprites if the script exists
      if [ -f ./deploy/scripts/build_sprite.sh ]; then
        echo "Running build_sprite.sh script..."
        # Make sure the target directory exists
        mkdir -p ./public/icons

        # Run the sprite generation script
        PATH="${lib.makeBinPath [ coreutils gnugrep gnused findutils jq ]}:$PATH" \
        bash ./deploy/scripts/build_sprite.sh
      fi
    '';

    # Fixed install phase to handle Next.js paths correctly
    installPhase = ''
      runHook preInstall

      # Create base output directory
      mkdir -p $out

      # Copy standalone directory contents (contains server.js and node_modules)
      cp -r .next/standalone/. $out/

      # Copy the .next directory to the output
      cp -r .next $out/

      # Create proper _next directory structure
      mkdir -p $out/_next/image
      mkdir -p $out/_next/data

      # Link all required Next.js static content
      ln -s $out/.next/static $out/_next/static

      # Ensure image optimization API has proper access to the Next.js build artifacts
      cp -r $out/.next/server $out/_next/server
      cp -r $out/.next/chunks $out/_next/chunks
      cp -r $out/.next/pages $out/_next/pages

      # Copy public directory (contains static assets like images, fonts, etc.)
      if [ -d public ]; then
        cp -r public $out/
      fi

      # Create a cache directory that can be written to
      mkdir -p $out/.next/cache
      chmod -R 777 $out/.next/cache

      # Create the executable script
      mkdir -p $out/bin

      # Create wrapper with dynamic loading of sprite hash
      makeWrapper ${nodejs}/bin/node $out/bin/blockscout-frontend \
        --add-flags "$out/server.js" \
        --set NEXT_TELEMETRY_DISABLED "1" \
        --set NODE_ENV "production" \
        --prefix PATH : "${lib.makeBinPath [ coreutils gnugrep gnused findutils jq ]}" \
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
