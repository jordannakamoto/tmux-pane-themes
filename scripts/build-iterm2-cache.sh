#!/usr/bin/env bash

# Build pre-converted cache of all iTerm2 themes
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OUTPUT_FILE="$CURRENT_DIR/../themes/iterm2.conf"

echo "# Pre-converted iTerm2 themes" > "$OUTPUT_FILE"
echo "# Format: theme-name|bg=#hexcolor,fg=#hexcolor|display-name" >> "$OUTPUT_FILE"

curl -s "https://api.github.com/repos/mbadolato/iTerm2-Color-Schemes/contents/schemes" | \
grep '"download_url"' | \
sed 's/.*"download_url": "//g' | \
sed 's/".*//g' | \
while IFS= read -r url; do
    theme=$(basename "$url" .itermcolors)
    echo "Processing $theme..."

    temp_file="/tmp/${theme}.itermcolors"
    curl -s "$url" -o "$temp_file"

    if [ -f "$temp_file" ]; then
        colors=$("$CURRENT_DIR/convert-iterm2-theme.sh" "$temp_file" 2>/dev/null)
        if [ -n "$colors" ]; then
            echo "$theme|$colors|$theme" >> "$OUTPUT_FILE"
        fi
        rm -f "$temp_file"
    fi
done

echo "Done! Generated $OUTPUT_FILE with $(grep -v '^#' "$OUTPUT_FILE" | wc -l) themes"
