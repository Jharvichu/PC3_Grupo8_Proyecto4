#!/bin/bash
# Script para recibir el mensaje reenviado por el Mediator

INPUT_FILE="../mediator/message_b.txt"

if [ ! -f "$INPUT_FILE" ]; then
echo "[cliente_b] ERROR: No se encontró $INPUT_FILE."
exit 1
fi

echo "[cliente_b] Mensaje recibido de $INPUT_FILE:"
cat "$INPUT_FILE"