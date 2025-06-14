#!/bin/bash
# Script para enviar un mensaje desde cliente_a a través del Mediator

# Mensaje: se puede pasar por argumento o usar variable de entorno
MSG="${1:-${CLIENT_A_MSG:-'Hola desde cliente A'}}"
TIMESTAMP="$(date -Iseconds)"
OUTPUT_FILE="message_a.txt"

# Crear el JSON y escribirlo en message_a.txt
echo "{\"msg\": \"$MSG\", \"timestamp\": \"$TIMESTAMP\"}" > "$OUTPUT_FILE"

echo "[cliente_a] Mensaje escrito en $OUTPUT_FILE:"

cat "$OUTPUT_FILE"