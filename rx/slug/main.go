// Build with: go build -o slug main.go
// Install: cp slug ~/.local/bin/slug
// Or: go install (if in a proper Go module)

package main

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"unicode"
)

type Config struct {
	verbose   bool
	dryRun    bool
	delimiter string
}

func (c *Config) logVerbose(msg string) {
	if c.verbose {
		fmt.Println(msg)
	}
}

func slugifyFilename(input, delimiter string) string {
	dir := filepath.Dir(input)
	if dir == "." {
		dir = ""
	}

	base := filepath.Base(input)
	ext := filepath.Ext(base)
	if ext != "" {
		base = strings.TrimSuffix(base, ext)
	}

	// Convert to lowercase and replace non-alphanumeric with delimiter
	var result strings.Builder
	lastWasDelimiter := true // Start as true to avoid leading delimiters

	for _, r := range base {
		if unicode.IsLetter(r) || unicode.IsDigit(r) {
			result.WriteRune(unicode.ToLower(r))
			lastWasDelimiter = false
		} else if !lastWasDelimiter {
			result.WriteString(delimiter)
			lastWasDelimiter = true
		}
	}

	// Remove trailing delimiter
	slug := strings.TrimSuffix(result.String(), delimiter)

	// Add extension back
	if ext != "" {
		slug += ext
	}

	// Add directory back
	if dir != "" {
		slug = filepath.Join(dir, slug)
	}

	return slug
}

func handleDuplicates(targetPath string) string {
	if _, err := os.Stat(targetPath); os.IsNotExist(err) {
		return targetPath
	}

	dir := filepath.Dir(targetPath)
	base := filepath.Base(targetPath)
	ext := filepath.Ext(base)
	
	if ext != "" {
		base = strings.TrimSuffix(base, ext)
	}

	counter := 1
	for {
		var newName string
		if ext != "" {
			newName = fmt.Sprintf("%s-%d%s", base, counter, ext)
		} else {
			newName = fmt.Sprintf("%s-%d", base, counter)
		}

		newPath := filepath.Join(dir, newName)
		if _, err := os.Stat(newPath); os.IsNotExist(err) {
			return newPath
		}
		counter++
	}
}

func printUsage() {
	fmt.Printf(`usage: %s [options] source_file ...
  -h, --help            Show this help
  -v, --verbose         Verbose mode (show rename actions)
  -n, --dry-run         Dry run mode (no changes, implies -v)
  -u, --underscore      Use underscores instead of hyphens as delimiter
`, os.Args[0])
}

func main() {
	var config Config
	var showHelp bool
	var useUnderscore bool

	flag.BoolVar(&showHelp, "h", false, "Show help")
	flag.BoolVar(&showHelp, "help", false, "Show help")
	flag.BoolVar(&config.verbose, "v", false, "Verbose mode")
	flag.BoolVar(&config.verbose, "verbose", false, "Verbose mode")
	flag.BoolVar(&config.dryRun, "n", false, "Dry run mode")
	flag.BoolVar(&config.dryRun, "dry-run", false, "Dry run mode")
	flag.BoolVar(&useUnderscore, "u", false, "Use underscores")
	flag.BoolVar(&useUnderscore, "underscore", false, "Use underscores")

	flag.Parse()

	if showHelp {
		printUsage()
		os.Exit(0)
	}

	// Set delimiter
	config.delimiter = "-"
	if useUnderscore {
		config.delimiter = "_"
	}

	// Dry run implies verbose
	if config.dryRun {
		config.verbose = true
	}

	files := flag.Args()
	if len(files) == 0 {
		printUsage()
		os.Exit(1)
	}

	for _, file := range files {
		if _, err := os.Stat(file); os.IsNotExist(err) {
			fmt.Fprintf(os.Stderr, "ERROR: File '%s' not found.\n", file)
			continue
		}

		slug := slugifyFilename(file, config.delimiter)
		finalPath := handleDuplicates(slug)

		if config.dryRun {
			fmt.Printf("Would rename: %s -> %s\n", file, finalPath)
		} else {
			if err := os.Rename(file, finalPath); err != nil {
				fmt.Fprintf(os.Stderr, "ERROR: Failed to rename '%s' to '%s': %v\n", file, finalPath, err)
			} else {
				config.logVerbose(fmt.Sprintf("Renamed: %s -> %s", file, finalPath))
			}
		}
	}
}