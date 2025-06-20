#!/bin/bash
# Script para esperar y mostrar el mensaje reenviado por el Mediator

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$DIR/.."

# Pone la ruta del archivo esperado, el tiempo máximo y un contador.
INPUT_FILE="$BASE_DIR/mediator/message_b.txt"

TIMEOUT=5
ELAPSED=0
OUTPUT_FILE="$DIR/message_b.txt"

# Bucle que se repite hasta que el tiempo que transcurra sea igual al del timeout
while [ $ELAPSED -lt $TIMEOUT ]; do
    if [ -f "$INPUT_FILE" ]; then
        echo "[cliente_b] ¡Mensaje recibido! Mirá lo que dice:"
        cat "$INPUT_FILE"
        exit 0
    fi
    sleep 1
    ELAPSED=$((ELAPSED + 1))
done


# Si termina el tiempo y no encuentra el archivo
echo "[cliente_b] Ups, no encontré el archivo $INPUT_FILE después de $TIMEOUT segundos."
exit 1

cp "$INPUT_FILE" "$OUTPUT_FILE"
echo "[cliente_b] Mensaje recibido de $INPUT_FILE:"
cat "$OUTPUT_FILE"