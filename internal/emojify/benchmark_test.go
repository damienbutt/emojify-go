package emojify

import (
	"strings"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/damienbutt/emojify-go/internal/emoji"
)

// Benchmark tests for performance measurement

func BenchmarkProcessor_Process_NoEmojis(b *testing.B) {
	processor := NewProcessor()
	text := "This is a long text without any emojis that should be processed quickly without any replacements being made."

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		processor.Process(text)
	}
}

func BenchmarkProcessor_Process_SingleEmoji(b *testing.B) {
	processor := NewProcessor()
	text := "Hello :smile: world"

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		processor.Process(text)
	}
}

func BenchmarkProcessor_Process_MultipleEmojis(b *testing.B) {
	processor := NewProcessor()
	text := "Hello :smile: world :heart: test :rocket: performance :100: benchmark :tada:"

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		processor.Process(text)
	}
}

func BenchmarkProcessor_Process_LargeText(b *testing.B) {
	processor := NewProcessor()
	text := strings.Repeat("Hello :smile: world :heart: test :rocket: ", 1000)

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		processor.Process(text)
	}
}

func BenchmarkProcessor_Process_ManySmallEmojis(b *testing.B) {
	processor := NewProcessor()
	text := strings.Repeat(":+1:", 1000)

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		processor.Process(text)
	}
}

func BenchmarkProcessor_Process_ComplexEmojis(b *testing.B) {
	processor := NewProcessor()
	text := "Complex test :1st_place_medal: :raising_hand: :telephone_receiver: :champagne: :100:"

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		processor.Process(text)
	}
}

func BenchmarkGetEmoji_Hit(b *testing.B) {
	alias := ":smile:"

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		emoji.GetEmoji(alias)
	}
}

func BenchmarkGetEmoji_Miss(b *testing.B) {
	alias := ":nonexistent_emoji:"

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		emoji.GetEmoji(alias)
	}
}

func BenchmarkIsValidEmojiChar(b *testing.B) {
	chars := []rune{'a', 'Z', '9', '_', '+', '-', '@', ' ', '!'}

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		for _, char := range chars {
			emoji.IsValidEmojiChar(char)
		}
	}
}

func BenchmarkHasEmoji_WithEmoji(b *testing.B) {
	text := "This text has :emoji: in it"

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		emoji.HasEmoji(text)
	}
}

func BenchmarkHasEmoji_WithoutEmoji(b *testing.B) {
	text := "This text has no emojis"

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		emoji.HasEmoji(text)
	}
}

func BenchmarkListAllEmojis(b *testing.B) {
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		emoji.ListAllEmojis()
	}
}

// Memory allocation benchmarks

func BenchmarkProcessor_Process_Allocs(b *testing.B) {
	processor := NewProcessor()
	text := "Hello :smile: world :heart: test"

	b.ReportAllocs()
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		processor.Process(text)
	}
}

func BenchmarkProcessor_Process_LargeText_Allocs(b *testing.B) {
	processor := NewProcessor()
	text := strings.Repeat("Hello :smile: world ", 1000)

	b.ReportAllocs()
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		processor.Process(text)
	}
}

// Comparison benchmarks to measure against simple string replacement

func BenchmarkStringReplace_Single(b *testing.B) {
	text := "Hello :smile: world"

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		result := strings.ReplaceAll(text, ":smile:", "😄")
		_ = result
	}
}

func BenchmarkStringReplace_Multiple(b *testing.B) {
	text := "Hello :smile: world :heart: test"

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		result := text
		result = strings.ReplaceAll(result, ":smile:", "😄")
		result = strings.ReplaceAll(result, ":heart:", "❤️")
		_ = result
	}
}

// Stress tests

func BenchmarkProcessor_Process_VeryLargeText(b *testing.B) {
	processor := NewProcessor()
	// Create a 1MB string with emojis
	text := strings.Repeat("Hello :smile: world :heart: this is a longer text with multiple emojis :rocket: :100: :tada: ", 12000)
	require.True(b, len(text) > 1000000, "Text should be over 1MB")

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		processor.Process(text)
	}
}

func BenchmarkProcessor_Process_ManyUniqueEmojis(b *testing.B) {
	processor := NewProcessor()
	// Use many different emojis to test map lookup performance
	text := ":100: :smile: :heart: :rocket: :tada: :thumbsup: :thumbsdown: :fire: :star: :moon: " +
		":sun: :cloud: :rain: :snow: :airplane: :car: :bike: :bus: :train: :ship: " +
		":house: :tree: :flower: :apple: :banana: :pizza: :burger: :coffee: :beer: :wine:"

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		processor.Process(text)
	}
}
