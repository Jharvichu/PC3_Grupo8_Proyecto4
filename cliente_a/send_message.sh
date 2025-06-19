#!/bin/bash

# Se detecta el directorio donde está el script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$DIR/.."

FACADE_PATH="$BASE_DIR/facade/facade_dir"

# Verifica si la carpeta, donde se almacenara el mensaje, existe
if [ ! -d "$FACADE_PATH" ]; then
    echo "[ERROR] Carpeta facade_dir NO existe."
fi

# Verifica que la variable de entorno CLIENT_A_MSG exista
if [[ -z "$CLIENT_A_MSG" ]]; then
    CLIENT_A_MSG="Luis de inspirate"
fi

# Mensaje por defecto o pasado como argumento
MSG="$CLIENT_A_MSG"
TIME="$(date -Iseconds)"
FILE="$BASE_DIR/facade/facade_dir/message_a.txt"

# Se guarda el mensaje
echo "{\"msg\": \"$MSG\", \"timestamp\": \"$TIME\"}" > "$FILE"

echo "[cliente_a] Mensaje guardado en $FILE:"
cat "$FILE"
