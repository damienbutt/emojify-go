package tests

import (
	"bytes"
	"io"
	"os"
	"os/exec"
	"runtime"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/stretchr/testify/suite"

	"github.com/damienbutt/emojify-go/internal/emojify"
)

// IntegrationTestSuite defines the integration test suite
type IntegrationTestSuite struct {
	suite.Suite
	binaryPath string
}

// SetupSuite builds the binary before running tests
func (suite *IntegrationTestSuite) SetupSuite() {
	var cmd *exec.Cmd
	var binaryName string

	// Determine binary name based on OS
	if runtime.GOOS == "windows" {
		binaryName = "emojify.exe"
	} else {
		binaryName = "emojify"
	}

	// Try to use Makefile first (Unix systems), fallback to direct go build
	if runtime.GOOS != "windows" {
		// Unix systems: use Makefile
		cmd = exec.Command("make", "build")
		cmd.Dir = ".."
		err := cmd.Run()
		if err == nil {
			suite.binaryPath = "../build/" + binaryName
			return
		}
		// If make fails, fall through to go build
	}

	// Windows or make failed: use direct go build
	cmd = exec.Command("go", "build", "-o", "build/"+binaryName, "./cmd/emojify")
	cmd.Dir = ".."
	err := cmd.Run()
	require.NoError(suite.T(), err, "Failed to build binary")

	suite.binaryPath = "../build/" + binaryName
}

// TearDownSuite cleans up after tests
func (suite *IntegrationTestSuite) TearDownSuite() {
	// If we built the binary directly (not via Makefile), clean it up
	if strings.Contains(suite.binaryPath, "../build/") {
		// Check if this was built via go build (not make)
		if runtime.GOOS == "windows" {
			// On Windows, we always use go build, so clean up
			os.Remove(suite.binaryPath)
		}
		// On Unix, the Makefile manages the build directory, so we don't clean up
	}
}

// TestCommandLineArguments tests processing command line arguments
func (suite *IntegrationTestSuite) TestCommandLineArguments() {
	tests := []struct {
		name     string
		args     []string
		expected string
	}{
		{
			name:     "single argument",
			args:     []string{"Hello :wink: world"},
			expected: "Hello 😉 world\n",
		},
		{
			name:     "multiple arguments",
			args:     []string{"Hello", ":smile:", "world", ":heart:"},
			expected: "Hello 😄 world ❤️\n",
		},
		{
			name:     "complex emojis",
			args:     []string{"Test :100: :+1: :-1:"},
			expected: "Test 💯 👍 👎\n",
		},
		{
			name:     "no emojis",
			args:     []string{"Just plain text"},
			expected: "Just plain text\n",
		},
		{
			name:     "empty argument",
			args:     []string{""},
			expected: "",
		},
	}

	for _, tt := range tests {
		suite.Run(tt.name, func() {
			cmd := exec.Command(suite.binaryPath, tt.args...)
			output, err := cmd.Output()

			require.NoError(suite.T(), err, "Command should not fail")
			assert.Equal(suite.T(), tt.expected, string(output))
		})
	}
}

// TestStdinProcessing tests processing input from stdin
func (suite *IntegrationTestSuite) TestStdinProcessing() {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{
			name:     "single line",
			input:    "Hello :smile: world",
			expected: "Hello 😄 world",
		},
		{
			name:     "multiple lines",
			input:    "Line 1 :100:\nLine 2 :rocket:\nLine 3 :heart:",
			expected: "Line 1 💯\nLine 2 🚀\nLine 3 ❤️",
		},
		{
			name:     "empty input",
			input:    "",
			expected: "",
		},
		{
			name:     "no emojis",
			input:    "Just plain text\nAnother line",
			expected: "Just plain text\nAnother line",
		},
		{
			name:     "mixed content",
			input:    "Plain line\nEmoji line :tada:\nAnother plain line",
			expected: "Plain line\nEmoji line 🎉\nAnother plain line",
		},
	}

	for _, tt := range tests {
		suite.Run(tt.name, func() {
			cmd := exec.Command(suite.binaryPath)
			cmd.Stdin = strings.NewReader(tt.input)

			output, err := cmd.Output()
			require.NoError(suite.T(), err, "Command should not fail")
			assert.Equal(suite.T(), tt.expected, string(output))
		})
	}
}

// TestFormatPreservation tests that the tool preserves exact input format
func (suite *IntegrationTestSuite) TestFormatPreservation() {
	tests := []struct {
		name        string
		input       string
		description string
	}{
		{
			name:        "no trailing newline",
			input:       "test :smile:",
			description: "Input without newline should output without newline",
		},
		{
			name:        "with trailing newline",
			input:       "test :smile:\n",
			description: "Input with newline should output with newline",
		},
		{
			name:        "multiple lines no final newline",
			input:       "line1 :100:\nline2 :rocket:",
			description: "Multi-line input without final newline preserved",
		},
		{
			name:        "multiple lines with final newline",
			input:       "line1 :100:\nline2 :rocket:\n",
			description: "Multi-line input with final newline preserved",
		},
		{
			name:        "empty string",
			input:       "",
			description: "Empty input should produce empty output",
		},
		{
			name:        "only newline",
			input:       "\n",
			description: "Single newline should be preserved",
		},
		{
			name:        "multiple newlines",
			input:       "\n\n\n",
			description: "Multiple newlines should be preserved",
		},
		{
			name:        "text with internal newlines",
			input:       "a\n\nb\n\nc",
			description: "Internal newlines should be preserved exactly",
		},
	}

	for _, tt := range tests {
		suite.Run(tt.name, func() {
			cmd := exec.Command(suite.binaryPath)
			cmd.Stdin = strings.NewReader(tt.input)

			output, err := cmd.Output()
			require.NoError(suite.T(), err, "Command should not fail")

			// Process expected output through emoji processor for comparison
			expected := emojify.Process(tt.input)

			assert.Equal(suite.T(), expected, string(output), tt.description)

			// Also verify byte length is exactly what we expect
			assert.Equal(suite.T(), len(expected), len(output),
				"Output byte length should match expected length for: %s", tt.description)
		})
	}
}

// TestBytePreservation tests exact byte count preservation
func (suite *IntegrationTestSuite) TestBytePreservation() {
	tests := []struct {
		name           string
		input          string
		expectedChange int // How many bytes the emoji substitution should change
	}{
		{
			name:           "no emojis",
			input:          "hello world",
			expectedChange: 0, // No change expected
		},
		{
			name:           "single emoji",
			input:          "hello :smile:",
			expectedChange: -3, // ":smile:" (7 chars) -> "😄" (4 chars in UTF-8)
		},
		{
			name:           "multiple emojis",
			input:          ":100: :+1:",
			expectedChange: -1, // ":100:" (5->4) + " " (1) + ":+1:" (4->4) = 10->9
		},
		{
			name:           "emoji with newlines",
			input:          "test :smile:\nworld",
			expectedChange: -3, // Only the emoji changes
		},
	}

	for _, tt := range tests {
		suite.Run(tt.name, func() {
			cmd := exec.Command(suite.binaryPath)
			cmd.Stdin = strings.NewReader(tt.input)

			output, err := cmd.Output()
			require.NoError(suite.T(), err, "Command should not fail")

			inputLen := len(tt.input)
			outputLen := len(output)
			actualChange := outputLen - inputLen

			assert.Equal(suite.T(), tt.expectedChange, actualChange,
				"Byte count change should be exactly %d (input: %d bytes, output: %d bytes)",
				tt.expectedChange, inputLen, outputLen)
		})
	}
}

// TestCommandLineFormatConsistency tests command line argument format
func (suite *IntegrationTestSuite) TestCommandLineFormatConsistency() {
	tests := []struct {
		name          string
		args          []string
		expectNewline bool
		description   string
	}{
		{
			name:          "empty argument",
			args:          []string{""},
			expectNewline: false,
			description:   "Empty argument should not add newline",
		},
		{
			name:          "non-empty argument",
			args:          []string{"hello :smile:"},
			expectNewline: true,
			description:   "Non-empty argument should add newline for CLI readability",
		},
		{
			name:          "multiple arguments",
			args:          []string{"hello", ":smile:", "world"},
			expectNewline: true,
			description:   "Multiple arguments should add newline",
		},
	}

	for _, tt := range tests {
		suite.Run(tt.name, func() {
			cmd := exec.Command(suite.binaryPath, tt.args...)
			output, err := cmd.Output()

			require.NoError(suite.T(), err, "Command should not fail")

			if tt.expectNewline {
				assert.True(suite.T(), strings.HasSuffix(string(output), "\n"),
					"Output should end with newline: %s", tt.description)
			} else {
				assert.False(suite.T(), strings.HasSuffix(string(output), "\n"),
					"Output should not end with newline: %s", tt.description)
			}
		})
	}
}

// TestVersionFlag tests the version flag
func (suite *IntegrationTestSuite) TestVersionFlag() {
	tests := []string{"-v", "--version"}

	for _, flag := range tests {
		suite.Run("version flag "+flag, func() {
			cmd := exec.Command(suite.binaryPath, flag)
			output, err := cmd.Output()

			require.NoError(suite.T(), err, "Version command should not fail")

			version := strings.TrimSpace(string(output))
			assert.NotEmpty(suite.T(), version, "Version should not be empty")
			assert.Regexp(suite.T(), `^\d+\.\d+\.\d+`, version, "Version should match semantic versioning")
		})
	}
}

// TestListFlag tests the list flag
func (suite *IntegrationTestSuite) TestListFlag() {
	tests := []string{"-l", "--list"}

	for _, flag := range tests {
		suite.Run("list flag "+flag, func() {
			cmd := exec.Command(suite.binaryPath, flag)
			output, err := cmd.Output()

			require.NoError(suite.T(), err, "List command should not fail")

			lines := strings.Split(string(output), "\n")

			// Should have many lines (over 2000 emojis)
			assert.Greater(suite.T(), len(lines), 2000, "Should list many emojis")

			// Check format of first few lines
			for i, line := range lines {
				if i >= 10 || line == "" { // Check first 10 non-empty lines
					break
				}

				// Each line should have format ":alias: emoji"
				parts := strings.Split(line, " ")
				assert.GreaterOrEqual(suite.T(), len(parts), 2, "Line should have at least alias and emoji: %s", line)
				assert.True(suite.T(), strings.HasPrefix(parts[0], ":"), "First part should start with colon: %s", line)
				assert.True(suite.T(), strings.HasSuffix(parts[0], ":"), "First part should end with colon: %s", line)
			}
		})
	}
}

// TestHelpFlag tests the help flag
func (suite *IntegrationTestSuite) TestHelpFlag() {
	tests := []string{"-h", "--help"}

	for _, flag := range tests {
		suite.Run("help flag "+flag, func() {
			cmd := exec.Command(suite.binaryPath, flag)
			output, err := cmd.Output()

			require.NoError(suite.T(), err, "Help command should not fail")

			help := string(output)
			assert.Contains(suite.T(), help, "emojify", "Help should mention emojify")
			assert.Contains(suite.T(), help, "emoji", "Help should mention emoji")
			assert.Contains(suite.T(), help, "USAGE", "Help should show usage")
		})
	}
}

// TestErrorCases tests error handling
func (suite *IntegrationTestSuite) TestErrorCases() {
	// Test invalid flag
	cmd := exec.Command(suite.binaryPath, "--invalid-flag")
	output, err := cmd.CombinedOutput()

	// Should exit with error
	assert.Error(suite.T(), err, "Invalid flag should cause error")
	assert.Contains(suite.T(), string(output), "flag", "Error message should mention flag")
}

// TestPipelineCompatibility tests compatibility with Unix pipelines
func (suite *IntegrationTestSuite) TestPipelineCompatibility() {
	// Test with echo
	cmd := exec.Command("sh", "-c", "echo 'Hello :smile: world' | "+suite.binaryPath)
	output, err := cmd.Output()

	require.NoError(suite.T(), err, "Pipeline should work")
	assert.Equal(suite.T(), "Hello 😄 world\n", string(output))

	// Test with multiple commands
	cmd = exec.Command("sh", "-c", "printf 'Line 1 :100:\\nLine 2 :rocket:' | "+suite.binaryPath+" | wc -l")
	output, err = cmd.Output()

	require.NoError(suite.T(), err, "Complex pipeline should work")
	lineCount := strings.TrimSpace(string(output))
	assert.Equal(suite.T(), "1", lineCount, "Should count 1 complete line (only first line ends with newline)")
}

// TestLargeInput tests handling of large input
func (suite *IntegrationTestSuite) TestLargeInput() {
	// Create large input
	largeInput := strings.Repeat("Hello :smile: world :heart: test :rocket:\n", 10000)

	cmd := exec.Command(suite.binaryPath)
	cmd.Stdin = strings.NewReader(largeInput)

	// Set up output capture
	var stdout bytes.Buffer
	cmd.Stdout = &stdout

	err := cmd.Run()
	require.NoError(suite.T(), err, "Large input should be processed without error")

	output := stdout.String()

	// Verify output
	assert.Contains(suite.T(), output, "😄", "Should contain smile emoji")
	assert.Contains(suite.T(), output, "❤️", "Should contain heart emoji")
	assert.Contains(suite.T(), output, "🚀", "Should contain rocket emoji")
	assert.NotContains(suite.T(), output, ":smile:", "Should not contain original aliases")

	// Count lines
	lines := strings.Split(strings.TrimSuffix(output, "\n"), "\n")
	assert.Equal(suite.T(), 10000, len(lines), "Should output same number of lines as input")
}

// TestBashCompatibility tests compatibility with the original bash version
func (suite *IntegrationTestSuite) TestBashCompatibility() {
	// Test cases that should match the bash version exactly
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{
			name:     "readme example 1",
			input:    "Hey, I just :raising_hand: you, and this is :scream: , but here's my :calling: , so :telephone_receiver: me, maybe?",
			expected: "Hey, I just 🙋 you, and this is 😱 , but here's my 📲 , so 📞 me, maybe?\n",
		},
		{
			name:     "bash test case",
			input:    "great :+1::+1::-1:",
			expected: "great 👍👍👎\n",
		},
		{
			name:     "edge case with colons",
			input:    "::::point_right:",
			expected: ":::👉\n",
		},
	}

	for _, tt := range tests {
		suite.Run(tt.name, func() {
			cmd := exec.Command(suite.binaryPath, tt.input)
			output, err := cmd.Output()

			require.NoError(suite.T(), err, "Command should not fail")
			assert.Equal(suite.T(), tt.expected, string(output))
		})
	}
}

// TestConcurrentAccess tests concurrent access to the binary
func (suite *IntegrationTestSuite) TestConcurrentAccess() {
	// Run multiple instances concurrently
	const numConcurrent = 10
	results := make(chan string, numConcurrent)
	errors := make(chan error, numConcurrent)

	for i := 0; i < numConcurrent; i++ {
		go func(id int) {
			cmd := exec.Command(suite.binaryPath, "Test :100: concurrent access")
			output, err := cmd.Output()
			if err != nil {
				errors <- err
				return
			}

			results <- string(output)
		}(i)
	}

	// Collect results
	for i := 0; i < numConcurrent; i++ {
		select {
		case result := <-results:
			assert.Equal(suite.T(), "Test 💯 concurrent access\n", result)
		case err := <-errors:
			suite.T().Errorf("Concurrent execution failed: %v", err)
		}
	}
}

// TestMemoryUsage tests memory usage with large inputs
func (suite *IntegrationTestSuite) TestMemoryUsage() {
	// This test ensures the program doesn't consume excessive memory
	largeInput := strings.Repeat("Test :smile: memory usage :heart:\n", 100000)

	cmd := exec.Command(suite.binaryPath)
	cmd.Stdin = strings.NewReader(largeInput)

	// Capture output but don't store it all in memory at once
	cmd.Stdout = io.Discard

	err := cmd.Run()
	assert.NoError(suite.T(), err, "Large input processing should not fail")
}

// TestDecodeFlag tests the --decode flag functionality
func (suite *IntegrationTestSuite) TestDecodeFlag() {
	tests := []struct {
		name     string
		args     []string
		expected string
	}{
		{
			name:     "single emoji decode",
			args:     []string{"--decode", "😄"},
			expected: ":smile:\n",
		},
		{
			name:     "multiple emoji decode",
			args:     []string{"--decode", "😄 🚀 💯"},
			expected: ":smile: :rocket: :100:\n",
		},
		{
			name:     "mixed text and emoji decode",
			args:     []string{"--decode", "Deploy completed 🚀 💯"},
			expected: "Deploy completed :rocket: :100:\n",
		},
		{
			name:     "no emoji to decode",
			args:     []string{"--decode", "Just plain text"},
			expected: "Just plain text\n",
		},
		{
			name:     "short flag",
			args:     []string{"-d", "Hello 😄 world"},
			expected: "Hello :smile: world\n",
		},
	}

	for _, tt := range tests {
		suite.Run(tt.name, func() {
			cmd := exec.Command(suite.binaryPath, tt.args...)
			output, err := cmd.Output()

			require.NoError(suite.T(), err, "Decode command should not fail")
			assert.Equal(suite.T(), tt.expected, string(output))
		})
	}
}

// TestEncodeFlag tests the --encode flag functionality
func (suite *IntegrationTestSuite) TestEncodeFlag() {
	tests := []struct {
		name     string
		args     []string
		expected string
	}{
		{
			name:     "explicit encode flag",
			args:     []string{"--encode", ":smile: :rocket:"},
			expected: "😄 🚀\n",
		},
		{
			name:     "short encode flag",
			args:     []string{"-e", "Hello :smile: world"},
			expected: "Hello 😄 world\n",
		},
		{
			name:     "encode should match default behavior",
			args:     []string{"--encode", "Deploy :rocket: :100:"},
			expected: "Deploy 🚀 💯\n",
		},
	}

	for _, tt := range tests {
		suite.Run(tt.name, func() {
			cmd := exec.Command(suite.binaryPath, tt.args...)
			output, err := cmd.Output()

			require.NoError(suite.T(), err, "Encode command should not fail")
			assert.Equal(suite.T(), tt.expected, string(output))
		})
	}
}

// TestMutuallyExclusiveFlags tests that --encode and --decode are mutually exclusive
func (suite *IntegrationTestSuite) TestMutuallyExclusiveFlags() {
	cmd := exec.Command(suite.binaryPath, "--encode", "--decode", "test")
	output, err := cmd.CombinedOutput()

	// Should exit with error
	assert.Error(suite.T(), err, "Command should fail with mutually exclusive flags")
	assert.Contains(suite.T(), string(output), "mutually exclusive", "Error should mention mutual exclusivity")
}

// TestDecodeStdinProcessing tests decoding input from stdin
func (suite *IntegrationTestSuite) TestDecodeStdinProcessing() {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{
			name:     "single emoji via stdin",
			input:    "😄",
			expected: ":smile:",
		},
		{
			name:     "multiple emojis via stdin",
			input:    "😄 🚀 💯",
			expected: ":smile: :rocket: :100:",
		},
		{
			name:     "mixed content via stdin",
			input:    "Deploy completed 🚀 💯",
			expected: "Deploy completed :rocket: :100:",
		},
		{
			name:     "multiline with emojis",
			input:    "Line 1 😄\nLine 2 🚀\nLine 3 💯",
			expected: "Line 1 :smile:\nLine 2 :rocket:\nLine 3 :100:",
		},
		{
			name:     "no emojis to decode",
			input:    "Just plain text",
			expected: "Just plain text",
		},
	}

	for _, tt := range tests {
		suite.Run(tt.name, func() {
			cmd := exec.Command(suite.binaryPath, "--decode")
			cmd.Stdin = strings.NewReader(tt.input)

			output, err := cmd.Output()
			require.NoError(suite.T(), err, "Decode stdin command should not fail")
			assert.Equal(suite.T(), tt.expected, string(output))
		})
	}
}

// TestRoundTripConversion tests encode -> decode round trip conversion
func (suite *IntegrationTestSuite) TestRoundTripConversion() {
	tests := []struct {
		name  string
		input string
	}{
		{
			name:  "simple case",
			input: "Hello :smile: world :rocket:",
		},
		{
			name:  "complex case",
			input: "Deploy completed :rocket: :100: :tada:",
		},
		{
			name:  "multiline",
			input: "Line 1 :smile:\nLine 2 :rocket:\nLine 3 :100:",
		},
		{
			name:  "mixed with text",
			input: "Great work team! :clap: The deployment :rocket: was perfect :100: Let's celebrate :tada:",
		},
	}

	for _, tt := range tests {
		suite.Run(tt.name, func() {
			// Step 1: Encode (aliases to emoji)
			encodeCmd := exec.Command(suite.binaryPath)
			encodeCmd.Stdin = strings.NewReader(tt.input)
			encoded, err := encodeCmd.Output()
			require.NoError(suite.T(), err, "Encode step should not fail")

			// Step 2: Decode (emoji back to aliases)
			decodeCmd := exec.Command(suite.binaryPath, "--decode")
			decodeCmd.Stdin = strings.NewReader(string(encoded))
			decoded, err := decodeCmd.Output()
			require.NoError(suite.T(), err, "Decode step should not fail")

			// Result should match original input
			assert.Equal(suite.T(), tt.input, string(decoded), "Round trip should preserve original input")
		})
	}
}

// TestFlagsBytePreservation tests that new flags preserve exact byte formatting
func (suite *IntegrationTestSuite) TestFlagsBytePreservation() {
	tests := []struct {
		name  string
		input string
		flags []string
	}{
		{
			name:  "encode flag no trailing newline",
			input: "test :smile:",
			flags: []string{"--encode"},
		},
		{
			name:  "decode flag no trailing newline",
			input: "test 😄",
			flags: []string{"--decode"},
		},
		{
			name:  "encode flag with newlines",
			input: "line1 :smile:\nline2 :rocket:\n",
			flags: []string{"--encode"},
		},
		{
			name:  "decode flag with newlines",
			input: "line1 😄\nline2 🚀\n",
			flags: []string{"--decode"},
		},
		{
			name:  "encode flag empty input",
			input: "",
			flags: []string{"--encode"},
		},
		{
			name:  "decode flag empty input",
			input: "",
			flags: []string{"--decode"},
		},
	}

	for _, tt := range tests {
		suite.Run(tt.name, func() {
			// Test with flags
			cmd := exec.Command(suite.binaryPath, tt.flags...)
			cmd.Stdin = strings.NewReader(tt.input)
			flagOutput, err := cmd.Output()
			require.NoError(suite.T(), err, "Command with flag should not fail")

			if tt.flags[0] == "--encode" {
				// Encode flag should match default behavior exactly
				defaultCmd := exec.Command(suite.binaryPath)
				defaultCmd.Stdin = strings.NewReader(tt.input)
				defaultOutput, err := defaultCmd.Output()
				require.NoError(suite.T(), err, "Default command should not fail")

				assert.Equal(suite.T(), defaultOutput, flagOutput,
					"--encode flag should produce identical output to default behavior")
			}

			// For non-empty inputs, verify output is not empty
			if len(tt.input) > 0 {
				assert.NotEmpty(suite.T(), flagOutput,
					"Output should not be empty for non-empty input with flag: %v", tt.flags[0])
			}

			// Verify that newlines and format are preserved
			// This is the key test for byte preservation
			if strings.HasSuffix(tt.input, "\n") {
				assert.True(suite.T(), strings.HasSuffix(string(flagOutput), "\n"),
					"Trailing newline should be preserved with flag: %v", tt.flags[0])
			} else if len(tt.input) > 0 {
				assert.False(suite.T(), strings.HasSuffix(string(flagOutput), "\n"),
					"No trailing newline should be added with flag: %v", tt.flags[0])
			}
		})
	}
}

// TestIntegration runs all integration tests
func TestIntegration(t *testing.T) {
	suite.Run(t, new(IntegrationTestSuite))
}
