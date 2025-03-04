{ pkgs }:
let
  cast = "${pkgs.foundry}/bin/cast";
in
pkgs.writeShellScriptBin "seed-l1" ''
  PRIVATE_KEY=$1
  RPC_URL=$2

  ${cast} send 0x0000000000000000000000000000000000000001 \
    --value $(cast 2w 1) \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    --priority-gas-price 15gwei \
    --gas-price 100gwei

  if [ $? -ne 0 ]; then
      echo "Could not execute seed transaction"
      exit 1
  fi

''
