{ inputs, ... }:

{
  imports = [ inputs.process-compose.flakeModule ];
  perSystem =
    {
      pkgs,
      lib,
      system,
      self',
      ...
    }:
    let

      configs = import ./configs { inherit pkgs; };

      openssl = "${pkgs.openssl}/bin/openssl";
      geth = "${pkgs.go-ethereum}/bin/geth";
      prysm_beacon = "${self'.packages.prysm}/bin/beacon-chain";
      prysm_validator = "${self'.packages.prysm}/bin/validator";
      prysm_ctl = "${self'.packages.prysm}/bin/prysmctl";
      dora = "${self'.packages.dora}/bin/dora-explorer";
      jq = "${pkgs.jq}/bin/jq";

      CHAIN_ID = "2345";
      GETH_HTTP_PORT = "8545";
      GETH_AUTH_PORT = "8551";
      GETH_METRICS_PORT = "8300";
      BEACON_HTTP_PORT = "4000";
      BEACON_RPC_PORT = "4001";
      DORA_HTTP_PORT = "8082";

      NUM_VALIDATORS = "64";
      GENESIS_TIME_DELAY = "0";

      dora-config = configs.mkDoraConfig {
        port = DORA_HTTP_PORT;
        consensus-url = "http://localhost:${BEACON_HTTP_PORT}";
        execution-url = "http://localhost:${GETH_HTTP_PORT}";
      };

      genesis = configs.mkGenesis {
        chainId = CHAIN_ID;
        address = "0x35Ec8a72D8e218C252EaE18044b0cBb97c1e57bF";
        balance = "0x43c33c1937564800000"; # 2 ETH
      };
      chain-config = configs.mkChainConfig { };
    in
    {
      process-compose."devnet" = {
        # We always create a tmp working directory
        cli.preHook = ''
          cd "$(mktemp -d)"

          EXECUTION_DIR="$PWD/execution"
          CONSENSUS_DIR="$PWD/consensus"
          DORA_DIR="$PWD/dora"
          DORA_CONFIG_PATH="$DORA_DIR/config.yaml"

          JWT=$PWD/jwt.txt
          GETH_PASSWORD=$PWD/password.txt

          touch "$GETH_PASSWORD"

          ${openssl} rand -hex 32 > "$JWT"

          mkdir -p "$EXECUTION_DIR"
          mkdir -p "$CONSENSUS_DIR/beacon"
          mkdir -p "$CONSENSUS_DIR/validator"
          mkdir -p "$DORA_DIR"

          cp ${dora-config} "$DORA_CONFIG_PATH"

          export JWT
          export GETH_PASSWORD
          export EXECUTION_DIR
          export CONSENSUS_DIR
          export DORA_DIR
          export DORA_CONFIG_PATH
        '';

        settings = {
          processes = {
            l1-genesis-init = {
              command = ''
                ${prysm_ctl} testnet generate-genesis \
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
                  
                ${geth} init --datadir "$EXECUTION_DIR" $EXECUTION_DIR/genesis.edited.json

                echo "$PWD"
              '';
            };

            l1-el = {
              command = ''
                ${geth} \
                  --networkid ${CHAIN_ID}\
                  --http \
                  --http.api=admin,eth,net,web3 \
                  --http.addr=127.0.0.1 \
                  --http.corsdomain="*" \
                  --http.port=${GETH_HTTP_PORT} \
                  --metrics.port=${GETH_METRICS_PORT} \
                  --authrpc.vhosts="*" \
                  --authrpc.addr=127.0.0.1 \
                  --authrpc.port=${GETH_AUTH_PORT} \
                  --authrpc.jwtsecret=$JWT \
                  --datadir "$EXECUTION_DIR" \
                  --syncmode 'full' \
                  --nodiscover \
                  --maxpeers 0 \
                  --verbosity 5 \
                  --allow-insecure-unlock \
                  --password $GETH_PASSWORD
              '';
              depends_on."l1-genesis-init".condition = "process_completed_successfully";
            };

            l1-beacon = {
              command = ''
                ${prysm_beacon} \
                  --datadir="$CONSENSUS_DIR/beacon" \
                  --min-sync-peers=0 \
                  --genesis-state="$CONSENSUS_DIR/genesis.ssz" \
                  --interop-eth1data-votes \
                  --chain-config-file=${chain-config} \
                  --minimal-config=true \
                  --contract-deployment-block=0 \
                  --chain-id=${CHAIN_ID} \
                  --rpc-host=127.0.0.1 \
                  --rpc-port=${BEACON_RPC_PORT} \
                  --http-port=${BEACON_HTTP_PORT} \
                  --execution-endpoint=$EXECUTION_DIR/geth.ipc \
                  --accept-terms-of-use \
                  --jwt-secret=$JWT \
                  --force-clear-db \
                  --suggested-fee-recipient=0x123463a4b065722e99115d6c222f267d9cabb524 \
                  --minimum-peers-per-subnet=0 \
                  --verbosity=info
              '';
              depends_on."l1-genesis-init".condition = "process_completed_successfully";
            };

            l1-validator = {
              command = ''
                ${prysm_validator} \
                  --beacon-rpc-provider="127.0.0.1:${BEACON_RPC_PORT}" \
                  --datadir=$CONSENSUS_DIR/validator \
                  --accept-terms-of-use \
                  --interop-num-validators ${NUM_VALIDATORS} \
                  --interop-start-index 0 \
                  --rpc-port=7000 \
                  --chain-config-file=${chain-config} \
                  --force-clear-db
              '';
              depends_on."l1-genesis-init".condition = "process_completed_successfully";
            };
            dora = {
              command = ''
                sleep 10
                cd "$DORA_DIR"
                ${dora} -config "$DORA_CONFIG_PATH"
              '';
              depends_on."l1-genesis-init".condition = "process_completed_successfully";
            };
          };
        };
      };
    };
}
