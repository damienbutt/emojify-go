package emojify

import (
	"fmt"
	"strings"

	"github.com/damienbutt/emojify-go/internal/emoji"
)

// Processor handles emoji replacement in text
type Processor struct{}

// NewProcessor creates a new emoji processor
func NewProcessor() *Processor {
	return &Processor{}
}

// Process replaces emoji aliases in the given text with actual emoji characters
func (p *Processor) Process(text string) string {
	if !emoji.HasEmoji(text) {
		return text
	}

	var result strings.Builder
	var currentToken strings.Builder
	inToken := false

	runes := []rune(text)

	for i, char := range runes {
		if !inToken {
			// Starting a new token
			if char == ':' {
				inToken = true
				currentToken.WriteRune(char)
			} else {
				result.WriteRune(char)
			}
		} else {
			// Inside a token
			if char == ':' {
				// Finishing the current token
				currentToken.WriteRune(char)
				token := currentToken.String()
				emojiResult := emoji.GetEmoji(token)

				// If no replacement was made, we might need to keep the leading ':'
				// for potential future emoji matches
				if emojiResult == token {
					// Check if this could be the start of another emoji
					if i+1 < len(runes) && emoji.IsValidEmojiChar(runes[i+1]) {
						// Write everything except the last ':' and start a new token
						result.WriteString(token[:len(token)-1])
						currentToken.Reset()
						currentToken.WriteRune(':')
					} else {
						// Not the start of another emoji, write everything
						result.WriteString(token)
						currentToken.Reset()
						inToken = false
					}
				} else {
					// Successful replacement
					result.WriteString(emojiResult)
					currentToken.Reset()
					inToken = false
				}
			} else if emoji.IsValidEmojiChar(char) {
				// Valid character for emoji alias
				currentToken.WriteRune(char)
			} else {
				// Invalid character, drop the current token
				currentToken.WriteRune(char)
				result.WriteString(currentToken.String())
				currentToken.Reset()
				inToken = false
			}
		}
	}

	// Handle any remaining token
	if currentToken.Len() > 0 {
		result.WriteString(currentToken.String())
	}

	return result.String()
}

// Process is a convenience function that creates a processor and processes text
func Process(text string) string {
	processor := NewProcessor()
	return processor.Process(text)
}

// Decode replaces emoji characters in the given text with their aliases
func (p *Processor) Decode(text string) string {
	// Quick check - if no multi-byte characters, likely no emoji
	if len(text) == len([]rune(text)) {
		return text
	}

	result := text
	// Get the reverse mapping and decode emojis
	reverseMap := emoji.GetReverseMap()

	// We need to handle emoji characters which can be multi-byte
	// Process the string by iterating through potential emoji matches
	// Sort by length (longest first) to handle compound emoji correctly
	var emojis []string
	for emojiChar := range reverseMap {
		emojis = append(emojis, emojiChar)
	}

	// Sort by length descending to replace longer emoji first
	for i := 0; i < len(emojis); i++ {
		for j := i + 1; j < len(emojis); j++ {
			if len(emojis[i]) < len(emojis[j]) {
				emojis[i], emojis[j] = emojis[j], emojis[i]
			}
		}
	}

	for _, emojiChar := range emojis {
		if strings.Contains(result, emojiChar) {
			alias := reverseMap[emojiChar]
			result = strings.ReplaceAll(result, emojiChar, alias)
		}
	}

	return result
}

// Decode is a convenience function that creates a processor and decodes text
func Decode(text string) string {
	processor := NewProcessor()
	return processor.Decode(text)
}

// ListEmojis prints all available emojis
func ListEmojis() error {
	emojis := emoji.ListAllEmojis()
	for _, emoji := range emojis {
		fmt.Println(emoji)
	}

	return nil
}
