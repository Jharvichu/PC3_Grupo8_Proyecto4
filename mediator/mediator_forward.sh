#!/bin/bash

TMP_MSG="./tmp_message.txt"
MSG_B="./message_b.txt"
LOG_FILE="../logs/mediator.log"
TS=$(date '+%Y-%m-%d %H:%M:%S')

# Llama a mediator_read.sh antes de reenviar el mensaje
if ! bash ./mediator_read.sh; then
  echo "[$TS] ERROR: Falló la lectura del mensaje, no se reenvía" >> "$LOG_FILE"
  exit 1
fi

# Verifica si existe el archivo
if [ ! -f "$TMP_MSG" ]; then
  echo "[$TS] ERROR: No se encontró $TMP_MSG." >> "$LOG_FILE"
  exit 1
fi

# Se crea un JSON con el mensaje y timestamp
cat "$TMP_MSG" > "$MSG_B"
echo "[$TS] OK: Mensaje reenviado a $MSG_B" >> "$LOG_FILE"

# Limpiando el archivo temporal
rm -f "$TMP_MSG"