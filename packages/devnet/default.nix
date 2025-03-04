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
      genesis = ./genesis.json;
      config = ./interop.yaml;
      mnemonics = ./mnemonics.yaml;
      dora-config = ./dora-config.yaml;

      openssl = "${pkgs.openssl}/bin/openssl";

      geth = "${pkgs.go-ethereum}/bin/geth";
      lighthouse = "${pkgs.lighthouse}/bin/lighthouse";

      prysm_beacon = "${self'.packages.prysm}/bin/beacon-chain";
      prysm_validator = "${self'.packages.prysm}/bin/validator";
      prysm_ctl = "${self'.packages.prysm}/bin/prysmctl";

      eth2-testnet-genesis = "${self'.packages.eth2-testnet-genesis}/bin/eth2-testnet-genesis";
      jq = "${pkgs.jq}/bin/jq";

    in
    {
      process-compose."devnet" = {
        # We always create a tmp working directory
        cli.preHook = ''
          cd "$(mktemp -d)"

          EXECUTION_DIR="$PWD/execution"
          CONSENSUS_DIR="$PWD/consensus"
          JWT=$PWD/jwt.txt
          GETH_PASSWORD=$PWD/password.txt

          touch "$GETH_PASSWORD"

          ${openssl} rand -hex 32 > "$JWT"
          mkdir -p "$EXECUTION_DIR"
          mkdir -p "$CONSENSUS_DIR/beacon"
          mkdir -p "$CONSENSUS_DIR/validator"

          export JWT
          export GETH_PASSWORD
          export EXECUTION_DIR
          export CONSENSUS_DIR
        '';
        settings = {
          processes = {

            l1-genesis-init = {
              command = ''
                ${prysm_ctl} testnet generate-genesis \
                  --fork deneb \
                  --num-validators 192 \
                  --genesis-time-delay 0 \
                  --chain-config-file ${config} \
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
                  
                rm -rf $EXECUTION_DIR/genesis.out.json

                ${geth} init --datadir "$EXECUTION_DIR" $EXECUTION_DIR/genesis.edited.json

              '';
            };

            l1-el = {
              command = ''
                ${geth} \
                  --networkid 2345 \
                  --http \
                  --http.api=admin,eth,net,web3 \
                  --http.addr=127.0.0.1 \
                  --http.corsdomain="*" \
                  --http.port=8545 \
                  --metrics.port=8300 \
                  --authrpc.vhosts="*" \
                  --authrpc.addr=127.0.0.1 \
                  --authrpc.port=8551 \
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
                  --chain-config-file=${config} \
                  --minimal-config=true \
                  --contract-deployment-block=0 \
                  --chain-id=2345 \
                  --rpc-host=127.0.0.1 \
                  --rpc-port=4000 \
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
                  --beacon-rpc-provider="127.0.0.1:4000" \
                  --datadir=$CONSENSUS_DIR/validator \
                  --accept-terms-of-use \
                  --interop-num-validators 64 \
                  --interop-start-index 0 \
                  --rpc-port=7000 \
                  --chain-config-file=${config} \
                  --force-clear-db
              '';
              depends_on."l1-genesis-init".condition = "process_completed_successfully";
            };

            # l1-cl-beacon = {
            #   command = ''
            #     ${lighthouse} bn \
            #                   --datadir "$BEACON_DIR" \
            #                   --execution-endpoint "http://127.0.0.1:8551" \
            #                   --execution-jwt $JWT \
            #                   --dummy-eth1
            #   '';
            # };
          };
        };
      };
    };
}
