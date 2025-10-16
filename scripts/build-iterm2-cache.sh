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
    # URL decode the theme name
    theme_decoded=$(echo "$theme" | sed 's/%20/ /g' | sed 's/%28/(/g' | sed 's/%29/)/g' | sed 's/%2B/+/g')
    echo "Processing $theme_decoded..."

    temp_file="/tmp/theme_$$.itermcolors"
    if curl -s "$url" -o "$temp_file" 2>/dev/null && [ -s "$temp_file" ]; then
        colors=$("$CURRENT_DIR/convert-iterm2-theme.sh" "$temp_file" 2>/dev/null)
        if [ -n "$colors" ]; then
            echo "$theme_decoded|$colors|$theme_decoded" >> "$OUTPUT_FILE"
        fi
        rm -f "$temp_file"
    fi
done

echo "Done! Generated $OUTPUT_FILE with $(grep -v '^#' "$OUTPUT_FILE" | wc -l) themes"
