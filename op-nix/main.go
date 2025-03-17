package main

import (
	"log/slog"
	"os"

	"github.com/Golem-Base/op.nix/op-nix/cmd"
	"github.com/urfave/cli/v2"
)

func main() {
	slog.SetDefault(slog.New(slog.NewJSONHandler(os.Stdout, nil)))

	app := &cli.App{
		Name:  "op.nix",
		Usage: "Helper utilities for devnet",

		Commands: []*cli.Command{
			cmd.CheckL1Command,
		},
	}

	// Run the CLI
	err := app.Run(os.Args)
	if err != nil {
		slog.Error("Error", app.Name, err)
		os.Exit(1)
	}
}
