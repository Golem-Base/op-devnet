{pkgs}: let
  cast = "${pkgs.foundry}/bin/cast";
in
  pkgs.writeShellScriptBin "seed-l2" ''
    set -euo pipefail

    PRIVATE_KEY=$1
    L1_RPC_URL=$2
    L2_RPC_URL=$3
    L1_STANDARD_BRIDGE_PROXY_ADDRESS=$4
    AMOUNT=$5

    ADDRESS=$(cast wallet address --private-key $PRIVATE_KEY)

    echo "Checking initial L2 balance for: $ADDRESS"
    INITIAL_L2_BALANCE=$(cast balance $ADDRESS --rpc-url=$L2_RPC_URL)
    echo "Balance for $ADDRESS: $(cast fw $INITIAL_L2_BALANCE)"

    echo "Depositing $AMOUNT to L2 via bridge..."

    ${cast} send $L1_STANDARD_BRIDGE_PROXY_ADDRESS \
      --value $AMOUNT \
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
        exit 0
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
  ''
