{pkgs}: let
  cast = "${pkgs.foundry}/bin/cast";
in
  pkgs.writeShellScriptBin "seed-l1" ''
    set -euo pipefail

    PRIVATE_KEY=$1
    RPC_URL=$2

    echo "Seeding the network with an initial transaction..."

    ${cast} send 0x0000000000000000000000000000000000000001 \
      --value $(cast 2w 1) \
      --rpc-url $RPC_URL \
      --private-key $PRIVATE_KEY \
      --priority-gas-price 15gwei \
      --gas-price 100gwei

    echo "Seeding transaction executed successfully..."
  ''
