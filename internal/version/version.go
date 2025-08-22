package version

var (
	// Version is the current version of emojify-go
	Version string = "1.0.0"

	// Commit is the git commit hash at build time
	Commit string

	// Date is the build date
	Date string

	// BuiltBy is the builder identifier
	BuiltBy string = "goreleaser"
)
