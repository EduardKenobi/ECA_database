#!/bin/bash

# Base URL for downloading ZIP files
BASE_URL="https://knmi-ecad-assets-prd.s3.amazonaws.com/download"

# Function to download the latest ZIP file
download_latest_zip() {
    local file_type=$1
    local zip_file="ECA_nonblend_${file_type}.zip"
    local current_date=$(date +"%m%Y")
    local renamed_zip_file="ECA_nonblend_${file_type}_${current_date}.zip"

    # echo "Checking for the latest ZIP file for ${file_type}..."
    local latest_file=$(ls ECA_nonblend_${file_type}_*.zip 2>/dev/null | sort | tail -n 1)

    if [[ -n "$latest_file" ]]; then
        local latest_date=$(echo "$latest_file" | grep -oP '\d{6}')
        # echo "Latest available file: $latest_file with date: $latest_date"

        if [[ "$current_date" -gt "$latest_date" ]]; then
            # echo "Downloading new ZIP file for ${file_type}..."
            curl --progress-bar -o "$zip_file" "${BASE_URL}/${zip_file}"
            mv "$zip_file" "$renamed_zip_file"
            # echo "Renamed $zip_file to $renamed_zip_file"
        else
            renamed_zip_file="$latest_file"
        fi
    else
        # echo "No previous ZIP file found. Downloading the first one for ${file_type}..."
        curl --progress-bar -o "$zip_file" "${BASE_URL}/${zip_file}"
        mv "$zip_file" "$renamed_zip_file"
        # echo "Renamed $zip_file to $renamed_zip_file"
    fi

    echo "$renamed_zip_file"  # Output the renamed ZIP file
}

# Function to extract a specific file from the ZIP
extract_file_from_zip() {
    local zip_file=$1
    local target_file=$2
    local output_dir=$3

    echo "Extracting $target_file from $zip_file..."
    if [[ -f "$zip_file" ]]; then
        unzip -j -o "$zip_file" "$target_file" -d "$output_dir"
    else
        echo "Error: ZIP file $zip_file not found."
    fi
}

# Function to process a specific file type
process_file_type() {
    local file_type=$1
    local target_file=$2
    local original_file=$3
    local column_name=$4

    echo "Processing file type: $file_type"

    # Check if the original file exists
    if [[ ! -f "latest_valid_data/$original_file" ]]; then
        echo "Original file $original_file not found. Creating an empty file..."
        touch "latest_valid_data/$original_file"
    fi

    # Run the Python script to get the latest date from the original file
    local latest_orig_date=$(python check_latest_valid_date.py "latest_valid_data/$original_file" "$column_name")
    echo "Latest date in original file: $latest_orig_date"

    # Download the latest ZIP file
    local zip_file=$(download_latest_zip "$file_type")

    # Extract the target file from the ZIP
    extract_file_from_zip "$zip_file" "$target_file" "extracted_data"

    # Check if the extracted file exists
    if [[ ! -f "extracted_data/$target_file" ]]; then
        echo "Extracted file $target_file not found. Skipping..."
        return
    fi

    # Run the Python script to get the latest date from the new file
    local latest_new_date=$(python check_latest_valid_date.py "extracted_data/$target_file" "$column_name")
    echo "Latest date in new file: $latest_new_date"

    # Compare dates and update the original file if needed
    if [[ "$latest_new_date" > "$latest_orig_date" ]]; then
        echo "New data is more recent. Updating the original file..."
        cp "extracted_data/$target_file" "latest_valid_data/$original_file"
        echo "File updated: latest_valid_data/$original_file"
    else
        echo "No update needed. Original file is up-to-date."
    fi
}

# Main script logic
main() {
    # Define the file types and their corresponding target, original files, and column names
    declare -A file_mappings=(
        ["tx"]="TX_SOUID116298.txt:TX.txt:TX"
        ["tg"]="TG_SOUID116299.txt:TG.txt:TG"
        ["tn"]="TN_SOUID116297.txt:TN.txt:TN"
        ["rr"]="RR_SOUID116304.txt:RR.txt:RR"
    )

    for file_type in "${!file_mappings[@]}"; do
        IFS=":" read -r target_file original_file column_name <<< "${file_mappings[$file_type]}"
        process_file_type "$file_type" "$target_file" "$original_file" "$column_name"
    done
}

main "$@"