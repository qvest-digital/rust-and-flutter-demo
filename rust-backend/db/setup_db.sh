#!/bin/zsh
cd "$(dirname "$0")" || echo "Failed to change directory"
sqlite3 tasks.sqlite < init.sql
echo "Successfully setup database"
