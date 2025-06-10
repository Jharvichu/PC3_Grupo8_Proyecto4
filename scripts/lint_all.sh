#!/bin/bash

LOGS_DIR="./logs"
LOG_FILE="$LOGS_DIR/lint.log"
mkdir -p "$LOGS_DIR"
echo "=== COMENZANDO LINTING ===" > "$LOG_FILE"

# Flake8 - Python
echo "---- Flake8 ----" >> "$LOG_FILE"
flake8 . 2>&1 | tee -a "$LOG_FILE"

# Shellcheck - Bash
echo "---- Shellcheck ----" >> "$LOG_FILE"
find . -name "*.sh" -not -path "./venv/*" | while read -r script; do
    echo "File: $script" >> "$LOG_FILE"
    shellcheck "$script" 2>&1 | tee -a "$LOG_FILE"
done

# TFLint - Terraform
echo "---- TFLint ----" >> "$LOG_FILE"
find . -name "*.tf" | while read -r tf_file; do
    dir=$(dirname "$tf_file")
    echo "Dir: $dir" >> "$LOG_FILE"
    tflint --chdir="$dir" 2>&1 | tee -a "$LOG_FILE"
done

echo "=== LINTING ACABADO ===" >> "$LOG_FILE"