package main

import (
	"fmt"
	"log"
	"os"
	"path/filepath"

	"github.com/damienbutt/emojify-go/internal/emoji"
)

func main() {
	fmt.Println("Fetching emoji data from GitHub gemoji repository...")

	result, err := emoji.ScrapeGitHubEmojis()
	if err != nil {
		log.Fatalf("Failed to scrape emoji data: %v", err)
	}

	fmt.Printf("Successfully fetched %d emojis\n", result.EmojiCount)

	// Generate Go code
	goCode := emoji.GenerateGoCode(result.Data)

	// Write to data.go file
	dataFile := filepath.Join("internal", "emoji", "data_generated.go")
	if err := os.WriteFile(dataFile, []byte(goCode), 0o644); err != nil {
		log.Fatalf("Failed to write data file: %v", err)
	}

	fmt.Printf("Generated %s with %d emoji mappings\n", dataFile, result.EmojiCount)
	fmt.Println("Done! Remember to update the import in your code to use the generated data.")
}
