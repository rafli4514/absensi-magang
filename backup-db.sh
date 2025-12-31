#!/bin/bash

# Database Backup Script
# Usage: ./backup-db.sh

set -e

BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/backup_$TIMESTAMP.sql"

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

echo "📦 Creating database backup..."

# Backup database
docker-compose exec -T postgres pg_dump -U absensi_user absensi_db > $BACKUP_FILE

if [ $? -eq 0 ]; then
  echo "✅ Backup created: $BACKUP_FILE"
  
  # Compress backup
  gzip $BACKUP_FILE
  echo "✅ Backup compressed: $BACKUP_FILE.gz"
  
  # Keep only last 7 days of backups
  find $BACKUP_DIR -name "backup_*.sql.gz" -mtime +7 -delete
  echo "🧹 Old backups (older than 7 days) cleaned up"
else
  echo "❌ Backup failed!"
  exit 1
fi

