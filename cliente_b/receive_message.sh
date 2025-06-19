#!/bin/bash
# Script para recibir el mensaje reenviado por el Mediator

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$DIR/.."

INPUT_FILE="$BASE_DIR/mediator/message_b.txt"
OUTPUT_FILE="$DIR/message_b.txt"

if [ ! -f "$INPUT_FILE" ]; then
echo "[cliente_b] ERROR: No se encontró $INPUT_FILE."
exit 1
fi

cp "$INPUT_FILE" "$OUTPUT_FILE"
echo "[cliente_b] Mensaje recibido de $INPUT_FILE:"
cat "$OUTPUT_FILE"