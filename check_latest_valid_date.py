import pandas as pd
import sys

def get_latest_valid_date(file_path, column_name):
    # Read the file, skipping the first 19 rows (comments + header)
    df = pd.read_csv(
        file_path,
        skiprows=19,
        names=["STAID", "SOUUID", "DATE", column_name, f"Q_{column_name}"]
    )

    # Filter valid values
    df_valid = df[df[column_name] != -9999].copy()

    # Convert date column to datetime
    df_valid["DATE"] = pd.to_datetime(df_valid["DATE"], format="%Y%m%d")

    # Find the latest date
    latest_date = df_valid["DATE"].max()

    return latest_date.date()

if __name__ == "__main__":
    # Get the file path and column name from the command-line arguments
    if len(sys.argv) != 3:
        print("Usage: python3 check_latest_valid_date.py <file_path> <column_name>")
        sys.exit(1)

    file_path = sys.argv[1]
    column_name = sys.argv[2]
    latest_date = get_latest_valid_date(file_path, column_name)
    print(latest_date)  # Print only the date