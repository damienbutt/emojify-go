package main

import (
	"context"
	"fmt"
	"io"
	"log"
	"os"
	"strings"

	"github.com/urfave/cli/v3"

	"github.com/damienbutt/emojify-go/internal/emojify"
	"github.com/damienbutt/emojify-go/internal/version"
)

func main() {
	cmd := &cli.Command{
		Name:    "emojify",
		Usage:   "emoji on the command line 😱",
		Version: version.Version,
		Authors: []any{
			"Damien Butt",
		},
		Description: `emojify substitutes emoji aliases that many services (like GitHub) use for emoji raw characters.

By default, it converts aliases to emoji (:smile: → 😄). Use --decode to convert emoji back to aliases (😄 → :smile:).

Examples:
  emojify "Hey, I just :raising_hand: you!"
  emojify --decode "Hey, I just 🙋 you!"
  git log --oneline --color | emojify | less -r
  echo "Perfect! :100:" | emojify
  echo "Perfect! 💯" | emojify --decode`,

		Flags: []cli.Flag{
			&cli.BoolFlag{
				Name:    "list",
				Aliases: []string{"l"},
				Usage:   "list all available emojis",
			},
			&cli.BoolFlag{
				Name:    "encode",
				Aliases: []string{"e"},
				Usage:   "encode aliases to emoji (default behavior)",
			},
			&cli.BoolFlag{
				Name:    "decode",
				Aliases: []string{"d"},
				Usage:   "decode emoji to aliases",
			},
		},

		Action: func(ctx context.Context, c *cli.Command) error {
			// Check for mutually exclusive flags
			encodeFlag := c.Bool("encode")
			decodeFlag := c.Bool("decode")

			if encodeFlag && decodeFlag {
				return fmt.Errorf("--encode and --decode flags are mutually exclusive")
			}

			if c.Bool("list") {
				return emojify.ListEmojis()
			}

			args := c.Args()
			// Check if we have actual text arguments (not just flags)
			// args.Slice() contains only non-flag arguments
			hasArgs := len(args.Slice()) > 0

			// Determine the processing function based on flags
			var processFunc func(string) string
			if decodeFlag {
				processFunc = emojify.Decode
			} else {
				// Default behavior (encode) or explicit encode flag
				processFunc = emojify.Process
			}

			if hasArgs {
				// Process command line arguments
				text := strings.Join(args.Slice(), " ")
				processed := processFunc(text)

				// For empty processed text, don't add a newline for better pipeline compatibility
				if processed == "" {
					fmt.Print(processed)
				} else {
					fmt.Println(processed)
				}
			} else {
				// Process stdin while preserving exact input format
				input, err := io.ReadAll(os.Stdin)
				if err != nil {
					return fmt.Errorf("error reading from stdin: %w", err)
				}

				// Process the input and preserve original format exactly
				processed := processFunc(string(input))
				fmt.Print(processed)
			}

			return nil
		},
	}

	// Override the default version printer to only show version number
	cli.VersionPrinter = func(cmd *cli.Command) {
		fmt.Printf("%s\n", cmd.Version)
	}

	if err := cmd.Run(context.Background(), os.Args); err != nil {
		log.Fatal(err)
	}
}
