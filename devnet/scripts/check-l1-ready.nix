{pkgs}: let
  cast = "${pkgs.foundry}/bin/cast";
in
  pkgs.writeShellScriptBin "check-l1-ready" ''
    TRIES=$1
    RPC_URL=$2

    block_number=0

    for ((i=0; i<$TRIES; i++)); do
      echo "Attempt #$i..."

      # If 'cast block-number' fails for any reason, store '0'
      block_number="$(${cast} bn --rpc-url "$RPC_URL" 2>/dev/null || echo 0)"

      # Check if it's valid and greater than 0
      if [[ "$block_number" =~ ^[0-9]+$ ]] && [ "$block_number" -gt 0 ]; then
        echo "Success: Block number is $block_number"
        exit 0
        break
      fi

      echo "Block number is $block_number, waiting 1 second..."
      sleep 1
    done

    # If block_number is still 0, exit with failure
    echo "Failed to fetch a valid (non-zero) block number after $TRIES attempts."
    exit 1
  ''
