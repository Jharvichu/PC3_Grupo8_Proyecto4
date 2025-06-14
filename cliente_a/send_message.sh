#!/bin/bash

# Se detecta el directorio donde está el script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Mensaje por defecto o pasado como argumento
MSG="${1:-'Hola desde cliente A'}"
TIME="$(date -Iseconds)"
FILE="$DIR/message_a.txt"

# Se guarda el mensaje
echo "{\"msg\": \"$MSG\", \"timestamp\": \"$TIME\"}" > "$FILE"

echo "[cliente_a] Mensaje guardado en $FILE:"
cat "$FILE"i
