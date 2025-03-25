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
    ];

    # Skip removing dev dependencies - Next.js needs them for proper builds
    yarnKeepDevDeps = true;

    yarnBuildScript = "build";

    env = {
      NODE_ENV = "production";
    };

    # Override the default install phase to handle Next.js specific files
    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib/node_modules/${finalAttrs.pname}

      # Copy necessary files for Next.js app
      cp -r .next package.json public $out/lib/node_modules/${finalAttrs.pname}/

      # If standalone directory exists, make sure to include it
      if [ -d .next/standalone ]; then
        mkdir -p $out/lib/node_modules/${finalAttrs.pname}/.next
        cp -r .next/standalone $out/lib/node_modules/${finalAttrs.pname}/.next/
      fi

      # Create the executable
      mkdir -p $out/bin
      makeWrapper ${nodejs}/bin/node $out/bin/blockscout-frontend \
        --add-flags "$out/lib/node_modules/${finalAttrs.pname}/.next/standalone/server.js"

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
