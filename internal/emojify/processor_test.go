package emojify

import (
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/stretchr/testify/suite"
)

// ProcessorTestSuite defines the test suite
type ProcessorTestSuite struct {
	suite.Suite
	processor *Processor
}

// SetupTest runs before each test
func (suite *ProcessorTestSuite) SetupTest() {
	suite.processor = NewProcessor()
}

// TestBasicEmojification tests basic emoji replacement functionality
func (suite *ProcessorTestSuite) TestBasicEmojification() {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{
			name:     "no emoji",
			input:    "no emoji :(",
			expected: "no emoji :(",
		},
		{
			name:     "single emoji",
			input:    "an emoji :grin:",
			expected: "an emoji 😁",
		},
		{
			name:     "multiple emojis",
			input:    "emojis :grin::grin: :tada:yay:champagne:",
			expected: "emojis 😁😁 🎉yay🍾",
		},
		{
			name:     "emojis with underscores and numbers",
			input:    "this is perfect :100:",
			expected: "this is perfect 💯",
		},
		{
			name:     "emojis with + and -",
			input:    "great :+1::+1::-1:",
			expected: "great 👍👍👎",
		},
		{
			name:     "mixed valid and invalid",
			input:    ":smile: :invalid_xyz: :heart:",
			expected: "😄 :invalid_xyz: ❤️",
		},
	}

	for _, tt := range tests {
		suite.Run(tt.name, func() {
			result := suite.processor.Process(tt.input)
			assert.Equal(suite.T(), tt.expected, result, "Input: %q", tt.input)
		})
	}
}

// TestEdgeCases tests edge cases and corner scenarios
func (suite *ProcessorTestSuite) TestEdgeCases() {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{
			name:     "right-hand side emojis",
			input:    ":not_an_emoji:point_right:",
			expected: ":not_an_emoji👉",
		},
		{
			name:     "multiple colons",
			input:    "::::point_right:",
			expected: ":::👉",
		},
		{
			name:     "punctuation after emoji",
			input:    "Enter the :airplane:!",
			expected: "Enter the ✈️!",
		},
		{
			name:     "preserve existing unicode",
			input:    "🐛 leave the emojis alone!!",
			expected: "🐛 leave the emojis alone!!",
		},
		{
			name:     "multiple spaces after emoji",
			input:    ":sparkles:   Three spaces",
			expected: "✨   Three spaces",
		},
		{
			name:     "emoji at start",
			input:    ":tada: Party time!",
			expected: "🎉 Party time!",
		},
		{
			name:     "emoji at end",
			input:    "Great job :100:",
			expected: "Great job 💯",
		},
		{
			name:     "only emoji",
			input:    ":heart:",
			expected: "❤️",
		},
		{
			name:     "empty string",
			input:    "",
			expected: "",
		},
		{
			name:     "single colon",
			input:    "Just a : colon",
			expected: "Just a : colon",
		},
		{
			name:     "incomplete emoji",
			input:    "Incomplete :abc",
			expected: "Incomplete :abc",
		},
		{
			name:     "invalid characters in emoji",
			input:    ":invalid@emoji:",
			expected: ":invalid@emoji:",
		},
		{
			name:     "very long text",
			input:    strings.Repeat("test :smile: ", 1000),
			expected: strings.Repeat("test 😄 ", 1000),
		},
	}

	for _, tt := range tests {
		suite.Run(tt.name, func() {
			result := suite.processor.Process(tt.input)
			assert.Equal(suite.T(), tt.expected, result, "Input: %q", tt.input)
		})
	}
}

// TestReadmeExamples tests the examples from the README
func (suite *ProcessorTestSuite) TestReadmeExamples() {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{
			name:     "readme example 1",
			input:    "Hey, I just :raising_hand: you, and this is :scream: , but here's my :calling: , so :telephone_receiver: me, maybe?",
			expected: "Hey, I just 🙋 you, and this is 😱 , but here's my 📲 , so 📞 me, maybe?",
		},
		{
			name:     "readme example 2",
			input:    "To :bee: , or not to :bee: : that is the question... To take :muscle: against a :ocean: of troubles, and by opposing, end them?",
			expected: "To 🐝 , or not to 🐝 : that is the question... To take 💪 against a 🌊 of troubles, and by opposing, end them?",
		},
	}

	for _, tt := range tests {
		suite.Run(tt.name, func() {
			result := suite.processor.Process(tt.input)
			assert.Equal(suite.T(), tt.expected, result, "Input: %q", tt.input)
		})
	}
}

// TestSpecialCharacters tests emojis with special characters
func (suite *ProcessorTestSuite) TestSpecialCharacters() {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{
			name:     "plus signs",
			input:    ":+1: thumbs up",
			expected: "👍 thumbs up",
		},
		{
			name:     "minus signs",
			input:    ":-1: thumbs down",
			expected: "👎 thumbs down",
		},
		{
			name:     "numbers",
			input:    ":1st_place_medal: first place",
			expected: "🥇 first place",
		},
		{
			name:     "mixed special chars",
			input:    ":+1: and :-1: and :100:",
			expected: "👍 and 👎 and 💯",
		},
	}

	for _, tt := range tests {
		suite.Run(tt.name, func() {
			result := suite.processor.Process(tt.input)
			assert.Equal(suite.T(), tt.expected, result, "Input: %q", tt.input)
		})
	}
}

// TestPerformance tests performance with large inputs
func (suite *ProcessorTestSuite) TestPerformance() {
	// Large input with many emojis
	input := strings.Repeat("Hello :smile: world :heart: test :rocket: ", 10000)

	result := suite.processor.Process(input)

	// Should complete without timeout and produce correct result
	assert.Contains(suite.T(), result, "😄")
	assert.Contains(suite.T(), result, "❤️")
	assert.Contains(suite.T(), result, "🚀")
	assert.NotContains(suite.T(), result, ":smile:")
	assert.NotContains(suite.T(), result, ":heart:")
	assert.NotContains(suite.T(), result, ":rocket:")
}

// TestConvenienceFunction tests the package-level Process function
func (suite *ProcessorTestSuite) TestConvenienceFunction() {
	result := Process("Hello :wink:")
	expected := "Hello 😉"
	assert.Equal(suite.T(), expected, result)
}

// TestProcessorCreation tests processor creation
func (suite *ProcessorTestSuite) TestProcessorCreation() {
	processor := NewProcessor()
	require.NotNil(suite.T(), processor)

	// Test that multiple processors work independently
	processor1 := NewProcessor()
	processor2 := NewProcessor()

	result1 := processor1.Process("Test :smile:")
	result2 := processor2.Process("Test :smile:")

	assert.Equal(suite.T(), result1, result2)
}

// TestListEmojis tests the ListEmojis function
func (suite *ProcessorTestSuite) TestListEmojis() {
	// This should not panic and should return without error
	err := ListEmojis()
	assert.NoError(suite.T(), err)
}

// TestBasicDecoding tests basic emoji decoding functionality
func (suite *ProcessorTestSuite) TestBasicDecoding() {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{
			name:     "no emoji",
			input:    "no emoji :(",
			expected: "no emoji :(",
		},
		{
			name:     "single emoji",
			input:    "an emoji 😁",
			expected: "an emoji :grin:",
		},
		{
			name:     "multiple emojis",
			input:    "emojis 😁😁 🎉",
			expected: "emojis :grin::grin: :tada:",
		},
		{
			name:     "mixed text and emojis",
			input:    "this is perfect 💯",
			expected: "this is perfect :100:",
		},
		{
			name:     "complex example",
			input:    "Deploy completed 🚀 💯",
			expected: "Deploy completed :rocket: :100:",
		},
		{
			name:     "empty string",
			input:    "",
			expected: "",
		},
		{
			name:     "emoji with skin tones",
			input:    "waving 👋🏻",
			expected: "waving :wave_tone1:",
		},
	}

	for _, test := range tests {
		suite.Run(test.name, func() {
			result := suite.processor.Decode(test.input)
			assert.Equal(suite.T(), test.expected, result)
		})
	}
}

// TestConvenienceDecodeFunction tests the package-level Decode function
func (suite *ProcessorTestSuite) TestConvenienceDecodeFunction() {
	input := "Hello 😄 world 🚀"
	expected := "Hello :smile: world :rocket:"
	result := Decode(input)
	assert.Equal(suite.T(), expected, result)
}

// TestRoundTripConversion tests encode -> decode -> encode round trip
func (suite *ProcessorTestSuite) TestRoundTripConversion() {
	tests := []string{
		"Deploy completed :rocket: :100:",
		"Hello :smile: world :heart:",
		":grin: :tada: :champagne:",
		"Mix of text :wave: and emoji",
	}

	for _, original := range tests {
		suite.Run("round trip: "+original, func() {
			// Original -> Encode -> Decode -> Should match original
			encoded := suite.processor.Process(original)
			decoded := suite.processor.Decode(encoded)
			assert.Equal(suite.T(), original, decoded)
		})
	}
}

// TestDecodePerformance tests decode performance with large text
func (suite *ProcessorTestSuite) TestDecodePerformance() {
	// Create a large string with many emojis
	largeText := strings.Repeat("Hello 😄 world 🚀 test 💯 ", 1000)

	// This should complete without hanging or taking too long
	result := suite.processor.Decode(largeText)

	// Verify it actually decoded something
	assert.Contains(suite.T(), result, ":smile:")
	assert.Contains(suite.T(), result, ":rocket:")
	assert.Contains(suite.T(), result, ":100:")
	assert.NotContains(suite.T(), result, "😄")
	assert.NotContains(suite.T(), result, "🚀")
	assert.NotContains(suite.T(), result, "💯")
}

// TestDecodeEdgeCases tests edge cases for decoding
func (suite *ProcessorTestSuite) TestDecodeEdgeCases() {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{
			name:     "only emoji",
			input:    "😄",
			expected: ":smile:",
		},
		{
			name:     "emoji at start",
			input:    "😄 hello",
			expected: ":smile: hello",
		},
		{
			name:     "emoji at end",
			input:    "hello 😄",
			expected: "hello :smile:",
		},
		{
			name:     "consecutive emojis",
			input:    "😄🚀💯",
			expected: ":smile::rocket::100:",
		},
		{
			name:     "emoji with punctuation",
			input:    "Great! 😄, amazing 🚀.",
			expected: "Great! :smile:, amazing :rocket:.",
		},
		{
			name:     "unicode text with emoji",
			input:    "Café 😄 naïve 🚀",
			expected: "Café :smile: naïve :rocket:",
		},
	}

	for _, test := range tests {
		suite.Run(test.name, func() {
			result := suite.processor.Decode(test.input)
			assert.Equal(suite.T(), test.expected, result)
		})
	}
}

// TestProcessor_Process runs the main processor tests
func TestProcessor_Process(t *testing.T) {
	suite.Run(t, new(ProcessorTestSuite))
}
