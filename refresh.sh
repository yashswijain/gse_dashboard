#!/usr/bin/env bash
# Refresh the dashboard from model.xlsx
set -e
cd "$(dirname "$0")"

INPUT="${1:-model.xlsx}"

if [ ! -f "$INPUT" ]; then
  echo "ERROR: '$INPUT' not found in $(pwd)"
  echo "Usage: ./refresh.sh [path-to-excel-file]"
  exit 1
fi

echo "==> Extracting data from $INPUT"
python3 extract_data.py "$INPUT" data.json

echo "==> Building dashboard"
python3 build_dashboard.py dashboard_template.html data.json dashboard.html

echo ""
echo "Done. Open dashboard.html in your browser."
