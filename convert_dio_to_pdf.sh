#!/bin/bash

# Script to convert all .dio, .dio.png, and .drawio files in a specified folder to PDF format
# Requires draw.io desktop application to be installed

# Find draw.io path on macOS (check common locations)
if [ -f "/Applications/draw.io.app/Contents/MacOS/draw.io" ]; then
    DRAWIO_PATH="/Applications/draw.io.app/Contents/MacOS/draw.io"
elif [ -f "/Applications/drawio.app/Contents/MacOS/drawio" ]; then
    DRAWIO_PATH="/Applications/drawio.app/Contents/MacOS/drawio"
elif [ -f "$HOME/Applications/draw.io.app/Contents/MacOS/draw.io" ]; then
    DRAWIO_PATH="$HOME/Applications/draw.io.app/Contents/MacOS/draw.io"
else
    echo "Error: draw.io application not found"
    echo ""
    echo "Please install draw.io using one of these methods:"
    echo "  1. Download from: https://www.drawio.com/"
    echo "  2. Using Homebrew: brew install --cask drawio"
    exit 1
fi

# Check if folder argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <folder_path> [output_folder]"
    echo "  folder_path  - Path to folder containing .dio, .dio.png, or .drawio files"
    echo "  output_folder - (Optional) Path to save PDF files (default: <input>/pdfs)"
    exit 1
fi

INPUT_FOLDER="$1"
OUTPUT_FOLDER="${2:-$INPUT_FOLDER/pdfs}"

# Check if input folder exists
if [ ! -d "$INPUT_FOLDER" ]; then
    echo "Error: Input folder '$INPUT_FOLDER' does not exist"
    exit 1
fi

# Create output folder if it doesn't exist
mkdir -p "$OUTPUT_FOLDER"

# Counter for converted files
converted=0
failed=0

echo "Converting .dio, .dio.png, and .drawio files from: $INPUT_FOLDER"
echo "Saving PDFs to: $OUTPUT_FOLDER"
echo "----------------------------------------"

# Find all .dio, .dio.png, and .drawio files and convert them
find "$INPUT_FOLDER" -maxdepth 1 \( -name "*.dio" -o -name "*.dio.png" -o -name "*.drawio" \) -type f | while read -r dio_file; do
    # Handle .dio, .dio.png, and .drawio extensions
    if [[ "$dio_file" == *.dio.png ]]; then
        filename=$(basename "$dio_file" .dio.png)
    elif [[ "$dio_file" == *.drawio ]]; then
        filename=$(basename "$dio_file" .drawio)
    else
        filename=$(basename "$dio_file" .dio)
    fi
    output_file="$OUTPUT_FOLDER/${filename}.pdf"
    
    echo "Converting: $(basename "$dio_file") -> $filename.pdf"
    
    # Run draw.io export command with --crop to remove empty space
    "$DRAWIO_PATH" --export --format pdf --crop --output "$output_file" "$dio_file" 2>/dev/null
    
    if [ $? -eq 0 ] && [ -f "$output_file" ]; then
        echo "  ✓ Success: $output_file"
        ((converted++))
    else
        echo "  ✗ Failed to convert: $dio_file"
        ((failed++))
    fi
done

echo "----------------------------------------"
echo "Conversion complete!"
echo "Files processed in: $INPUT_FOLDER"
