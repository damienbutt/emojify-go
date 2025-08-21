package emoji

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
)

// GemojiEntry represents a single emoji entry from GitHub's gemoji API
type GemojiEntry struct {
	Emoji   string   `json:"emoji"`
	Aliases []string `json:"aliases"`
}

// ScraperResult holds the result of scraping emoji data
type ScraperResult struct {
	EmojiCount int
	Data       map[string]string
}

// ScrapeGitHubEmojis fetches emoji data from GitHub's gemoji repository
func ScrapeGitHubEmojis() (*ScraperResult, error) {
	const gemojiURL = "https://raw.githubusercontent.com/github/gemoji/master/db/emoji.json"

	resp, err := http.Get(gemojiURL)
	if err != nil {
		return nil, fmt.Errorf("failed to fetch emoji data: %w", err)
	}

	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("unexpected status code: %d", resp.StatusCode)
	}

	var entries []GemojiEntry
	if err := json.NewDecoder(resp.Body).Decode(&entries); err != nil {
		return nil, fmt.Errorf("failed to decode JSON: %w", err)
	}

	emojiMap := make(map[string]string)

	for _, entry := range entries {
		for _, alias := range entry.Aliases {
			emojiAlias := fmt.Sprintf(":%s:", alias)
			emojiMap[emojiAlias] = entry.Emoji
		}
	}

	return &ScraperResult{
		EmojiCount: len(emojiMap),
		Data:       emojiMap,
	}, nil
}

// GenerateGoCode generates Go code for the emoji mappings
func GenerateGoCode(data map[string]string) string {
	var builder strings.Builder

	builder.WriteString("package emoji\n\n")
	builder.WriteString("// EmojiMap holds the mapping from aliases to Unicode emoji characters\n")
	builder.WriteString("// This file is auto-generated from GitHub's gemoji database\n")
	builder.WriteString("var EmojiMap = map[string]string{\n")

	// Sort aliases for consistent output
	aliases := make([]string, 0, len(data))
	for alias := range data {
		aliases = append(aliases, alias)
	}

	for _, alias := range aliases {
		builder.WriteString(fmt.Sprintf("\t%q: %q,\n", alias, data[alias]))
	}

	builder.WriteString("}\n")

	return builder.String()
}
