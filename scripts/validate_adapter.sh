#!/bin/bash

LOGS_DIR="./logs"
LOG_FILE="$LOGS_DIR/validate_adapter.log"
mkdir -p "$LOGS_DIR"
echo "=== EJECUTANDO VALIDATE ADAPTER ===" > "$LOG_FILE"

cd adapter || exit 1

echo "--- terraform fmt ---" >> "../$LOG_FILE"
terraform fmt -check 2>&1 | tee -a "../$LOG_FILE"
FMT_STATUS=$?

echo "--- terraform validate ---" >> "../$LOG_FILE"
terraform validate 2>&1 | tee -a "../$LOG_FILE"
VALIDATE_STATUS=$?

if [ $FMT_STATUS -eq 0 ] && [ $VALIDATE_STATUS -eq 0 ]; then
    echo "[OK] Adapter validado correctamente." >> "../$LOG_FILE"
    exit 0
else
    echo "[ERROR] Problemas en formato o validación de Terraform." >> "../$LOG_FILE"
    exit 1
fi