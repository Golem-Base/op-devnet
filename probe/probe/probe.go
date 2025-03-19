package probe

import (
	"context"
	"fmt"
	"math/big"
	"time"

	"github.com/ethereum-optimism/optimism/op-service/txmgr"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/ethereum/go-ethereum/log"
)

type Probe struct {
	Name    string
	Account *common.Address
	Client  *ethclient.Client
	ChainId *big.Int
	TxMgr   *txmgr.SimpleTxManager
}

func NewProbe(ctx context.Context, name, rpcUrl, privateKey string) (*Probe, error) {
	pk, err := crypto.HexToECDSA(privateKey)
	if err != nil {
		return nil, fmt.Errorf("could not parse private key: %w", err)
	}
	account := crypto.PubkeyToAddress(pk.PublicKey)

	client, err := ethclient.Dial(rpcUrl)
	if err != nil {
		return nil, fmt.Errorf("could not dial rpc at %s: %w", rpcUrl, err)
	}

	timeoutCtx, cancel := context.WithTimeout(ctx, time.Duration(30*time.Second))
	defer cancel()

	chainId, err := client.NetworkID(timeoutCtx)
	if err != nil {
		return nil, fmt.Errorf("failed to get network id: %w", err)
	}

	txMgr, err := NewTxMgr("l1-probe", rpcUrl, privateKey)
	if err != nil {
		return nil, fmt.Errorf("could not construct transaction manager: %w", err)
	}

	return &Probe{
		Name:    name,
		Account: &account,
		Client:  client,
		ChainId: chainId,
		TxMgr:   txMgr,
	}, nil
}

func (p *Probe) WaitForChainStart(ctx context.Context, duration time.Duration) error {
	deadline := time.Now().Add(duration)

	for time.Now().Before(deadline) {

		header, err := p.Client.HeaderByNumber(ctx, nil)
		if err != nil {
			log.Error("received error fetching header: %w", err)
		}
		if header.Number.Uint64() > 0 {
			return nil
		}
		time.Sleep(1 * time.Second)
	}
	return fmt.Errorf("timed out waiting for chain to start producing blocks")
}
