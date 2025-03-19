package cmd

import (
	"context"
	"fmt"
	"math/big"
	"probe/probe"
	"time"

	"github.com/ethereum-optimism/optimism/op-service/txmgr"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/log"
	"github.com/urfave/cli/v2"
)

const ZeroAddress string = "0x0000000000000000000000000000000000000000"

var SendOnReadyCommand = &cli.Command{
	Name:  "sendOnReady",
	Usage: "Waits for the client to produce blocks and attempts to transfer ETH",

	// Example flags
	Flags: []cli.Flag{
		&cli.StringFlag{
			Name:     "rpc-url",
			Usage:    "Url for exection client",
			Required: true,
		},
		&cli.StringFlag{
			Name:     "private-key",
			Usage:    "Private key of address to send test transaction from",
			Required: true,
		},
		&cli.Uint64Flag{
			Name:     "amount",
			Usage:    "Wei amount to send",
			Required: true,
		},
	},
	Action: func(c *cli.Context) error {
		amount := big.NewInt(int64(c.Uint64("amount")))

		ctx := context.Background()
		l1Probe, err := probe.NewProbe(ctx, "l1", c.String("rpc-url"), c.String("private-key"))
		if err != nil {
			return fmt.Errorf("Failed to build l1 probe: %w", err)
		}

		if err := l1Probe.WaitForChainStart(ctx, time.Second*30); err != nil {
			return fmt.Errorf("Chain did not start: %w", err)
		}

		zeroAddress := common.HexToAddress(ZeroAddress)

		receipt, err := l1Probe.TxMgr.Send(ctx, txmgr.TxCandidate{To: &zeroAddress, Value: amount})
		if err != nil {
			return fmt.Errorf("Failed to send ETH to %s: %w", zeroAddress, err)
		}

		log.Info("Successfully sent transaction", "tx", receipt.TxHash.Hex())

		return nil
	},
}
