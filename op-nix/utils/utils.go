package utils

import (
	"context"
	"crypto/ecdsa"
	"fmt"
	"log/slog"
	"math/big"
	"time"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethclient"
)

const DefaultTimeout int64 = 60
const DefaultL1RpcUrl string = "http://localhost:8545"
const DefaultL2RpcUrl string = "http://localhost:9545"

const ZeroAddressHex string = "0x0000000000000000000000000000000000000000"

func WaitForChainStart(ctx context.Context, client *ethclient.Client, timeout time.Duration) error {
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

func ValidateUserBalance(ctx context.Context, client *ethclient.Client, account *common.Address, amount *big.Int) error {
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

func SendTransaction(ctx context.Context, client *ethclient.Client, privateKey *ecdsa.PrivateKey, toAccount *common.Address, amount *big.Int) error {
	// Derive from account
	account := crypto.PubkeyToAddress(privateKey.PublicKey)

	// Get chainID
	chainId, err := client.NetworkID(ctx)
	if err != nil {
		return fmt.Errorf("failed to get network id: %w", err)
	}

	// Construct the signer
	signer := types.LatestSignerForChainID(chainId)
	nonce, err := client.PendingNonceAt(ctx, account)
	if err != nil {
		return fmt.Errorf("failed to get nonce: %w", err)
	}

	// Estimate the gas price
	gasPrice, err := client.SuggestGasPrice(ctx)
	if err != nil {
		return fmt.Errorf("failed to suggest gas price: %w", err)
	}

	// Construct the unsigned transaction data
	tx := types.NewTransaction(nonce, *toAccount, amount, uint64(21000), gasPrice, nil)

	// Sign the transaction
	signedTx, err := types.SignTx(tx, signer, privateKey)
	if err != nil {
		return fmt.Errorf("failed to sign tx: %w", err)
	}
	txHash := signedTx.Hash()

	// Send the transaction to the client
	slog.Info("Sending transaction", "txHash", txHash.Hex())
	err = client.SendTransaction(ctx, signedTx)
	if err != nil {
		return fmt.Errorf("failed to send tx: %w", err)
	}
	slog.Info("Transaction sent, waiting for receipt", "txHash", txHash.Hex())

	// Wait for the transaction to be mined
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

func RemoveHexPrefix(s string) string {
	if len(s) >= 2 && s[:2] == "0x" {
		return s[2:]
	}
	return s
}
