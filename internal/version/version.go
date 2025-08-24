package version

var (
	// Version is the current version of emojify-go.
	// This is set at build time using ldflags.
	Version string = "dev"

	// Commit is the git commit hash at build time.
	Commit string = "n/a"

	// Date is the build date.
	Date string = "unknown"

	// BuiltBy is the builder identifier.
	BuiltBy string = "local"
)
