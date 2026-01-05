#!/usr/bin/env bash
set -euo pipefail

BASE="/srv/testlab"
TS="$(date +%Y%m%d_%H%M%S)"
REPORT="${BASE}/reports/report_${TS}.csv"
LOG="${BASE}/logs/run.log"

echo "[INFO] ${TS} start run" >> "$LOG"

{
  echo "timestamp,metric,value"
  echo "${TS},example,123"
} > "$REPORT"

echo "[INFO] ${TS} report generated: $(basename "$REPORT")" >> "$LOG"
