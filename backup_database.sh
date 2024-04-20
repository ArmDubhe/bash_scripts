#!/bin/bash

# Database credentials
DB_IP="127.0.0.1"
DB_USER="armando"
DB_PASS="arma4000"
DB_NAME="408277_cyatie"

# Backup directory
BACKUP_DIR="/home/armando/Documentos/db_bk/dump"
# Backup directory files limit
FILE_LIMIT="5";

# Timestamp for the backup file
TIMESTAMP=$(date '+%Y%m%d_%H%M')

# Backup file name
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_$TIMESTAMP.sql"

# Create backup directory if it doesn't exist
# mkdir -p "$BACKUP_DIR"

# Count the number of backup files in the directory
backup_count=$(ls -1 "$BACKUP_DIR"/*.zip 2>/dev/null | wc -l)

# Check if the number of backup files exceeds 
if [ "$backup_count" -eq "$FILE_LIMIT" ] || [ "$backup_count" -gt "$FILE_LIMIT" ]; then
    # Find the oldest backup file and delete it
    oldest_file=$(ls -1t "$BACKUP_DIR"/*.zip | tail -n 1)
    rm "$oldest_file"
fi

# Perform database backup using mysqldump
mysqldump -h "$DB_IP" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$BACKUP_FILE"

# Check if the backup was successful
if [ $? -eq 0 ]; then
    echo "Database backup completed successfully."

    # Change directory to the parent directory of the backup file
    cd "$(dirname "$BACKUP_FILE")" || exit

    # Compress the backup file into a zip file without the directory tree path
    zip -j "$BACKUP_FILE.zip" "$(basename "$BACKUP_FILE")" > /dev/null

    # Remove the uncompressed backup file
    rm "$BACKUP_FILE"

    echo "Backup file compressed: $BACKUP_FILE.zip"
else
    echo "Error: Database backup failed."
fi
