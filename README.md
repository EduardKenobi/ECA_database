
# ECAD Database Automation

This project automates the process of downloading, extracting, and updating climate data files from the KNMI ECAD database. The script ensures that the latest data is always available and updates the local files only when new data is detected.

## Features

- Downloads the latest ZIP files for specified data types.
- Extracts specific files from the downloaded ZIP archives.
- Compares the latest data with existing files and updates them if necessary.
- Supports multiple data types (e.g., temperature, precipitation).

## Prerequisites

- **Bash**: Ensure you have a Bash shell available.
- **Python**: Required for running the `check_latest_valid_date.py` script.
- **curl**: For downloading files.
- **unzip**: For extracting files from ZIP archives.

## File Structure

- `download_data.sh`: Main script for automating the data download and update process.
- `check_latest_valid_date.py`: Python script to determine the latest valid date in a file.
- `latest_valid_data/`: Directory containing the most up-to-date data files.
- `extracted_data/`: Temporary directory for storing extracted files.

## Usage

1. Clone or copy the project to your local machine.
2. Ensure the required tools (Bash, Python, curl, unzip) are installed.
3. Run the script:
   ```bash
   ./download_data.sh
   ```

## Configuration

The script processes the following data types by default:
- `tx`: Maximum temperature
- `tg`: Mean temperature
- `tn`: Minimum temperature
- `rr`: Precipitation

You can modify the `file_mappings` in the script to add or change the data types.

## How It Works

1. **Download**: The script checks if a newer ZIP file is available for each data type and downloads it if necessary.
2. **Extract**: Specific files are extracted from the ZIP archive.
3. **Compare**: The script compares the latest data in the extracted file with the existing data.
4. **Update**: If the new data is more recent, the original file is updated.

## Example Output

