{inputs, ...}: {
  imports = [inputs.process-compose.flakeModule];
  perSystem = {
    self',
    pkgs,
    lib,
    ...
  }: let
    inherit (import ./accounts.nix) accounts;

    # utils
    openssl = lib.getExe pkgs.openssl;
    jq = lib.getExe pkgs.jq;
    # cast = "${pkgs.foundry}/bin/cast";

    #L1
    geth = lib.getExe pkgs.go-ethereum;
    prysm-beacon = lib.getExe self'.packages.prysm;
    prysm-ctl = "${self'.packages.prysm}/bin/prysmctl";
    prysm-validator = "${self'.packages.prysm}/bin/validator";

    # L2

    probe = lib.getExe self'.packages.probe;
    # withdrawer = "${inputs.withdrawer.packages.${pkgs.system}.default}";

    configs = pkgs.callPackage ./configs {};

    # op-deployer-init = "${scripts.op-deployer-init}/bin/op-deployer-init";

    # explorers
    dora = lib.getExe self'.packages.dora;
    blockscout = lib.getExe self'.packages.blockscout;

    L1_CHAIN_ID = "2345";

    # L1 specific config options
    GETH_HTTP_PORT = "8545";
    GETH_WS_PORT = "8546";
    GETH_AUTH_PORT = "8551";
    GETH_METRICS_PORT = "8300";
    BEACON_HTTP_PORT = "4000";
    BEACON_RPC_PORT = "4001";
    DORA_HTTP_PORT = "8082";
    VALIDATOR_HTTP_PORT = "7000";

    # OP-specific ports
    SEEDER_ACCOUNT = lib.elemAt accounts 1;

    NUM_VALIDATORS = "64";
    GENESIS_TIME_DELAY = "0";

    dora-config = configs.mkDoraConfig {
      port = DORA_HTTP_PORT;
      consensus-url = "http://localhost:${BEACON_HTTP_PORT}";
      execution-url = "http://localhost:${GETH_HTTP_PORT}";
    };

    genesis = configs.mkGenesis {
      chainId = L1_CHAIN_ID;
      inherit accounts;
      balance = "0xd3c21bcecceda1000000";
    };
    chain-config = configs.mkChainConfig {};
  in {
    process-compose."devnet" = {
      cli.options.port = 5656;
      # We always create a tmp working directory
      cli.preHook = ''
        PROJECT_DIR="$PWD"
        cd "$(mktemp -d)"

        DEVNET_SYMLINK="$PROJECT_DIR/.devnet"
        if [ -L "$DEVNET_SYMLINK" ] && [ -d "$DEVNET_SYMLINK" ]; then
            rm "$DEVNET_SYMLINK"
        fi
        ln -s "$PWD" "$DEVNET_SYMLINK"

        EXECUTION_DIR="$PWD/execution"
        CONSENSUS_DIR="$PWD/consensus"
        DORA_DIR="$PWD/dora"
        POSTGRES_DIR="$PWD/postgres"
        OP_DIR="$PWD/op"
        OP_DEPLOYER_DIR="$OP_DIR/deployer"

        mkdir -p "$EXECUTION_DIR"
        mkdir -p "$CONSENSUS_DIR/{beacon,validator}"
        mkdir -p "$DORA_DIR"
        mkdir -p "$OP_DEPLOYER_DIR"

        L1_JWT=$PWD/l1-jwt.txt
        L2_JWT=$PWD/l2-jwt.txt
        GETH_PASSWORD=$PWD/password.txt

        touch "$GETH_PASSWORD"

        ${openssl} rand -hex 32 > "$L1_JWT"
        ${openssl} rand -hex 32 > "$L2_JWT"

        DORA_CONFIG_PATH="$DORA_DIR/config.yaml"
        cp ${dora-config} "$DORA_CONFIG_PATH"

        POSTGRES_DIR="$PWD/postgres"
        mkdir -p "$POSTGRES_DIR"

        OP_GENESIS_CONFIG="$OP_DEPLOYER_DIR/genesis.json"
        OP_L1_ADDRESSES_FILE="$OP_DEPLOYER_DIR/l1_addresses.json"
        OP_IMPLEMENTATIONS_CONFIG="$OP_DEPLOYER_DIR/implementations.json"
        OP_STATE_CONFIG="$OP_DEPLOYER_DIR/state.json"
        OP_ROLLUP_CONFIG="$OP_DEPLOYER_DIR/rollup.json"
        OP_GETH_DIR="$OP_DIR/op-geth"

        export L1_JWT
        export L2_JWT
        export GETH_PASSWORD
        export EXECUTION_DIR
        export CONSENSUS_DIR
        export DORA_DIR
        export DORA_CONFIG_PATH
        export OP_DIR
        export OP_DEPLOYER_DIR
        export OP_GENESIS_CONFIG
        export OP_ROLLUP_CONFIG
        export OP_GETH_DIR
        export OP_IMPLEMENTATIONS_CONFIG
        export OP_STATE_CONFIG
        export OP_L1_ADDRESSES_FILE
        export POSTGRES_DIR
        export DEVNET_SYMLINK
      '';
      cli.postHook = ''
        unlink "$DEVNET_SYMLINK"
      '';

      settings = {
        processes = {
          # L1
          l1-init = {
            command = ''
              cat ${genesis}
              ${jq} -r '.' ${genesis}
              ${prysm-ctl} testnet generate-genesis \
                --fork deneb \
                --num-validators ${NUM_VALIDATORS} \
                --genesis-time-delay ${GENESIS_TIME_DELAY} \
                --chain-config-file ${chain-config} \
                --geth-genesis-json-in ${genesis} \
                --geth-genesis-json-out "$EXECUTION_DIR/genesis.out.json" \
                --output-ssz "$CONSENSUS_DIR/genesis.ssz"

              ${jq} '.config.blobSchedule = {
                "cancun": {
                  "target": 3,
                  "max": 6,
                  "baseFeeUpdateFraction": 3338477
                }
              }' "$EXECUTION_DIR/genesis.out.json" > "$EXECUTION_DIR/genesis.edited.json"

              ${geth} init \
                --state.scheme=hash \
                --datadir "$EXECUTION_DIR" \
                $EXECUTION_DIR/genesis.edited.json

              echo "$PWD"
            '';
            shutdown.signal = 9;
          };
          l1-el = {
            command = ''
              ${geth} \
                --networkid ${L1_CHAIN_ID}\
                --http \
                --http.api=admin,eth,net,debug,web3 \
                --http.addr=127.0.0.1 \
                --http.corsdomain="*" \
                --http.port=${GETH_HTTP_PORT} \
                --ws \
                --ws.addr=127.0.0.1 \
                --ws.port=${GETH_WS_PORT} \
                --ws.api=admin,eth,net,debug,web3 \
                --metrics.port=${GETH_METRICS_PORT} \
                --authrpc.vhosts="*" \
                --authrpc.addr=127.0.0.1 \
                --authrpc.port=${GETH_AUTH_PORT} \
                --authrpc.jwtsecret=$L1_JWT \
                --datadir "$EXECUTION_DIR" \
                --syncmode=full \
                --gcmode=archive \
                --nodiscover \
                --maxpeers 0 \
                --verbosity 5 \
                --allow-insecure-unlock \
                --password $GETH_PASSWORD
            '';
            shutdown.signal = 9;
            depends_on."l1-init".condition = "process_completed_successfully";
          };
          l1-cl-beacon = {
            command = ''
              ${prysm-beacon} \
                --datadir="$CONSENSUS_DIR/beacon" \
                --min-sync-peers=0 \
                --genesis-state="$CONSENSUS_DIR/genesis.ssz" \
                --interop-eth1data-votes \
                --chain-config-file=${chain-config} \
                --minimal-config=true \
                --contract-deployment-block=0 \
                --chain-id=${L1_CHAIN_ID} \
                --rpc-host=127.0.0.1 \
                --rpc-port=${BEACON_RPC_PORT} \
                --http-port=${BEACON_HTTP_PORT} \
                --execution-endpoint=$EXECUTION_DIR/geth.ipc \
                --accept-terms-of-use \
                --jwt-secret=$L1_JWT \
                --force-clear-db \
                --suggested-fee-recipient=0x123463a4b065722e99115d6c222f267d9cabb524 \
                --minimum-peers-per-subnet=0 \
                --verbosity=info
            '';
            shutdown.signal = 9;
            depends_on."l1-init".condition = "process_completed_successfully";
          };
          l1-cl-validator = {
            command = ''
              ${prysm-validator} \
                --beacon-rpc-provider="127.0.0.1:${BEACON_RPC_PORT}" \
                --datadir=$CONSENSUS_DIR/validator \
                --accept-terms-of-use \
                --interop-num-validators ${NUM_VALIDATORS} \
                --interop-start-index 0 \
                --rpc-port=${VALIDATOR_HTTP_PORT} \
                --chain-config-file=${chain-config} \
                --force-clear-db
            '';
            shutdown.signal = 9;
            depends_on."l1-init".condition = "process_completed_successfully";
          };
          l1-check = {
            command = ''
              ${probe} sendOnReady \
                --rpc-url=http://127.0.0.1:${GETH_HTTP_PORT} \
                --private-key ${SEEDER_ACCOUNT.private-key} \
                --value=$(cast 2w 1)
            '';
            shutdown.signal = 9;
            depends_on."l1-init".condition = "process_completed_successfully";
          };

          # L2
          # l2-deploy = {
          #   command = ''
          #     ${deploy-optimism} \
          #       --rpc-url http://localhost:${GETH_HTTP_PORT} \
          #       --private-key ${DEPLOYER_ACCOUNT.private-key} \
          #       --l1-chain-id ${L1_CHAIN_ID} \
          #       --l2-chain-id ${L2_CHAIN_ID} \
          #       --work-dir $OP_DEPLOYER_DIR \
          #       --superchain-proxy-admin-owner ${SUPERCHAIN_PROXY_ADMIN_OWNER.address} \
          #       --protocol-versions-owner ${PROTOCOL_VERSIONS_OWNER.address} \
          #       --guardian ${GUARDIAN.address} \
          #       --l1-fee-vault-recipient ${L1_FEE_VAULT_RECIPIENT.address} \
          #       --base-fee-vault-recipient ${BASE_FEE_VAULT_RECIPIENT.address} \
          #       --sequencer-fee-vault-recipient ${SEQUENCER_FEE_VAULT_RECIPIENT.address} \
          #       --l1-proxy-admin-owner ${L1_PROXY_ADMIN_OWNER.address} \
          #       --l2-proxy-admin-owner ${L2_PROXY_ADMIN_OWNER.address} \
          #       --system-config-owner ${SYSTEM_CONFIG_OWNER.address} \
          #       --unsafe-block-signer ${UNSAFE_BLOCK_SIGNER.address} \
          #       --upgrade-controller ${UPGRADE_CONTROLLER.address} \
          #       --batcher ${BATCHER.address} \
          #       --challenger ${CHALLENGER.address} \
          #       --sequencer ${SEQUENCER.address} \
          #       --proposer ${PROPOSER.address}
          #   '';
          #   shutdown.signal = 9;
          #   depends_on."l1-check".condition = "process_completed_successfully";
          # };

          # l2-init = {
          #   command = ''
          #     ${op-geth} init \
          #       --state.scheme=hash \
          #       --datadir "$OP_GETH_DIR" \
          #       $OP_GENESIS_CONFIG
          #   '';
          #   shutdown.signal = 9;
          #   depends_on."l2-deploy".condition = "process_completed_successfully";
          # };

          # l2-el = {
          #   command = ''
          #     ${op-geth} \
          #       --networkid ${L2_CHAIN_ID} \
          #       --datadir="$OP_GETH_DIR" \
          #       --http \
          #       --http.corsdomain="*" \
          #       --http.vhosts="*" \
          #       --http.addr=127.0.0.1 \
          #       --http.port=${OP_GETH_HTTP_PORT} \
          #       --http.api=web3,debug,eth,txpool,net,engine \
          #       --ws \
          #       --ws.addr=127.0.0.1 \
          #       --ws.port=${OP_GETH_WS_PORT} \
          #       --ws.origins="*" \
          #       --ws.api=admin,debug,eth,txpool,net,engine,web3 \
          #       --nodiscover \
          #       --maxpeers=0 \
          #       --syncmode=full \
          #       --gcmode=archive \
          #       --authrpc.vhosts="*" \
          #       --authrpc.addr=127.0.0.1 \
          #       --authrpc.port=${OP_GETH_AUTH_PORT} \
          #       --authrpc.jwtsecret=$L2_JWT \
          #       --rollup.disabletxpoolgossip=true \
          #       --port=${OP_GETH_DISCOVERY_PORT} \
          #       --db.engine=pebble \
          #       --state.scheme=hash
          #   '';
          #   shutdown.signal = 9;
          #   depends_on."l2-init".condition = "process_completed_successfully";
          # };

          # l2-cl-sequencer = {
          #   command = ''
          #     ${op-node} \
          #       --l1=http://127.0.0.1:${GETH_HTTP_PORT} \
          #       --l1.beacon=http://127.0.0.1:${BEACON_HTTP_PORT} \
          #       --l1.trustrpc \
          #       --l1.rpckind=debug_geth \
          #       --l2=http://127.0.0.1:${OP_GETH_AUTH_PORT} \
          #       --l2.jwt-secret=$L2_JWT \
          #       --l2.enginekind=geth \
          #       --rpc.addr=127.0.0.1 \
          #       --rpc.port=${OP_NODE_RPC_PORT} \
          #       --rpc.enable-admin \
          #       --syncmode=consensus-layer \
          #       --sequencer.enabled \
          #       --sequencer.l1-confs=5 \
          #       --verifier.l1-confs=4 \
          #       --rollup.config=$OP_ROLLUP_CONFIG \
          #       --rollup.load-protocol-versions=true \
          #       --p2p.disable
          #   '';
          #   shutdown.signal = 9;
          #   depends_on."l2-init".condition = "process_completed_successfully";
          # };

          # l2-cl-batcher = {
          #   command = ''
          #     ${op-batcher} \
          #       --l1-eth-rpc=http://127.0.0.1:${GETH_HTTP_PORT} \
          #       --l2-eth-rpc=http://127.0.0.1:${OP_GETH_HTTP_PORT} \
          #       --rollup-rpc=http://127.0.0.1:${OP_NODE_RPC_PORT} \
          #       --poll-interval=1s \
          #       --data-availability-type=blobs \
          #       --sub-safety-margin=6 \
          #       --num-confirmations=1 \
          #       --safe-abort-nonce-too-low-count=3 \
          #       --resubmission-timeout=30s \
          #       --rpc.addr=127.0.0.1 \
          #       --rpc.port=${OP_BATCHER_RPC_PORT} \
          #       --rpc.enable-admin \
          #       --max-channel-duration=5 \
          #       --private-key=${BATCHER.private-key} \
          #       --wait-node-sync \
          #       --throttle-threshold=0
          #   '';
          #   shutdown.signal = 9;
          #   depends_on."l2-init".condition = "process_completed_successfully";
          # };
          # l2-cl-proposer = {
          #   # `--allow-non-finalized=true` will shorten the amount of time it takes until proposals are made as it will
          #   # eagerly observe for batch submissions on unfinalized L1 blocks. When set to false it waits until those
          #   # blocks are finalized before making proposals to them which is approx 2 epochs
          #   command = ''
          #     ${op-proposer} \
          #       --allow-non-finalized=true \
          #       --poll-interval=12s \
          #       --rpc.port=${OP_PROPOSER_RPC_PORT} \
          #       --rollup-rpc=http://127.0.0.1:${OP_NODE_RPC_PORT} \
          #       --game-factory-address="$(${jq} -r ".opChainDeployments.[0].disputeGameFactoryProxyAddress" $OP_STATE_CONFIG)" \
          #       --game-type 1 \
          #       --proposal-interval=10s \
          #       --private-key=${PROPOSER.private-key} \
          #       --l1-eth-rpc=http://127.0.0.1:${GETH_HTTP_PORT}
          #   '';
          #   shutdown.signal = 9;
          #   depends_on."l2-init".condition = "process_completed_successfully";
          # };
          # l2-check = {
          #   command = ''
          #     ${probe} bridgeEthAndFinalize \
          #       --private-key=${USER_ACCOUNT.private-key} \
          #       --l1-rpc-url=http://127.0.0.1:${GETH_HTTP_PORT} \
          #       --l2-rpc-url=http://127.0.0.1:${OP_GETH_HTTP_PORT} \
          #       --optimism-portal-address=$(${jq} -r ".opChainDeployments.[0].optimismPortalProxyAddress" $OP_STATE_CONFIG) \
          #       --l1-standard-bridge-address=$(${jq} -r ".opChainDeployments.[0].l1StandardBridgeProxyAddress" $OP_STATE_CONFIG) \
          #       --l2-standard-bridge-address="0x4200000000000000000000000000000000000010" \
          #       --value=$(cast 2w 10000)
          #   '';
          #   shutdown.signal = 9;
          #   depends_on."l2-init".condition = "process_completed_successfully";
          # };

          # misc
          dora = {
            command = ''
              cd "$DORA_DIR"
              ${dora} -config "$DORA_CONFIG_PATH"
            '';
            depends_on."l1-check".condition = "process_completed_successfully";
            shutdown.signal = 9;
          };
          blockscout = {
            command = let
              # Create a wrapper script that sets up everything
              blockscoutEnvScript = pkgs.writeShellScript "blockscout-env.sh" ''
                # Create a temporary directory for our configuration
                export TEMP_CONFIG_DIR=$(mktemp -d)
                trap 'rm -rf "$TEMP_CONFIG_DIR"' EXIT

                # Create directory structure
                mkdir -p "$TEMP_CONFIG_DIR/config/runtime"
                mkdir -p "$TEMP_CONFIG_DIR/tzdata"

                # Copy config_helper.exs if it exists
                cp -r "${self'.packages.blockscout}/apps" "$TEMP_CONFIG_DIR/apps"
                cp "${self'.packages.blockscout}/config/runtime/prod.exs" "$TEMP_CONFIG_DIR/config/runtime/prod.exs"
                cp "${self'.packages.blockscout}/config/config.exs" "$TEMP_CONFIG_DIR/config/config.exs"
                cp "${self'.packages.blockscout}/config/config_helper.exs" "$TEMP_CONFIG_DIR/config/config_helper.exs"

                # Create required data directories
                mkdir -p dets temp

                # Change to the temp directory so relative paths work
                cd "$TEMP_CONFIG_DIR"

                # Database Configuration - explicit database settings
                export DATABASE_URL="postgresql://blockscout:blockscout@localhost:5432/blockscout?sslmode=disable"

                # Ethereum JSON RPC Configuration
                export ETHEREUM_JSONRPC_VARIANT=geth
                export ETHEREUM_JSONRPC_HTTP_URL="http://localhost:${GETH_HTTP_PORT}"
                export ETHEREUM_JSONRPC_TRACE_URL="http://localhost:${GETH_HTTP_PORT}"
                export ETHEREUM_JSONRPC_WS_URL="ws://localhost:${GETH_WS_PORT}"

                # Set tzdata directory to a writable location
                export TZDATA_DIR="$TEMP_CONFIG_DIR/tzdata"

                # SSL Configuration
                export ECTO_USE_SSL=false

                # Basic Configuration
                export BLOCKSCOUT_PROTOCOL="http"
                export BLOCKSCOUT_HOST="localhost"
                export PORT="4040"
                export SECRET_KEY_BASE="56NtB48ear7+wMSf0IQuWDAAazhpb31qyc7GiyspBP2vh7t5zlCsF5QDv76chXeN"

                # Chain Configuration
                export CHAIN_ID=${L1_CHAIN_ID}
                export SUBNETWORK="Local Testnet"
                export NETWORK="L1"
                export CHAIN_TYPE="ethereum"

                # Runtime Behavior Configuration
                export ACCOUNT_ENABLED=false
                export ADMIN_PANEL_ENABLED=true
                export API_V1_READ_METHODS_DISABLED=false
                export API_V1_WRITE_METHODS_DISABLED=false
                export DISABLE_EXCHANGE_RATES=true
                export DISABLE_INDEXER=false
                export DISABLE_WEBAPP=false
                export MUD_INDEXER_ENABLED=false
                export NFT_MEDIA_HANDLER_ENABLED=false

                export INDEXER_DISABLE_BEACON_BLOB_FETCHER=true
                export INDEXER_BEACON_RPC_URL=http://localhost:${BEACON_HTTP_PORT}
                export INDEXER_CATCHUP_BLOCKS_BATCH_SIZE=10
                export INDEXER_CATCHUP_BLOCKS_CONCURRENCY=10

                # Set RELEASE_COOKIE if not already set
                export RELEASE_COOKIE=''${RELEASE_COOKIE:-"blockscout-cookie"}

                # Set RUNTIME_CONFIG=true to ensure it reads the runtime config
                export RUNTIME_CONFIG=true

                # Export config directory location so Blockscout can find it
                export RELEASE_CONFIG_DIR="$TEMP_CONFIG_DIR/config"

                export SHOW_SENSITIVE_DATA_ON_CONNECTION_ERROR=true

                # Run the command that was passed to this script
                exec "$@"
              '';
            in ''
              echo "Starting database migration..."
              ${blockscoutEnvScript} ${blockscout} eval "Elixir.Explorer.ReleaseTasks.create_and_migrate()"

              echo "Starting Blockscout..."
             ${blockscoutEnvScript} ${blockscout} start
            '';
            depends_on."postgres".condition = "process_healthy";
            shutdown.signal = 9;
            log_location = "/home/aldo/Dev/numtide/golem/op.nix/logs.txt";
          };

          postgres = {
            command = pkgs.writeShellScriptBin "postgres" ''
              # Initialize database directory
              ${lib.getExe' pkgs.postgresql "initdb"} \
                  -D "$POSTGRES_DIR/data" \
                  --username=blockscout \
                  --pwfile=<(echo "blockscout") \
                  --auth=trust \
                  --encoding=UTF8 \
                  --data-checksums

              # Start postgres server temporarily for setup
              ${lib.getExe' pkgs.postgresql "pg_ctl"} \
                  -D "$POSTGRES_DIR/data" \
                  -o "-k $POSTGRES_DIR/data -h 127.0.0.1 -p 5432" \
                  -w start

              # Common psql parameters
              PSQL_COMMON="-h 127.0.0.1 -p 5432 -U blockscout"

              # Create databases
              for DB in blockscout blockscout_account blockscout_api blockscout_mud; do
                ${lib.getExe' pkgs.postgresql "createdb"} $PSQL_COMMON $DB

                # Grant superuser privileges to all databases
                ${lib.getExe' pkgs.postgresql "psql"} $PSQL_COMMON -d $DB \
                    -c "ALTER USER blockscout WITH SUPERUSER;"
              done

              # Stop temporary server
              ${lib.getExe' pkgs.postgresql "pg_ctl"} \
                  -D "$POSTGRES_DIR/data" stop

              # Start postgres with final configuration
              ${lib.getExe' pkgs.postgresql "postgres"} \
                  -D "$POSTGRES_DIR/data" \
                  -k "$POSTGRES_DIR/data" \
                  -c max_connections=200 \
                  -c client_connection_check_interval=60000 \
                  -c listen_addresses='127.0.0.1' \
                  -c port=5432
            '';
            readiness_probe = {
              exec = {
                command = ''
                  ${lib.getExe' pkgs.postgresql "pg_isready"} -U blockscout -d blockscout -h localhost -p 5432;
                '';
              };
              initial_delay_seconds = 5;
              period_seconds = 10;
              timeout_seconds = 5;
              success_threshold = 1;
              failure_threshold = 5;
            };
          };

          pgweb = {
            command = ''
              ${lib.getExe pkgs.pgweb} \
                --host=localhost \
                --port=5432 \
                --user=blockscout \
                --pass=blockscout \
                --db=blockscout \
                --listen=8585 \
                --bind=0.0.0.0
            '';
            depends_on."postgres".condition = "process_healthy";
            readiness_probe = {
              http_get = {
                host = "localhost";
                port = 8585;
                path = "/";
              };
              initial_delay_seconds = 5;
              period_seconds = 10;
              timeout_seconds = 2;
              success_threshold = 1;
              failure_threshold = 3;
            };
          };
        };
      };
    };
  };
}
