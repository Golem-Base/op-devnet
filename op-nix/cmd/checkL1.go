package cmd

import (
	"context"
	"fmt"
	"math/big"
	"time"

	"github.com/Golem-Base/op.nix/utils"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/urfave/cli/v2"
)

var CheckL1Command = &cli.Command{
	Name:  "checkL1",
	Usage: "Waits for L1 to spin up and runs a test transaction",

	// Example flags
	Flags: []cli.Flag{
		&cli.Int64Flag{
			Name:    "timeout",
			Aliases: []string{"t"},
			Usage:   "Number of seconds to wait for L1 to spin up",
			Value:   utils.DefaultTimeout,
		},
		&cli.StringFlag{
			Name:  "rpc-url",
			Usage: "Url for exection client",
			Value: utils.DefaultL1RpcUrl,
		},
		&cli.StringFlag{
			Name:     "private-key",
			Usage:    "Private key of address to send test transaction from",
			Required: true,
		},
		&cli.Int64Flag{
			Name:     "amount",
			Usage:    "Wei amount to send",
			Required: true,
		},
	},
	Action: func(c *cli.Context) error {
		timeout := time.Second * time.Duration(c.Int64("timeout"))

		rawPrivateKey := c.String("private-key")
		privateKey, err := crypto.HexToECDSA(utils.RemoveHexPrefix(rawPrivateKey))
		if err != nil {
			return fmt.Errorf("could not parse private-key %s: %w", rawPrivateKey, err)
		}

		account := crypto.PubkeyToAddress(privateKey.PublicKey)

		rawAmount := c.Int64("amount")
		if rawAmount < 1 {
			return fmt.Errorf("amount must be greater than 0")
		}
		amount := big.NewInt(rawAmount)

		rpcUrl := c.String("rpc-url")
		client, err := ethclient.Dial(rpcUrl)
		if err != nil {
			return fmt.Errorf("could not dial rpc at %s: %w", rpcUrl, err)
		}

		ctx := context.Background()

		if err := utils.WaitForChainStart(ctx, client, timeout); err != nil {
			return err
		}

		if err := utils.ValidateUserBalance(ctx, client, &account, amount); err != nil {
			return err
		}

		zeroAddress := common.HexToAddress(utils.ZeroAddressHex)
		if err := utils.SendTransaction(ctx, client, privateKey, &zeroAddress, amount); err != nil {
			return err
		}

		return nil
	},
}
