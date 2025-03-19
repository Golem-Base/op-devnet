package probe

import (
	"fmt"
	"time"

	"github.com/ethereum-optimism/optimism/op-service/txmgr"
	"github.com/ethereum-optimism/optimism/op-service/txmgr/metrics"
	"github.com/ethereum/go-ethereum/log"
)

var DefaultProbeFlagValues = txmgr.DefaultFlagValues{
	NumConfirmations:          uint64(1),
	SafeAbortNonceTooLowCount: uint64(3),
	FeeLimitMultiplier:        uint64(5),
	FeeLimitThresholdGwei:     100.0,
	// MinTipCapGwei:             1.0,
	// MinBaseFeeGwei:            1.0,
	ResubmissionTimeout:   24 * time.Second,
	NetworkTimeout:        10 * time.Second,
	TxSendTimeout:         0, // Try sending txs indefinitely, to preserve tx ordering for Holocene
	TxNotInMempoolTimeout: 2 * time.Minute,
	ReceiptQueryInterval:  2 * time.Second,
}

func NewTxMgr(name, rpcUrl, privateKey string) (*txmgr.SimpleTxManager, error) {
	cliCfg := txmgr.NewCLIConfig(rpcUrl, DefaultProbeFlagValues)
	cliCfg.PrivateKey = privateKey
	mgr, err := txmgr.NewSimpleTxManager(name, log.Root(), &metrics.NoopTxMetrics{}, cliCfg)
	if err != nil {
		return nil, fmt.Errorf("Could not instantiate the %s transaction manager: %w", name, err)
	}
	return mgr, nil
}
