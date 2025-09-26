# fabric_automation Bash Function Specification

## Purpose
Create a modular Bash function to streamline the use of `fabric` (from github.com/danielmiessler/fabric) and `yt-dlp` (from github.com/yt-dlp/yt-dlp) for processing YouTube videos.

## Function Name
`fabric_automation`

## Inputs
1. URL as the first argument (required)
   - Example: `"https://youtu.be/U_3aezlmiJs"`
   - No default URL provided

2. Pattern name as the second argument (optional)
   - Example: `"pattern-name-1"`
   - If not provided, prompt the user to select a pattern using `fzf`
   - `fzf` should list only the immediate subdirectories (depth-1) in `~/.config/fabric/patterns/` (e.g., `pattern-name-1`, not their contents like `system.md`)

## Core Behavior
1. Use `yt-dlp` to extract the video’s title (`videoTitle`) and ID (`videoID`) before running `fabric`
   - Extract using `yt-dlp -o "%(title)s:::%(id)s" --get-filename` with `::: ` as a reliable separator (to handle colons in titles, which are illegal in filenames on macOS/Linux)
   - Print debug output to the terminal showing the extracted title and ID to verify correct extraction

2. Check the success log (`~/.config/log/fabric_automation_success.log`) before proceeding:
   - If the log exists and the `videoID` is found, inform the user of the parent directory it was downloaded to and ask if they want to continue
   - If "no," ask if they want to create the markdown file (if it doesn’t exist); if "no" to both, exit with a log entry in the error log: `YYYY-MM-DD HH:MM:SS - Error: User cancelled <videoID>`
   - If "yes," proceed normally (overwriting existing files); if the log doesn’t exist, continue as normal

3. Determine the output directory:
   - Check if `/Volumes/armor/didact/YT` exists; use it as the parent directory if it does
   - Fallback to `/Volumes/Samsung USB/YT` if the first doesn’t exist
   - Otherwise, use the current working directory (`/pwd/`); do not create parent directories if they don’t exist
   - Create a subdirectory `<video-title-slug>` under the chosen parent directory if it doesn’t exist

4. Run `fabric` with the specified URL and pattern:
   - Command: `fabric -y "URL" -p "pattern-name"` (per github.com/danielmiessler/fabric)
   - Pipe output to a markdown file in the format specified below

5. Download the video using `yt-dlp` with:
   - Preferred resolution: 1080p (highest priority)
   - Fallback: 720p, then the next highest available resolution
   - Audio: AAC
   - Container: MP4
   - Use format filters like `bestvideo[height<=1080]+bestaudio[ext=aac]` to achieve this

## Output File Naming
1. Slugify titles and pattern names:
   - Convert to lowercase alphanumeric, collapsing all non-alphanumeric characters (spaces, underscores, punctuation, emojis, etc.) into a single hyphen
   - Example: `"My   Super-_-Awesome---Video_Title!"` → `"my-super-awesome-video-title"`
   - Pattern name example: `"pattern_name_1"` → `"pattern-name-1"`
   - Remove non-ASCII characters; preserve extensions and `videoID` (do not slug `videoID`)

2. Output files should follow this naming pattern:
   - Markdown file: `<parent_dir>/<video-title-slug>/<video-title-slug>-<pattern-slug>-<videoID>.md`
   - Video file: `<parent_dir>/<video-title-slug>/<video-title-slug>-<pattern-slug>-<videoID>.mp4`

## Error Handling
1. Capture `stderr` from `yt-dlp` and `fabric`
2. Log errors to `$HOME/.config/log/fabric_automation.log`
3. Format log entries with timestamp: `YYYY-MM-DD HH:MM:SS - Error: ...`
4. Clean up temporary error files properly

## Success Logging
1. Log successful completions to `$HOME/.config/log/fabric_automation_success.log`
2. Format: `YYYY-MM-DD HH:MM:SS - Success: <videoID> - <parent_dir>`
3. Create the log and its directory (`~/.config/log/`) if they don’t exist
4. Write the success log entry only after the command completes without errors

## Assumptions
1. `fabric`, `yt-dlp`, and `fzf` are already installed
2. Function will be used in `zsh` but written in Bash for maximum compatibility
3. Function should work in both macOS and Linux environments
4. `fabric` runs as `fabric -y "URL" -p "pattern-name" > <markdown_file>` where `-y` is for the YouTube URL and `-p` is the pattern name
5. The environment is set up globally, so `fabric` can be run directly without additional paths or flags

## Usage Examples
```bash
fabric_automation "https://youtu.be/U_3aezlmiJs" "pattern-name-1"
fabric_automation "https://youtu.be/U_3aezlmiJs"  # Prompts for pattern via fzf
```

## Implementation Features
1. Modular design with separate functions for common tasks (e.g., slugification, directory selection)
2. Proper error handling and reporting
3. Consistent naming conventions
4. Debugging output to the terminal for extracted video title and ID
5. Safe handling of special characters in video titles for macOS/Linux compatibility

---

### Notes on Changes
- Clarified `fzf` to list only depth-1 subdirectory names in `~/.config/fabric/patterns/`.
- Specified slugification to collapse all non-alphanumeric characters into a single hyphen.
- Confirmed no parent directory creation; `<video-title-slug>` is created in `pwd` if needed.
- Added logic for success log checking and user prompts for continuation or markdown creation.
- Updated `fabric` command syntax and output redirection based on your confirmation.
- Specified debug output to the terminal for title/ID verification.
