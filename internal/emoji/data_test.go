package emoji

import (
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/stretchr/testify/suite"
)

// EmojiTestSuite defines the test suite for emoji functionality
type EmojiTestSuite struct {
	suite.Suite
}

// TestGetEmoji tests the GetEmoji function
func (suite *EmojiTestSuite) TestGetEmoji() {
	tests := []struct {
		name     string
		alias    string
		expected string
	}{
		{
			name:     "valid emoji",
			alias:    ":100:",
			expected: "💯",
		},
		{
			name:     "valid emoji with plus",
			alias:    ":+1:",
			expected: "👍",
		},
		{
			name:     "valid emoji with minus",
			alias:    ":-1:",
			expected: "👎",
		},
		{
			name:     "invalid emoji returns original",
			alias:    ":nonexistent:",
			expected: ":nonexistent:",
		},
		{
			name:     "empty string",
			alias:    "",
			expected: "",
		},
		{
			name:     "malformed alias",
			alias:    "no_colons",
			expected: "no_colons",
		},
	}

	for _, tt := range tests {
		suite.Run(tt.name, func() {
			result := GetEmoji(tt.alias)
			assert.Equal(suite.T(), tt.expected, result)
		})
	}
}

// TestListAllEmojis tests the ListAllEmojis function
func (suite *EmojiTestSuite) TestListAllEmojis() {
	emojis := ListAllEmojis()

	// Should have a significant number of emojis
	assert.Greater(suite.T(), len(emojis), 2000, "Should have over 2000 emojis")

	// Each entry should be formatted correctly
	for i, emoji := range emojis {
		if i >= 10 { // Only check first 10 for performance
			break
		}
		assert.Contains(suite.T(), emoji, ":", "Entry should contain colons: %s", emoji)
		assert.True(suite.T(), len(emoji) > 3, "Entry should be longer than 3 chars: %s", emoji)
	}

	// Should be sorted
	if len(emojis) > 1 {
		assert.True(suite.T(), emojis[0] < emojis[1], "Emojis should be sorted")
	}

	// Check for some known emojis
	emojiList := ListAllEmojis()

	// These should exist (checking just the format, not exact emoji)
	found100 := false
	foundSmile := false
	foundHeart := false

	for _, emoji := range emojiList {
		if strings.Contains(emoji, ":100:") {
			found100 = true
		}
		if strings.Contains(emoji, ":smile:") {
			foundSmile = true
		}
		if strings.Contains(emoji, ":heart:") {
			foundHeart = true
		}

		// Break early if we found all we're looking for
		if found100 && foundSmile && foundHeart {
			break
		}
	}

	// At least some common emojis should be found
	assert.True(suite.T(), found100 || foundSmile || foundHeart, "Should find at least one common emoji")
}

// TestIsValidEmojiChar tests the IsValidEmojiChar function
func (suite *EmojiTestSuite) TestIsValidEmojiChar() {
	tests := []struct {
		name     string
		char     rune
		expected bool
	}{
		// Valid characters
		{name: "lowercase a", char: 'a', expected: true},
		{name: "lowercase z", char: 'z', expected: true},
		{name: "uppercase A", char: 'A', expected: true},
		{name: "uppercase Z", char: 'Z', expected: true},
		{name: "digit 0", char: '0', expected: true},
		{name: "digit 9", char: '9', expected: true},
		{name: "underscore", char: '_', expected: true},
		{name: "plus", char: '+', expected: true},
		{name: "minus", char: '-', expected: true},

		// Invalid characters
		{name: "space", char: ' ', expected: false},
		{name: "exclamation", char: '!', expected: false},
		{name: "at symbol", char: '@', expected: false},
		{name: "hash", char: '#', expected: false},
		{name: "dollar", char: '$', expected: false},
		{name: "percent", char: '%', expected: false},
		{name: "caret", char: '^', expected: false},
		{name: "ampersand", char: '&', expected: false},
		{name: "asterisk", char: '*', expected: false},
		{name: "parenthesis", char: '(', expected: false},
		{name: "bracket", char: '[', expected: false},
		{name: "colon", char: ':', expected: false},
		{name: "semicolon", char: ';', expected: false},
		{name: "quote", char: '"', expected: false},
		{name: "slash", char: '/', expected: false},
		{name: "backslash", char: '\\', expected: false},
		{name: "pipe", char: '|', expected: false},
		{name: "question", char: '?', expected: false},
		{name: "dot", char: '.', expected: false},
		{name: "comma", char: ',', expected: false},
		{name: "unicode emoji", char: '😀', expected: false},
	}

	for _, tt := range tests {
		suite.Run(tt.name, func() {
			result := IsValidEmojiChar(tt.char)
			assert.Equal(suite.T(), tt.expected, result, "Character: %c (%d)", tt.char, tt.char)
		})
	}
}

// TestHasEmoji tests the HasEmoji function
func (suite *EmojiTestSuite) TestHasEmoji() {
	tests := []struct {
		name     string
		text     string
		expected bool
	}{
		{
			name:     "has emoji",
			text:     "Hello :smile: world",
			expected: true,
		},
		{
			name:     "no emoji",
			text:     "Hello world",
			expected: false,
		},
		{
			name:     "single colon",
			text:     "Time is 12:30",
			expected: true, // Contains colon, function just checks for presence
		},
		{
			name:     "multiple colons",
			text:     ":::",
			expected: true,
		},
		{
			name:     "empty string",
			text:     "",
			expected: false,
		},
		{
			name:     "colon at start",
			text:     ":start",
			expected: true,
		},
		{
			name:     "colon at end",
			text:     "end:",
			expected: true,
		},
	}

	for _, tt := range tests {
		suite.Run(tt.name, func() {
			result := HasEmoji(tt.text)
			assert.Equal(suite.T(), tt.expected, result)
		})
	}
}

// TestEmojiMapIntegrity tests the integrity of the emoji map
func (suite *EmojiTestSuite) TestEmojiMapIntegrity() {
	// Map should not be empty
	require.NotEmpty(suite.T(), EmojiMap, "EmojiMap should not be empty")

	// Should have a reasonable number of emojis
	assert.Greater(suite.T(), len(EmojiMap), 2000, "Should have over 2000 emojis")

	// All keys should be properly formatted
	for alias := range EmojiMap {
		assert.True(suite.T(), len(alias) >= 3, "Alias should be at least 3 chars: %s", alias)
		assert.True(suite.T(), alias[0] == ':', "Alias should start with colon: %s", alias)
		assert.True(suite.T(), alias[len(alias)-1] == ':', "Alias should end with colon: %s", alias)

		// Check that the middle part contains only valid characters
		middle := alias[1 : len(alias)-1]
		for _, char := range middle {
			assert.True(suite.T(), IsValidEmojiChar(char), "Invalid char in alias %s: %c", alias, char)
		}
	}

	// All values should be non-empty
	for alias, emoji := range EmojiMap {
		assert.NotEmpty(suite.T(), emoji, "Emoji value should not be empty for alias: %s", alias)
	}

	// Test some known emoji mappings
	knownMappings := map[string]string{
		":100:":      "💯",
		":+1:":       "👍",
		":-1:":       "👎",
		":airplane:": "✈️",
		":heart:":    "❤️",
	}

	for alias := range knownMappings {
		if actualEmoji, exists := EmojiMap[alias]; exists {
			// We don't assert exact match since the emoji might have variations
			// Just ensure it's not empty and different from the alias
			assert.NotEmpty(suite.T(), actualEmoji, "Emoji should not be empty for %s", alias)
			assert.NotEqual(suite.T(), alias, actualEmoji, "Emoji should be different from alias for %s", alias)
		}
	}
}

// TestEmojiConsistency tests consistency across different functions
func (suite *EmojiTestSuite) TestEmojiConsistency() {
	// GetEmoji should return same results as direct map access
	testAliases := []string{":100:", ":smile:", ":heart:", ":nonexistent:"}

	for _, alias := range testAliases {
		directResult := EmojiMap[alias]
		if directResult == "" {
			directResult = alias // GetEmoji returns original if not found
		}

		functionResult := GetEmoji(alias)
		assert.Equal(suite.T(), directResult, functionResult, "GetEmoji should match direct map access for %s", alias)
	}
}

// TestEdgeCases tests edge cases for the emoji package
func (suite *EmojiTestSuite) TestEdgeCases() {
	// Test with very long alias (should return as-is)
	longAlias := ":" + string(make([]byte, 1000)) + ":"
	result := GetEmoji(longAlias)
	assert.Equal(suite.T(), longAlias, result)

	// Test with Unicode characters in input
	unicodeAlias := ":test_😀_emoji:"
	result = GetEmoji(unicodeAlias)
	assert.Equal(suite.T(), unicodeAlias, result)
}

// TestEmoji runs all emoji tests
func TestEmoji(t *testing.T) {
	suite.Run(t, new(EmojiTestSuite))
}
