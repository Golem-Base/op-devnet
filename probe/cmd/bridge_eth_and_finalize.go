package cmd

import (
	"bytes"
	"context"
	"encoding/hex"
	"fmt"
	"math/big"
	"time"

	"github.com/Golem-Base/op.nix/probe/bindings"
	"github.com/Golem-Base/op.nix/probe/probe"

	"github.com/ethereum-optimism/optimism/op-service/eth"
	"github.com/ethereum-optimism/optimism/op-service/txmgr"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/log"
	"github.com/google/uuid"
	"github.com/urfave/cli/v2"
)

// https://github.com/ethereum-optimism/optimism/blob/bf97453f43bcdb7e6947b8505cb8ab2ec068be6f/packages/contracts-bedrock/src/universal/StandardBridge.sol#L28
const DEFAULT_RECEIVE_DEFAULT_GAS_LIMIT uint32 = 200_000

var BridgeEthAndFinalizeCommand = &cli.Command{
	Name:  "bridgeEthAndFinalize",
	Usage: "Waits for the L2 to produce blocks and attempts to bridge ETH from L1 to L2",

	// Example flags
	Flags: []cli.Flag{
		&cli.StringFlag{
			Name:     "private-key",
			Usage:    "Private key of address to send test transaction from",
			Required: true,
		},
		&cli.StringFlag{
			Name:     "l1-rpc-url",
			Usage:    "Url for L1 execution client",
			Required: true,
		},
		&cli.StringFlag{
			Name:     "l2-rpc-url",
			Usage:    "Url for L2 execution client",
			Required: true,
		},
		&cli.StringFlag{
			Name:     "l1-standard-bridge-address",
			Usage:    "Contract address for l1 standard bridge",
			Required: true,
		},
		&cli.StringFlag{
			Name:     "l2-standard-bridge-address",
			Usage:    "Contract address for l2 standard bridge",
			Required: true,
		},
		&cli.Uint64Flag{
			Name:     "amount",
			Usage:    "Amount to deposit from L1 to L2 (wei)",
			Required: true,
		},
	},
	Action: func(c *cli.Context) error {
		amount := big.NewInt(int64(c.Uint64("amount")))

		ctx := context.Background()

		l1Probe, err := probe.NewProbe(ctx, "l1", c.String("l1-rpc-url"), c.String("private-key"))
		if err != nil {
			return fmt.Errorf("Failed to build l1 probe: %w", err)
		}

		l2Probe, err := probe.NewProbe(ctx, "l2", c.String("l2-rpc-url"), c.String("private-key"))
		if err != nil {
			return fmt.Errorf("Failed to build l1 probe: %w", err)
		}

		l1StandardBridgeAddress := common.HexToAddress(c.String("l1-standard-bridge-proxy-address"))
		l1StandardBridgeAbi, err := bindings.L1StandardBridgeMetaData.GetAbi()
		if err != nil {
			return fmt.Errorf("Could not get L1StandardBridge ABI: %w", err)
		}
		_, err = bindings.NewL1StandardBridge(l1StandardBridgeAddress, l1Probe.Client)
		if err != nil {
			return fmt.Errorf("Could not instantiate L1StandardBridge: %w", err)
		}

		l2StandardBridgeAddress := common.HexToAddress(c.String("l2-standard-bridge-address"))
		_, err = bindings.L2StandardBridgeMetaData.GetAbi()
		if err != nil {
			return fmt.Errorf("Could not get L2StandardBridge ABI: %w", err)
		}
		l2StandardBridge, err := bindings.NewL2StandardBridge(l2StandardBridgeAddress, l2Probe.Client)
		if err != nil {
			return fmt.Errorf("Could not instantiate L2StandardBridge: %w", err)
		}

		l2Probe.WaitForChainStart(ctx, time.Second*30)

		initialBlock, err := l2Probe.Client.BlockNumber(ctx)
		if err != nil {
			return fmt.Errorf("Could not get l2 blocknumber: %w", err)
		}

		depositId, err := uuid.New().MarshalBinary()
		if err != nil {
			return fmt.Errorf("Could not create uuid for deposit identification")
		}
		txData, err := l1StandardBridgeAbi.Pack("depositETH", DEFAULT_RECEIVE_DEFAULT_GAS_LIMIT, depositId)
		if err != nil {
			return fmt.Errorf("Could not construct calldata for DepositETH: %w", err)
		}

		timeoutCtx, cancel := context.WithTimeout(ctx, 2*time.Minute)
		defer cancel()
		receipt, err := l1Probe.TxMgr.Send(timeoutCtx, txmgr.TxCandidate{
			TxData: txData,
			Blobs:  []*eth.Blob{},
			To:     &l1StandardBridgeAddress,
			Value:  amount,
		})
		if err != nil {
			return fmt.Errorf("Failed to send depositETH transaction: %w", err)
		}

		log.Info("depositETH transaction has been proposed and included in a block", "tx", receipt.TxHash.Hex())

		event, err := waitForDepositFinalizedEvent(ctx, l2Probe, *l2StandardBridge, initialBlock, depositId)
		if err != nil {
			return fmt.Errorf("Failed to get DepositFinalized event")
		}

		log.Info("Deposit has been finalized on L2", "from", event.From, "to", event.To, "amount", event.Amount, "depositId", hex.EncodeToString(event.ExtraData))

		return nil
	},
}

func waitForDepositFinalizedEvent(ctx context.Context, l2Probe *probe.Probe, l2StandardBridge bindings.L2StandardBridge, initialBlock uint64, depositId []byte) (*bindings.L2StandardBridgeDepositFinalized, error) {
	lastCheckedBlock := initialBlock

	pollInterval := 2 * time.Second
	timeoutCtx, cancel := context.WithTimeout(ctx, 5*time.Minute)
	defer cancel()

	encodedDepositId := hex.EncodeToString(depositId)

	for timeoutCtx.Err() == nil {

		latestBlock, err := l2Probe.Client.BlockNumber(ctx)
		if err != nil {
			log.Warn("Failed to fetch latest L2 block, retrying...", "error", err)
			time.Sleep(pollInterval)
			continue
		}

		if latestBlock > lastCheckedBlock {
			log.Info("Polling for DepositFinalized event", "start", lastCheckedBlock, "end", latestBlock, "extraData", encodedDepositId)

			eventIter, err := l2StandardBridge.FilterDepositFinalized(
				&bind.FilterOpts{Start: lastCheckedBlock, End: &latestBlock}, nil, nil, nil,
			)
			if err != nil {
				log.Error("Failure requesting deposit finalized event", "error", err)
				time.Sleep(pollInterval)
				continue
			}

			for eventIter.Next() {
				evt := eventIter.Event
				if bytes.Equal(evt.ExtraData, depositId) {
					eventIter.Close()
					return evt, nil
				}
			}
			eventIter.Close()
			lastCheckedBlock = latestBlock
		}
		time.Sleep(pollInterval)
	}
	return nil, fmt.Errorf("timed out waiting for DepositFinalized event")
}
