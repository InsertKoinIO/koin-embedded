#!/bin/bash

REPO_BLOCK_FILE="repository.gradle"

if [ ! -f "$REPO_BLOCK_FILE" ]; then
    echo "Error: $REPO_BLOCK_FILE not found!"
    exit 1
fi

echo "Injecting repository block into all publish*.gradle.kts files in $KOIN_DIR/projects/gradle ..."

# Debug: List target files
echo "Files to process:"
ls "$KOIN_DIR/projects/gradle"/publish*.gradle.kts

for file in "$KOIN_DIR/projects/gradle"/publish*.gradle.kts; do
    if [ -f "$file" ]; then
        echo "Processing file: $file"
        # Check if the file already contains a repositories block.
        if ! grep -q 'repositories {' "$file"; then
            # Use a flexible pattern to match the line that starts with optional whitespace followed by
            # configure<PublishingExtension> and an opening curly brace.
            sed -i.bak '/^[[:space:]]*configure<PublishingExtension>[[:space:]]*{/r '"$REPO_BLOCK_FILE" "$file"
            rm "$file.bak"
            echo "Injected repository block into $file"
        else
            echo "File $file already contains a repositories block; skipping."
        fi
    else
        echo "No file found at: $file"
    fi
done

echo "Repository updated."
