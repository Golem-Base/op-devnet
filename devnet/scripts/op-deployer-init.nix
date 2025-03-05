{
  pkgs,
  lib,
  ...
}: let
  dasel = lib.getExe pkgs.dasel;
in
  pkgs.writeShellScriptBin "op-deployer-init" ''
    # TODO: Fill properly the necessary arguments here
    PRIVATE_KEY=$1
    RPC_URL=$2

    L1_CHAIN_ID=$555
    L2_CHAIN_IDS=$666
    NETWORK_CONFIG_DIR=$3

    local INTENT_FILE=$NETWORK_CONFIG_DIR/intent.toml
    local SUPERCHAIN_FILE=$NETWORK_CONFIG_DIR/superchain.json
    local IMPLEMENTATIONS_FILE=$NETWORK_CONFIG_DIR/implementations.json
    local PROXY_FILE=$NETWORK_CONFIG_DIR/proxy.json
    local GENESIS_FILE=$NETWORK_CONFIG_DIR/genesis.json
    local ROLLUP_FILE=$NETWORK_CONFIG_DIR/rollup.json

    # These are constants for this particular release (see https://github.com/Golem-Base/infra/blob/8c642fde58b0a06690064ce4fa4645f168f2d265/justfile for more explanations)
    local L1_CONTRACTS_RELEASE="op-contracts/v2.0.0-rc.1"
    local L1_ARTIFACTS_LOCATOR="tag://op-contracts/v2.0.0-rc.1"
    local L2_ARTIFACTS_LOCATOR="tag://op-contracts/v1.7.0-beta.1+l2-contracts"
    local ABSOLUTE_PRESTATE_HASH="0x03c7dde421fc4988d13be78b655712e0274937dab5de988fbb7a17cf6142b8a"
    local PROTOCOL_VERSION="0x0000000000000000000000000000000000000004000000000000000000000001"

    echo "Initializing OP chain"
    op-deployer init \
        --l1-chain-id {{ L1_CHAIN_ID }} \
        --l2-chain-ids $L2_CHAIN_IDS \
        --workdir $NETWORK_CONFIG_DIR \
        --intent-config-type custom

    echo "Setting chain parameters"
    ${dasel} put -f $INTENT_FILE -r toml -t int "chains.[0].eip1559DenominatorCanyon" -v 250
    ${dasel} put -f $INTENT_FILE -r toml -t int "chains.[0].eip1559Denominator" -v 50
    ${dasel} put -f $INTENT_FILE -r toml -t int "chains.[0].eip1559Elasticity" -v 6

    echo "Setting contract locators"
    ${dasel} put -f $INTENT_FILE -r toml -t string -v "$L1_ARTIFACTS_LOCATOR" "l1ContractsLocator"
    ${dasel} put -f $INTENT_FILE -r toml -t string -v "$L2_ARTIFACTS_LOCATOR" "l2ContractsLocator"

    echo "Bootstraping superchain"
    op-deployer bootstrap superchain \
        --private-key $GS_ADMIN_PRIVATE_KEY \
        --l1-rpc-url $L1_RPC_URL \
        --artifacts-locator $L1_ARTIFACTS_LOCATOR \
        --guardian $GS_ADMIN_ADDRESS \
        --recommended-protocol-version $PROTOCOL_VERSION \
        --required-protocol-version $PROTOCOL_VERSION \
        --superchain-proxy-admin-owner $GS_ADMIN_ADDRESS \
        --protocol-versions-owner $GS_ADMIN_ADDRESS \
        --outfile $SUPERCHAIN_FILE

    # Set all roles
    echo "Setting superchain roles"
    ${dasel} put -f $INTENT_FILE -r toml -t string "superchainRoles.proxyAdminOwner" -v "$GS_ADMIN_ADDRESS"
    ${dasel} put -f $INTENT_FILE -r toml -t string "superchainRoles.protocolVersionsOwner" -v "$GS_ADMIN_ADDRESS"
    ${dasel} put -f $INTENT_FILE -r toml -t string "superchainRoles.guardian" -v "$GS_ADMIN_ADDRESS"

    echo "Setting vault, L1 fee and sequencer fee vault address recipient"
    ${dasel} put -f $INTENT_FILE -r toml -t string "chains.[0].baseFeeVaultRecipient" -v "$GS_ADMIN_ADDRESS"
    ${dasel} put -f $INTENT_FILE -r toml -t string "chains.[0].l1FeeVaultRecipient" -v "$GS_ADMIN_ADDRESS"
    ${dasel} put -f $INTENT_FILE -r toml -t string "chains.[0].sequencerFeeVaultRecipient" -v "$GS_ADMIN_ADDRESS"

    echo "Setting proxy owners"
    ${dasel} put -f $INTENT_FILE -r toml -t string "chains.[0].roles.l1ProxyAdminOwner" -v "$GS_ADMIN_ADDRESS"
    ${dasel} put -f $INTENT_FILE -r toml -t string "chains.[0].roles.l2ProxyAdminOwner" -v "$GS_ADMIN_ADDRESS"
    ${dasel} put -f $INTENT_FILE -r toml -t string "chains.[0].roles.systemConfigOwner" -v "$GS_ADMIN_ADDRESS"
    ${dasel} put -f $INTENT_FILE -r toml -t string "chains.[0].roles.unsafeBlockSigner" -v "$GS_ADMIN_ADDRESS"

    echo "Setting batcher, challenger, sequencer and proposer addresses"
    ${dasel} put -f $INTENT_FILE -r toml -t string "chains.[0].roles.batcher" -v "$GS_BATCHER_ADDRESS"
    ${dasel} put -f $INTENT_FILE -r toml -t string "chains.[0].roles.challenger" -v "$GS_CHALLENGER_ADDRESS"
    ${dasel} put -f $INTENT_FILE -r toml -t string "chains.[0].roles.sequencer" -v "$GS_SEQUENCER_ADDRESS"
    ${dasel} put -f $INTENT_FILE -r toml -t string "chains.[0].roles.proposer" -v "$GS_PROPOSER_ADDRESS"

    # bootstrap implementations
    local SuperChainConfixProxy
    SuperChainConfigProxy = $(${dasel} select -f $SUPERCHAIN_FILE -s ".SuperchainConfigProxy" -w plain)

    local ProtocolVersionsProxy
    ProtocolVersionsProxy = $(${dasel} select -f $SUPERCHAIN_FILE -s ".ProtocolVersionsProxy" -w plain)

    echo "Bootstrapping implementations"
    op-deployer bootstrap implementations \
        --superchain-config-proxy "$SuperchainConfigProxy" \
        --protocol-versions-proxy "$ProtocolVersionsProxy" \
        --private-key $GS_ADMIN_PRIVATE_KEY \
        --l1-rpc-url $L1_RPC_URL \
        --artifacts-locator $L1_ARTIFACTS_LOCATOR \
        --l1-contracts-release $L1_CONTRACTS_RELEASE \
        --upgrade-controller $GS_ADMIN_ADDRESS \
        --outfile $IMPLEMENTATIONS_FILE

    echo "Bootstraping proxy"
    op-deployer bootstrap proxy \
        --private-key $GS_ADMIN_PRIVATE_KEY \
        --l1-rpc-url $L1_RPC_URL \
        --artifacts-locator $L1_ARTIFACTS_LOCATOR \
        --proxy-owner $GS_ADMIN_ADDRESS \
        --outfile $PROXY_FILE

    echo "Applying config"
    op-deployer apply \
        --private-key $GS_ADMIN_PRIVATE_KEY \
        --l1-rpc-url $L1_RPC_URL \
        --workdir $NETWORK_CONFIG_DIR

    echo "Generating op-geth genesis file"
    op-deployer inspect genesis \
        --workdir $NETWORK_CONFIG_DIR $L2_CHAIN_IDS \
        > $GENESIS_FILE

    echo "Generating rollup file"
    op-deployer inspect rollup \
        --workdir $NETWORK_CONFIG_DIR $L2_CHAIN_IDS \
        > $ROLLUP_FILE
  ''
