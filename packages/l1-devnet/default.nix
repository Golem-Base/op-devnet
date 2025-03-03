{ pkgs }:

let

  usage_func_string = ''
    usage() {
      cat <<EOF
    Usage: ''${0##*/} [options]

    Options:
      --private-key KEY         Ethereum private key
      -h, --help                Show this help message and exit

    EOF
    }
  '';

  parse_args = ''
    OPTIONS=:h
    LONGOPTS=private-key:,help

    TEMP=$(getopt -o "$OPTIONS" --long "$LONGOPTS" -n "''${0##*/}" -- "$@") || {
      usage
      exit 1
    }

    eval set -- "$TEMP"

    while true; do
      case "$1" in
        --private-key)
          PRIVATE_KEY="$2"
          shift 2
          ;;
        -h|--help)
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

    if [[ -z "$PRIVATE_KEY" ]]; then
      echo "Error: --private-key is required." >&2
      usage
      exit 1
    fi

  '';

  genesis = pkgs.writeTextFile {
    name = "genesis.json";
    text = ''
      {
        "config": {
          "chainId": 12345,
          "homesteadBlock": 0,
          "eip150Block": 0,
          "eip155Block": 0,
          "eip158Block": 0,
          "byzantiumBlock": 0
        },
        "alloc": {},
        "coinbase": "0x0000000000000000000000000000000000000000",
        "difficulty": "0x1",
        "gasLimit": "0x47e7c4",
        "nonce": "0x0",
        "timestamp": "0x0"
      }
    '';
  };
in
pkgs.writeShellScriptBin "l1-devnet" ''
  PRIVATE_KEY=""

  ${usage_func_string}
  ${parse_args}

  ADDRESS="$(${pkgs.foundry}/bin/cast wallet address --private-key $PRIVATE_KEY)"

  echo "Using address: $ADDRESS"

  DATA_DIR=$(mktemp -d)
  LOGFILE="$DATA_DIR/geth.log"
  GETH_CMD=(
    geth
    --dev
    --http
    --datadir=$DATA_DIR
    --http.api "admin,eth,web3,personal,net"
  )
  cleanup() {
    echo "Received SIGTERM. Stopping Geth..."

    if [[ -n "''${GETH_PID:-}" ]]; then
      kill "$GETH_PID" 2>/dev/null || true
    fi

    if [[ -n "''${TAIL_PID:-}" ]]; then
      kill "$TAIL_PID" 2>/dev/null || true
    fi

    rm -rf $DATA_DIR
    exit 0
  }
  trap cleanup SIGTERM

  geth init --datadir $DATADIR ${genesis}

  echo "Starting Geth in dev mode..."
  "''${GETH_CMD[@]}" >"$LOGFILE" 2>&1 &
  GETH_PID=$!

  echo "Waiting for Geth to initialize..."
  sleep 3

  geth attach --exec "
    eth.sendTransaction({
      from: eth.accounts[0],
      to: "\"$ADDRESS\"",
      value: web3.toWei(100, 'ether')
    });
  " http://127.0.0.1:8545 || {
    echo "Initial funding command failed." >&2
    kill "$GETH_PID"
    exit 1
  }

  echo "Tailing Geth logs at $LOGFILE"
  # Start tail in background
  tail -f "$LOGFILE" &
  TAIL_PID=$!  

  wait "$GETH_PID"

  echo "Geth has exited. Stopping script."
  kill "$TAIL_PID" 2>/dev/null || true
  exit 0
''
