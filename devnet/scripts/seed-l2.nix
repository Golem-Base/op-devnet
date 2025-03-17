{pkgs, ...} @ args: let
  cast = "${pkgs.foundry}/bin/cast";
  jq = "${pkgs.jq}/bin/jq";
  withdrawer = "${args.withdrawer}/bin/withdrawer";
in
  pkgs.writeShellScriptBin "seed-l2" ''
    set -euo pipefail

    PRIVATE_KEY=$1
    L1_RPC_URL=$2
    L2_RPC_URL=$3
    L2_NODE_RPC_URL=$4
    L1_STANDARD_BRIDGE_PROXY_ADDRESS=$5
    OPTIMISM_PORTAL_PROXY_ADDRESS=$6
    DISPUTE_GAME_FACTORY_PROXY_ADDRESS=$7
    DEPOSIT_AMOUNT=$8
    WITHDRAWAL_AMOUNT=$9

    L2_STANDARD_BRIDGE_ADDRESS=0x4200000000000000000000000000000000000010

    ADDRESS=$(cast wallet address --private-key $PRIVATE_KEY)

    echo "Checking initial L2 balance for: $ADDRESS"
    INITIAL_L2_BALANCE=$(cast balance $ADDRESS --rpc-url=$L2_RPC_URL)
    echo "Balance for $ADDRESS: $(cast fw $INITIAL_L2_BALANCE)"

    echo "Depositing $DEPOSIT_AMOUNT to L2 via bridge..."

    ${cast} send $L1_STANDARD_BRIDGE_PROXY_ADDRESS \
      --value $DEPOSIT_AMOUNT \
      --private-key $PRIVATE_KEY \
      --rpc-url $L1_RPC_URL \
      --priority-gas-price 15gwei \
      --gas-price 100gwei

    echo "Deposit transaction executed successfully..."

    TIMEOUT=300
    SLEEP_INTERVAL=1
    START_TIME=$(date +%s)

    echo "Polling for L2 balance to increase..."
    while true; do
      CURRENT_L2_BALANCE=$(cast balance "$ADDRESS" --rpc-url="$L2_RPC_URL")

      # Check if the balance has increased
      if [ "$CURRENT_L2_BALANCE" -gt "$INITIAL_L2_BALANCE" ]; then
        echo "Balance increased on L2. New balance: $(cast fw "$CURRENT_L2_BALANCE")"
        echo "Deposit confirmed!"
        break
      fi

      NOW=$(date +%s)
      if (( NOW - START_TIME >= TIMEOUT )); then
        echo "Timed out after $TIMEOUT seconds. Balance has not increased yet."
        exit 1
      fi

      echo "Balance has not increased yet. Current: $(cast fw "$CURRENT_L2_BALANCE")"
      echo "Sleeping for $SLEEP_INTERVAL seconds..."
      sleep "$SLEEP_INTERVAL"
    done

    echo "Making initial withdrawal from L2 to L1"
    WITHDRAWAL_JSON=$(cast send $L2_STANDARD_BRIDGE_ADDRESS \
      --value=$WITHDRAWAL_AMOUNT \
      --private-key=$PRIVATE_KEY \
      --rpc-url=$L2_RPC_URL \
      --json)

    WITHDRAWAL_TRANSACTION_HASH=$(${jq} ".transactionHash" <<< $WITHDRAWAL_JSON)
    WITHDRAWAL_TRANSACTION_BLOCK=$(${jq} ".blockNumber" <<< $WITHDRAWAL_JSON | cast to-dec)
    echo "Made initital withdrawal transaction: $WITHDRAWAL_TRANSACTION_HASH, block: $WITHDRAWAL_TRANSACTION_BLOCK"

    # We need to poll here until we know that the withdrawal transaction has been published
    # batcher makes a submission every 5 blocks, 10 seconds
    # proposer makes a proposal every 10s,
    # We might get away by waiting for the l2 safe head being greater than the transaction block number, indicating the
    # transaction was mined
    # echo "sleeping for 30 seconds waiting for batcher and proposer to propogate the tx to L1 so that it can be proved"
    # sleep 30

    L2_SAFE_BLOCK=$(curl -X POST -H "Content-Type: application/json" --data \
        '{"jsonrpc":"2.0","method":"optimism_syncStatus","params":[],"id":1}'  \
        $L2_NODE_RPC_URL | jq ".result.safe_l2.number")
    echo "Current l2_safe_block: $L2_SAFE_BLOCK"
    while (( L2_SAFE_BLOCK < WITHDRAWAL_TRANSACTION_BLOCK )); do
      echo "Current l2_safe_block: $L2_SAFE_BLOCK less than withdrawal block: $WITHDRAWAL_TRANSACTION_BLOCK, sleeping 10s..."
      sleep 10
      L2_SAFE_BLOCK=$(curl -X POST -H "Content-Type: application/json" --data \
          '{"jsonrpc":"2.0","method":"optimism_syncStatus","params":[],"id":1}'  \
          $L2_NODE_RPC_URL | jq ".result.safe_l2.number")
    done

    echo "Proving withdrawal transaction: $WITHDRAWAL_TRANSACTION_HASH"
    ${withdrawer} \
      --rpc=$L1_RPC_URL \
      --l2-rpc=$L2_RPC_URL \
      --private-key=$PRIVATE_KEY \
      --withdrawal=$WITHDRAWAL_TRANSACTION_HASH \
      --portal-address=$OPTIMISM_PORTAL_PROXY_ADDRESS \
      --dgf-address=$DISPUTE_GAME_FACTORY_PROXY_ADDRESS \
      --fault-proofs

  ''
