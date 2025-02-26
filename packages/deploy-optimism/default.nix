_:

{
  perSystem =
    {
      pkgs,
      lib,
      system,
      self',
      ...
    }:
    {
      packages =
        let

          usage_func_string = ''
            usage() {
              cat <<EOF
            Usage: ''${0##*/} [options]

            Options:
              --rpc-url URL             Specify the RPC URL
              --private-key KEY         Ethereum private key
              -o, --out-dir DIR         Output directory
              -h, --help                Show this help message and exit

            EOF
            }
          '';

          parse_args = ''
            OPTIONS=::o:h
            LONGOPTS=rpc-url:,private-key:,out-dir:,help

            TEMP=$(getopt -o "$OPTIONS" --long "$LONGOPTS" -n "''${0##*/}" -- "$@") || {
              usage
              exit 1
            }

            eval set -- "$TEMP"

            while true; do
              case "$1" in
                -r|--rpc-url)
                  RPC_URL="$2"
                  shift 2
                  ;;
                -k|--private-key)
                  PRIVATE_KEY="$2"
                  shift 2
                  ;;
                -o|--out-dir)
                  OUT_DIR="$2"
                  shift 2
                  ;;
                -h|--help)
                  usage
                  exit 0
                  ;;
                --)
                  shift
                  break
                  ;;
                *)
                  echo "Error: Unknown option '$1'" >&2
                  usage
                  exit 1
                  ;;
              esac
            done

            if [[ -z "$RPC_URL" ]]; then
              echo "Error: --rpc-url is required." >&2
              usage
              exit 1
            fi

            if [[ -z "$PRIVATE_KEY" ]]; then
              echo "Error: --private-key is required." >&2
              usage
              exit 1
            fi

          '';
        in
        {
          deploy-optimism = pkgs.writeShellScriptBin "deploy-optimism" ''
            RPC_URL=""
            PRIVATE_KEY=""
            OUT_DIR="$PWD/.optimism_deployment_$(date +"%Y%m%d_%H%M%S")"

            ${usage_func_string}
            ${parse_args}

            temp=$(mktemp -d)

            echo "Created working directory: $temp"

            cleanup() {
              unset IMPL_SALT
            }
            trap cleanup EXIT

            deploy_v130() {
              DIR=$temp/v1_3_0

              mkdir -p $DIR
              cp -r ${self'.packages.contracts-bedrock-v1_3_0}/share/* $DIR

              cd $DIR

              find "$DIR" -type d -exec chmod 755 {} +
              find "$DIR" -type f -exec chmod 644 {} +
              chown -R "$(id -u):$(id -g)" "$DIR"

              mkdir -p $DIR/deployments
              mkdir -p $DIR/deploy-config

              echo "Generating optimism configuration"
              
              ${self'.packages.op-config}/bin/op-config --rpc-url $RPC_URL > $DIR/config.json
              L1_CHAIN_ID=$(jq -r .l1ChainID $DIR/config.json)

              mkdir -p $OUT_DIR

              cp $DIR/config.json $OUT_DIR/config.json
              mv $DIR/config.json "$DIR/deploy-config/$L1_CHAIN_ID.json"

              export IMPL_SALT=$(openssl rand -hex 32)
              echo $IMPL_SALT > $OUT_DIR/salt

              echo "Deploying Optimism L1 contracts"                
              ${pkgs.foundry}/bin/forge script scripts/Deploy.s.sol:Deploy --broadcast --non-interactive --private-key $PRIVATE_KEY --rpc-url $L1_RPC_URL -vvvvv

              cp $DIR/deployments/$L1_CHAIN_ID/.deploy $OUT_DIR/l1_addresses.json

              echo "Deployed L1 contracts successfully"
              echo "working dir: $DIR"
              echo "outputs written to: $OUT_DIR"
            }

            deploy_v130
          '';
        };
    };
}
