package cmd

import (
	"context"
	"crypto/ecdsa"
	"fmt"
	"math/big"
	"time"

	"log/slog"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/urfave/cli/v2"
)

const defaultTimeout int64 = 60
const defaultRpcUrl string = "http://localhost:8545"
const recipientAddressHex string = "0x0000000000000000000000000000000000000001"

var CheckL1Command = &cli.Command{
	Name:  "checkL1",
	Usage: "Waits for L1 to spin up and runs a test transaction",

	// Example flags
	Flags: []cli.Flag{
		&cli.Int64Flag{
			Name:    "timeout",
			Aliases: []string{"t"},
			Usage:   "Number of seconds to wait for L1 to spin up",
			Value:   defaultTimeout,
		},
		&cli.StringFlag{
			Name:  "rpc-url",
			Usage: "Url for exection client",
			Value: defaultRpcUrl,
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
		privateKey, err := crypto.HexToECDSA(removeHexPrefix(rawPrivateKey))
		if err != nil {
			return fmt.Errorf("could not parse private-key %s: %w", rawPrivateKey, err)
		}

		address := crypto.PubkeyToAddress(privateKey.PublicKey)

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

		err = run(ctx, client, timeout, &address, privateKey, amount)
		if err != nil {
			return fmt.Errorf("checkL1 failed with error: %w", err)
		}
		return nil

	},
}

func run(ctx context.Context, client *ethclient.Client, timeout time.Duration, account *common.Address, privateKey *ecdsa.PrivateKey, amount *big.Int) error {
	if err := waitForChainStart(ctx, client, timeout); err != nil {
		return err
	}

	if err := validateUserBalance(ctx, client, account, amount); err != nil {
		return err
	}

	chainId, err := client.NetworkID(ctx)
	if err != nil {
		return fmt.Errorf("failed to get network id: %w", err)
	}

	signer := types.LatestSignerForChainID(chainId)
	nonce, err := client.PendingNonceAt(ctx, *account)
	if err != nil {
		return fmt.Errorf("failed to get nonce: %w", err)
	}
	gasPrice, err := client.SuggestGasPrice(ctx)
	if err != nil {
		return fmt.Errorf("failed to suggest gas price: %w", err)
	}

	recipientAddress := common.HexToAddress(recipientAddressHex)
	tx := types.NewTransaction(nonce, recipientAddress, amount, uint64(21000), gasPrice, nil)
	signedTx, err := types.SignTx(tx, signer, privateKey)
	if err != nil {
		return fmt.Errorf("failed to sign tx: %w", err)
	}
	txHash := signedTx.Hash()
	slog.Info("Sending transaction", "txHash", txHash.Hex())

	err = client.SendTransaction(ctx, signedTx)
	if err != nil {
		return fmt.Errorf("failed to send tx: %w", err)
	}

	slog.Info("Transaction sent, waiting for receipt", "txHash", txHash.Hex())

	ticker := time.NewTicker(1 * time.Second)
	defer ticker.Stop()

	timeoutCtx, cancel := context.WithTimeout(ctx, time.Second*60)
	defer cancel()

	for {
		select {
		case <-timeoutCtx.Done():
			return fmt.Errorf("timed out waiting for receipt for tx %s", txHash.Hex())
		case <-ticker.C:
			receipt, err := client.TransactionReceipt(ctx, txHash)
			if err == nil && receipt != nil {
				slog.Info("Transaction mined successfully", "receipt", receipt)
				return nil
			}
		}
	}
}

func waitForChainStart(ctx context.Context, client *ethclient.Client, timeout time.Duration) error {
	deadline := time.Now().Add(timeout)
	for time.Now().Before(deadline) {
		header, err := client.HeaderByNumber(ctx, nil)
		if err == nil && header.Number.Uint64() > 0 {
			slog.Info("client indicates chain has started", "header", header)
			return nil
		}
		if err != nil {
			slog.Info("no valid response from client", "err", err)
		}
		if err == nil {
			slog.Info("response from client", "header", header)
		}

		time.Sleep(1 * time.Second)
	}

	return fmt.Errorf("timed out waiting for block")
}

func validateUserBalance(ctx context.Context, client *ethclient.Client, account *common.Address, amount *big.Int) error {
	balance, err := client.BalanceAt(ctx, *account, nil)
	if err != nil {
		return fmt.Errorf("could not fetch account balance: %w", err)
	}

	if balance.Cmp(amount) == -1 {
		return fmt.Errorf("account balance less than amount", "balance", balance, "amount", amount)
	}

	slog.Info("validated user balance successfully", "balance", balance)
	return nil

}

func removeHexPrefix(s string) string {
	if len(s) >= 2 && s[:2] == "0x" {
		return s[2:]
	}
	return s
}
