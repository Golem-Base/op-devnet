#!/usr/bin/env bash

# set -euo pipefail

# This script is used to generate the getting-started.json configuration file
# used in the Getting Started quickstart guide on the docs site. Avoids the
# need to have the getting-started.json committed to the repo since it's an
# invalid JSON file when not filled in, which is annoying.

RPC_URL=""

usage() {
  cat <<EOF
Usage: op-config [options]

Options:
  --rpc-url URL             Specify the RPC URL
  -h, --help                Show this help message and exit

EOF
}

OPTIONS=:h
LONGOPTS=rpc-url:,help

TEMP=$(getopt -o "$OPTIONS" --long "$LONGOPTS" -n "${0##*/}" -- "$@") || {
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
    -h|--help)
      usage
      exit 0
      ;;
    --)
      # End of all options
      shift
      break
      ;;
    *)
      # Unexpected options (shouldn’t happen if getopt is used correctly)
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

append_with_default() {
    json_key="$1"
    env_var_name="$2"
    default_value="$3"
    var_value="${!env_var_name}"

    if [ -z "$var_value" ] || [ "$var_value" == "None" ]; then
        var_value="$default_value"
    fi

    echo "  \"$json_key\": \"$var_value\"," >> tmp_config.json
}

WALLETS=$(cast wallet new --json --number 4)

GS_ADMIN_ADDRESS=$(jq -r .[0].address <<< $WALLETS)
GS_ADMIN_PRIVATE_KEY=$(jq -r .[0].private_key<<< $WALLETS)
GS_BATCHER_ADDRESS=$(jq -r .[1].address <<< $WALLETS)
GS_BATCHER_PRIVATE_KEY=$(jq -r .[1].private_key <<< $WALLETS)
GS_PROPOSER_ADDRESS=$(jq -r .[2].address <<< $WALLETS)
GS_PROPOSER_PRIVATE_KEY=$(jq -r .[2].private_key <<< $WALLETS)
GS_SEQUENCER_ADDRESS=$(jq -r .[3].address <<< $WALLETS)
GS_SEQUENCER_PRIVATE_KEY=$(jq -r .[3].private_key <<< $WALLETS)

l1_chain_id=$(cast chain-id --rpc-url "$RPC_URL")

# Get the latest block timestamp and hash
block=$(cast block latest --rpc-url "$RPC_URL")
timestamp=$(echo "$block" | awk '/timestamp/ { print $2 }')
blockhash=$(echo "$block" | awk '/hash/ { print $2 }')

# Start generating the config file in a temporary file

cat << EOL > tmp_config.json
{
  "admin_address": "$GS_ADMIN_ADDRESS",
  "admin_private_key": "$GS_ADMIN_PRIVATE_KEY",
  "batcher_address": "$GS_BATCHER_ADDRESS",
  "batcher_private_key": "$GS_BATCHER_PRIVATE_KEY",
  "proposer_address": "$GS_PROPOSER_ADDRESS",
  "proposer_private_key": "$GS_PROPOSER_PRIVATE_KEY",
  "sequencer_address": "$GS_SEQUENCER_ADDRESS",
  "sequencer_private_key": "$GS_SEQUENCER_PRIVATE_KEY",
  
  "l1StartingBlockTag": "$blockhash",

  "l1ChainID": $l1_chain_id,
  "l2ChainID": 42069,
  "l2BlockTime": 2,
  "l1BlockTime": 12,

  "maxSequencerDrift": 600,
  "sequencerWindowSize": 3600,
  "channelTimeout": 300,

  "p2pSequencerAddress": "$GS_SEQUENCER_ADDRESS",
  "batchInboxAddress": "0xff00000000000000000000000000000000042069",
  "batchSenderAddress": "$GS_BATCHER_ADDRESS",

  "l2OutputOracleSubmissionInterval": 120,
  "l2OutputOracleStartingBlockNumber": 0,
  "l2OutputOracleStartingTimestamp": $timestamp,

  "l2OutputOracleProposer": "$GS_PROPOSER_ADDRESS",
  "l2OutputOracleChallenger": "$GS_ADMIN_ADDRESS",

  "finalizationPeriodSeconds": 12,

  "proxyAdminOwner": "$GS_ADMIN_ADDRESS",
  "baseFeeVaultRecipient": "$GS_ADMIN_ADDRESS",
  "l1FeeVaultRecipient": "$GS_ADMIN_ADDRESS",
  "sequencerFeeVaultRecipient": "$GS_ADMIN_ADDRESS",
  "finalSystemOwner": "$GS_ADMIN_ADDRESS",
  "superchainConfigGuardian": "$GS_ADMIN_ADDRESS",

  "baseFeeVaultMinimumWithdrawalAmount": "0x8ac7230489e80000",
  "l1FeeVaultMinimumWithdrawalAmount": "0x8ac7230489e80000",
  "sequencerFeeVaultMinimumWithdrawalAmount": "0x8ac7230489e80000",
  "baseFeeVaultWithdrawalNetwork": 0,
  "l1FeeVaultWithdrawalNetwork": 0,
  "sequencerFeeVaultWithdrawalNetwork": 0,

  "gasPriceOracleOverhead": 0,
  "gasPriceOracleScalar": 1000000,

  "enableGovernance": true,
  "governanceTokenSymbol": "OP",
  "governanceTokenName": "Optimism",
  "governanceTokenOwner": "$GS_ADMIN_ADDRESS",

  "l2GenesisBlockGasLimit": "0x1c9c380",
  "l2GenesisBlockBaseFeePerGas": "0x3b9aca00",

  "eip1559Denominator": 50,
  "eip1559DenominatorCanyon": 250,
  "eip1559Elasticity": 6,
EOL

# Append conditional environment variables with their corresponding default values
# Activate granite fork
if [ -n "${GRANITE_TIME_OFFSET}" ]; then
    append_with_default "l2GenesisGraniteTimeOffset" "GRANITE_TIME_OFFSET" "0x0"
fi
# Activate holocene fork
if [ -n "${HOLOCENE_TIME_OFFSET}" ]; then
    append_with_default "l2GenesisHoloceneTimeOffset" "HOLOCENE_TIME_OFFSET" "0x0"
fi

# Activate the interop fork
if [ -n "${INTEROP_TIME_OFFSET}" ]; then
    append_with_default "l2GenesisInteropTimeOffset" "INTEROP_TIME_OFFSET" "0x0"
fi

# Already forked updates
append_with_default "l2GenesisFjordTimeOffset" "FJORD_TIME_OFFSET" "0x0"
append_with_default "l2GenesisRegolithTimeOffset" "REGOLITH_TIME_OFFSET" "0x0"
append_with_default "l2GenesisEcotoneTimeOffset" "ECOTONE_TIME_OFFSET" "0x0"
append_with_default "l2GenesisDeltaTimeOffset" "DELTA_TIME_OFFSET" "0x0"
append_with_default "l2GenesisCanyonTimeOffset" "CANYON_TIME_OFFSET" "0x0"

# Continue generating the config file
cat << EOL >> tmp_config.json
  "systemConfigStartBlock": 0,

  "requiredProtocolVersion": "0x0000000000000000000000000000000000000003000000000000000000000000",
  "recommendedProtocolVersion": "0x0000000000000000000000000000000000000003000000000000000000000000",

  "faultGameAbsolutePrestate": "0x03c7ae758795765c6664a5d39bf63841c71ff191e9189522bad8ebff5d4eca98",
  "faultGameMaxDepth": 44,
  "faultGameClockExtension": 0,
  "faultGameMaxClockDuration": 1200,
  "faultGameGenesisBlock": 0,
  "faultGameGenesisOutputRoot": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "faultGameSplitDepth": 14,
  "faultGameWithdrawalDelay": 600,

  "preimageOracleMinProposalSize": 1800000,
  "preimageOracleChallengePeriod": 300
}
EOL

cat tmp_config.json
rm tmp_config.json
