{
  pkgs,
  lib,
  ...
} @ args: let
  dasel = lib.getExe pkgs.dasel;
  op-deployer = lib.getExe args.op-deployer;

  usage = ''
    RPC_URL=""
    PRIVATE_KEY=""
    WORK_DIR=""
    L1_CHAIN_ID=""
    L2_CHAIN_ID=""

    # Addresses
    SUPERCHAIN_PROXY_ADMIN_OWNER=""
    PROTOCOL_VERSIONS_OWNER=""
    GUARDIAN=""
    BASE_FEE_VAULT_RECIPIENT=""
    L1_FEE_VAULT_RECIPIENT=""
    SEQUENCER_FEE_VAULT_RECIPIENT=""
    L1_PROXY_ADMIN_OWNER=""
    L2_PROXY_ADMIN_OWNER=""
    SYSTEM_CONFIG_OWNER=""
    UNSAFE_BLOCK_SIGNER=""
    UPGRADE_CONTROLLER=""
    BATCHER=""
    CHALLENGER=""
    SEQUENCER=""
    PROPOSER=""

    # These are constants for this particular release (see https://github.com/Golem-Base/infra/blob/8c642fde58b0a06690064ce4fa4645f168f2d265/justfile for more explanations)
    L1_CONTRACTS_RELEASE="op-contracts/v2.0.0-rc.1"
    L1_ARTIFACTS_CHECKSUM="1e788c684d48232a85cf5f5bd3876e83d6d2240c80588f60e160faca0133eac8"
    L2_ARTIFACTS_LOCATOR="tag://op-contracts/v1.7.0-beta.1+l2-contracts"
    ABSOLUTE_PRESTATE_HASH="0x03c7dde421fc4988d13be78b655712e0274937dab5de988fbb7a17cf6142b8a"
    PROTOCOL_VERSION="0x0000000000000000000000000000000000000004000000000000000000000001"


    usage() {
      cat <<EOF
    Usage: deploy-optimism [options]

    Options:
      --private-key <PRIVATE_KEY>                Deployer private key
      --rpc-url <URL>                            Specify the RPC URL
      --work-dir <PATH>                          Working directory
      --l1-chain-id <INTEGER>                    L1 chain identifier
      --l2-chain-id <INTEGER>                    L2 chain identifier

      --superchain-proxy-admin-owner <ADDRESS>   -
      --protocol-versions-owner <ADDRESS>        -
      --guardian <ADDRESS>                       -
      --base-fee-vault-recipient <ADDRESS>       -
      --l1-fee-vault-recipient <ADDRESS>         -
      --sequencer-fee-vault-recipient <ADDRESS>  -
      --l1-proxy-admin-owner <ADDRESS>           -
      --l2-proxy-admin-owner <ADDRESS>           -
      --system-config-owner <ADDRESS>            -
      --unsafe-block-signer <ADDRESS>            -
      --upgrade-controller <ADDRESS>             -
      --batcher <ADDRESS>                        -
      --challenger <ADDRESS>                     -
      --sequencer <ADDRESS>                      -
      --proposer <ADDRESS>                       -

      --l1-contracts-release <RELEASE>           L1 contracts release             (default: op-contracts/v2.0.0-rc.1)
      --l1-artifacts-checksum <CHECKSUM>         L1 contracts commit hash         (default: 1e788c684d48232a85cf5f5bd3876e83d6d2240c80588f60e160faca0133eac8)
      --l2-artifacts-locator <TAG>               Tagged L2 contracts artifacts    (default: tag://op-contracts/v1.7.0-beta.1+l2-contracts)
      --absolute-prestate-hash <HASH>            Absolute prestate hash           (default: 0x03c7dde421fc4988d13be78b655712e0274937dab5de988fbb7a17cf6142b8a)
      --protocol-version <HASH>                  Protocol version hash            (default: 0x0000000000000000000000000000000000000004000000000000000000000001)

      -h, --help                                 Show this help message and exit

    EOF
    }

    OPTIONS=h
    LONGOPTS=help,private-key:,rpc-url:,work-dir:,l1-chain-id:,l2-chain-id:,superchain-proxy-admin-owner:,protocol-versions-owner:,guardian:,base-fee-vault-recipient:,l1-fee-vault-recipient:,sequencer-fee-vault-recipient:,l1-proxy-admin-owner:,l2-proxy-admin-owner:,system-config-owner:,unsafe-block-signer:,upgrade-controller:,batcher:,challenger:,sequencer:,proposer:,l1-contracts-release:,l1-artifacts-checksum:,l2-artifacts-locator:,absolute-prestate-hash:,protocol-version:

    TEMP=$(getopt -o "$OPTIONS" --long "$LONGOPTS" -n "''${0##*/}" -- "$@") || {
      usage
      exit 1
    }

    eval set -- "$TEMP"

    while true; do
      case "$1" in
      --rpc-url)
        RPC_URL="$2"
        shift 2
        ;;
      --private-key)
        PRIVATE_KEY="$2"
        shift 2
        ;;
      --work-dir)
        WORK_DIR="$2"
        shift 2
        ;;
      --l1-chain-id)
        L1_CHAIN_ID="$2"
        shift 2
        ;;
      --l2-chain-id)
        L2_CHAIN_ID="$2"
        shift 2
        ;;
      --superchain-proxy-admin-owner)
        SUPERCHAIN_PROXY_ADMIN_OWNER="$2"
        shift 2
        ;;
      --protocol-versions-owner)
        PROTOCOL_VERSIONS_OWNER="$2"
        shift 2
        ;;
      --guardian)
        GUARDIAN="$2"
        shift 2
        ;;
      --base-fee-vault-recipient)
        BASE_FEE_VAULT_RECIPIENT="$2"
        shift 2
        ;;
      --l1-fee-vault-recipient)
        L1_FEE_VAULT_RECIPIENT="$2"
        shift 2
        ;;
      --sequencer-fee-vault-recipient)
        SEQUENCER_FEE_VAULT_RECIPIENT="$2"
        shift 2
        ;;
      --l1-proxy-admin-owner)
        L1_PROXY_ADMIN_OWNER="$2"
        shift 2
        ;;
      --l2-proxy-admin-owner)
        L2_PROXY_ADMIN_OWNER="$2"
        shift 2
        ;;
      --system-config-owner)
        SYSTEM_CONFIG_OWNER="$2"
        shift 2
        ;;
      --unsafe-block-signer)
        UNSAFE_BLOCK_SIGNER="$2"
        shift 2
        ;;
      --upgrade-controller)
        UPGRADE_CONTROLLER="$2"
        shift 2
        ;;
      --batcher)
        BATCHER="$2"
        shift 2
        ;;
      --challenger)
        CHALLENGER="$2"
        shift 2
        ;;
      --sequencer)
        SEQUENCER="$2"
        shift 2
        ;;
      --proposer)
        PROPOSER="$2"
        shift 2
        ;;
      --l1-contracts-release)
        L1_CONTRACTS_RELEASE="$2"
        shift 2
        ;;

      --l1-artifacts-checksum)
        L1_ARTIFACTS_CHECKSUM="$2"
        shift 2
        ;;
      --l2-artifacts-locator)
        L2_ARTIFACTS_LOCATOR="$2"
        shift 2
        ;;
      --absolute-prestate-hash)
        ABSOLUTE_PRESTATE_HASH="$2"
        shift 2
        ;;
      --protocol-version)
        PROTOCOL_VERSION="$2"
        shift 2
        ;;
      -h | --help)
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

    if [[ -z $RPC_URL ]]; then
      echo "Error: --rpc-url is required." >&2
      usage
      exit 1
    fi

    if [[ -z "$PRIVATE_KEY" ]]; then
      echo "Error: --private-key is required." >&2
      usage
      exit 1
    fi

    if [[ -z "$WORK_DIR" ]]; then
      echo "Error: --work-dir is required." >&2
      usage
      exit 1
    fi

    if [[ -z "$L1_CHAIN_ID" ]]; then
      echo "Error: --l1-chain-id is required." >&2
      usage
      exit 1
    fi

    if [[ -z "$L2_CHAIN_ID" ]]; then
      echo "Error: --l2-chain-id is required." >&2
      usage
      exit 1
    fi

    if [[ -z "$SUPERCHAIN_PROXY_ADMIN_OWNER" ]]; then
      echo "$SUPERCHAIN_PROXY_ADMIN_OWNER"
      echo "Error: --superchain-proxy-admin-owner is required." >&2
      usage
      exit 1
    fi

    if [[ -z "$PROTOCOL_VERSIONS_OWNER" ]]; then
      echo "Error: --protocol-versions-owner is required." >&2
      usage
      exit 1
    fi

    if [[ -z "$GUARDIAN" ]]; then
      echo "Error: --guardian is required." >&2
      usage
      exit 1
    fi

    if [[ -z "$BASE_FEE_VAULT_RECIPIENT" ]]; then
      echo "Error: --base-fee-vault-recipient is required." >&2
      usage
      exit 1
    fi

    if [[ -z "$L1_FEE_VAULT_RECIPIENT" ]]; then
      echo "Error: --l1-fee-vault-recipient is required." >&2
      usage
      exit 1
    fi

    if [[ -z "$SEQUENCER_FEE_VAULT_RECIPIENT" ]]; then
      echo "Error: --sequencer-fee-vault-recipient is required." >&2
      usage
      exit 1
    fi

    if [[ -z "$L1_PROXY_ADMIN_OWNER" ]]; then
      echo "Error: --l1-proxy-admin-owner is required." >&2
      usage
      exit 1
    fi

    if [[ -z "$L2_PROXY_ADMIN_OWNER" ]]; then
      echo "Error: --l2-proxy-admin-owner is required." >&2
      usage
      exit 1
    fi

    if [[ -z "$SYSTEM_CONFIG_OWNER" ]]; then
      echo "Error: --system-config-owner is required." >&2
      usage
      exit 1
    fi

    if [[ -z "$UNSAFE_BLOCK_SIGNER" ]]; then
      echo "Error: --unsafe-block-signer is required." >&2
      usage
      exit 1
    fi

    if [[ -z "$UPGRADE_CONTROLLER" ]]; then
      echo "Error: --UPGRADE_CONTROLLER is required." >&2
      usage
      exit 1
    fi

    if [[ -z "$BATCHER" ]]; then
      echo "Error: --batcher is required." >&2
      usage
      exit 1
    fi

    if [[ -z "$CHALLENGER" ]]; then
      echo "Error: --challenger is required." >&2
      usage
      exit 1
    fi

    if [[ -z "$SEQUENCER" ]]; then
      echo "Error: --sequencer is required." >&2
      usage
      exit 1
    fi

    if [[ -z "$PROPOSER" ]]; then
      echo "Error: --proposer is required." >&2
      usage
      exit 1
    fi
  '';
in
  pkgs.writeShellScriptBin "deploy-optimism" ''
    set -euo pipefail
    ${usage}

    INTENT_FILE=$WORK_DIR/intent.toml
    SUPERCHAIN_FILE=$WORK_DIR/superchain.json
    IMPLEMENTATIONS_FILE=$WORK_DIR/implementations.json
    PROXY_FILE=$WORK_DIR/proxy.json
    GENESIS_FILE=$WORK_DIR/genesis.json
    L1_ADDRESSES_FILE=$WORK_DIR/l1_addresses.json
    ROLLUP_FILE=$WORK_DIR/rollup.json

    L1_ARTIFACTS_LOCATOR="https://storage.googleapis.com/oplabs-contract-artifacts/artifacts-v1-$L1_ARTIFACTS_CHECKSUM.tar.gz"

    echo "Initializing OP chain"
    ${op-deployer} init \
        --l1-chain-id $L1_CHAIN_ID \
        --l2-chain-ids $L2_CHAIN_ID \
        --workdir $WORK_DIR \
        --intent-type custom

    echo "Setting chain parameters"
    ${dasel} put -f $INTENT_FILE -r toml -t int "chains.[0].eip1559DenominatorCanyon" -v 250
    ${dasel} put -f $INTENT_FILE -r toml -t int "chains.[0].eip1559Denominator" -v 50
    ${dasel} put -f $INTENT_FILE -r toml -t int "chains.[0].eip1559Elasticity" -v 6

    echo "Setting contract locators"
    ${dasel} put -f $INTENT_FILE -r toml -t string -v "$L1_ARTIFACTS_LOCATOR" "l1ContractsLocator"
    ${dasel} put -f $INTENT_FILE -r toml -t string -v "$L2_ARTIFACTS_LOCATOR" "l2ContractsLocator"

    echo "Bootstraping superchain"
    ${op-deployer} bootstrap superchain \
        --private-key $PRIVATE_KEY \
        --l1-rpc-url $RPC_URL \
        --artifacts-locator $L1_ARTIFACTS_LOCATOR \
        --guardian $GUARDIAN \
        --recommended-protocol-version $PROTOCOL_VERSION \
        --required-protocol-version $PROTOCOL_VERSION \
        --superchain-proxy-admin-owner $SUPERCHAIN_PROXY_ADMIN_OWNER \
        --protocol-versions-owner $PROTOCOL_VERSIONS_OWNER \
        --outfile $SUPERCHAIN_FILE

    # Set all roles
    echo "Setting superchain roles"
    ${dasel} put -f $INTENT_FILE -r toml -t string "superchainRoles.proxyAdminOwner" -v "$SUPERCHAIN_PROXY_ADMIN_OWNER"
    ${dasel} put -f $INTENT_FILE -r toml -t string "superchainRoles.protocolVersionsOwner" -v "$PROTOCOL_VERSIONS_OWNER"
    ${dasel} put -f $INTENT_FILE -r toml -t string "superchainRoles.guardian" -v "$GUARDIAN"

    echo "Setting vault, L1 fee and sequencer fee vault address recipient"
    ${dasel} put -f $INTENT_FILE -r toml -t string "chains.[0].baseFeeVaultRecipient" -v "$BASE_FEE_VAULT_RECIPIENT"
    ${dasel} put -f $INTENT_FILE -r toml -t string "chains.[0].l1FeeVaultRecipient" -v "$L1_FEE_VAULT_RECIPIENT"
    ${dasel} put -f $INTENT_FILE -r toml -t string "chains.[0].sequencerFeeVaultRecipient" -v "$SEQUENCER_FEE_VAULT_RECIPIENT"

    echo "Setting proxy owners"
    ${dasel} put -f $INTENT_FILE -r toml -t string "chains.[0].roles.l1ProxyAdminOwner" -v "$L1_PROXY_ADMIN_OWNER"
    ${dasel} put -f $INTENT_FILE -r toml -t string "chains.[0].roles.l2ProxyAdminOwner" -v "$L2_PROXY_ADMIN_OWNER"
    ${dasel} put -f $INTENT_FILE -r toml -t string "chains.[0].roles.systemConfigOwner" -v "$SYSTEM_CONFIG_OWNER"
    ${dasel} put -f $INTENT_FILE -r toml -t string "chains.[0].roles.unsafeBlockSigner" -v "$UNSAFE_BLOCK_SIGNER"

    echo "Setting batcher, challenger, sequencer and proposer addresses"
    ${dasel} put -f $INTENT_FILE -r toml -t string "chains.[0].roles.batcher" -v "$BATCHER"
    ${dasel} put -f $INTENT_FILE -r toml -t string "chains.[0].roles.challenger" -v "$CHALLENGER"
    ${dasel} put -f $INTENT_FILE -r toml -t string "chains.[0].roles.sequencer" -v "$SEQUENCER"
    ${dasel} put -f $INTENT_FILE -r toml -t string "chains.[0].roles.proposer" -v "$PROPOSER"

    # bootstrap implementations
    SUPERCHAIN_CONFIG_PROXY=$(${dasel} select -f $SUPERCHAIN_FILE -s ".SuperchainConfigProxy" -w plain)
    SUPERCHAIN_PROXY_ADMIN=$(${dasel} select -f $SUPERCHAIN_FILE -s ".SuperchainProxyAdmin" -w plain)
    PROTOCOL_VERSIONS_PROXY=$(${dasel} select -f $SUPERCHAIN_FILE -s ".ProtocolVersionsProxy" -w plain)

    echo "Bootstrapping implementations"
    ${op-deployer} bootstrap implementations \
        --superchain-config-proxy $SUPERCHAIN_CONFIG_PROXY \
        --protocol-versions-proxy $PROTOCOL_VERSIONS_PROXY \
        --private-key $PRIVATE_KEY \
        --l1-rpc-url $RPC_URL \
        --artifacts-locator $L1_ARTIFACTS_LOCATOR \
        --l1-contracts-release $L1_CONTRACTS_RELEASE \
        --upgrade-controller $UPGRADE_CONTROLLER \
        --outfile $IMPLEMENTATIONS_FILE

    echo "Bootstraping proxy"
    ${op-deployer} bootstrap proxy \
        --private-key $PRIVATE_KEY \
        --l1-rpc-url $RPC_URL \
        --artifacts-locator $L1_ARTIFACTS_LOCATOR \
        --proxy-owner $L1_PROXY_ADMIN_OWNER \
        --outfile $PROXY_FILE

    echo "Applying config"
    ${op-deployer} apply \
        --private-key $PRIVATE_KEY \
        --l1-rpc-url $RPC_URL \
        --workdir $WORK_DIR

    echo "Generating genesis file"
    ${op-deployer} inspect genesis \
        --workdir $WORK_DIR $L2_CHAIN_ID \
        > $GENESIS_FILE

    echo "Generating rollup file"
    ${op-deployer} inspect rollup \
        --workdir $WORK_DIR $L2_CHAIN_ID \
        > $ROLLUP_FILE

    echo "Generating l1 addresses file"
    ${op-deployer} inspect l1 \
        --workdir $WORK_DIR $L2_CHAIN_ID \
        > $L1_ADDRESSES_FILE
  ''
