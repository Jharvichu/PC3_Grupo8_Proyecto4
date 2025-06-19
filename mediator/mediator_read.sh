#!/bin/bash

# Ruta al mensaje de cliente_a
MSG_A="../facade/facade_dir/message_a.txt"
TMP_MSG="./tmp_message.txt"
LOG_FILE="../logs/mediator.log"
TS=$(date '+%Y-%m-%d %H:%M:%S')

# Verifica si existe el archivo
if [ ! -f "$MSG_A" ]; then
  echo "[$TS] ERROR: No se encontró $MSG_A" >> "$LOG_FILE"
  exit 1
fi

# Verifica que el archivo tenga la clave "msg"
if ! grep -q '"msg"' "$MSG_A"; then
  echo "[$TS] ERROR: $MSG_A no contiene la clave \"msg\"" >> "$LOG_FILE"
  exit 1
fi

# Extrae el valor de "msg" usando jq
if ! command -v jq &>/dev/null; then
  echo "[$TS] ERROR: 'jq' no está instalado." >> "$LOG_FILE"
  exit 1
fi

MSG=$(jq -r '.msg // empty' "$MSG_A")
if [ -z "$MSG" ] || [ "$MSG" == "null" ]; then
  echo "[$TS] ERROR: La clave \"msg\" está vacía o inválida en $MSG_A" >> "$LOG_FILE"
  exit 1
fi

# Copia el contenido de message_a.txt a un archivo temporal tmp_message.txt
echo "[$TS] Leyendo mensaje de: cliente_a..."
echo "$MSG" > "$TMP_MSG"
echo "[$TS] El mensaje fue leído. Guardado en $TMP_MSG" >> "$LOG_FILE"