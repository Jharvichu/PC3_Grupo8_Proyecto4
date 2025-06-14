#!/bin/bash

# Ruta al mensaje de cliente_a
MSG_A="../cliente_a/message_a.txt"
TMP_MSG="./tmp_message.txt"

# Verifica si existe el archivo
if [ ! -f "$MSG_A" ]; then
  echo "[Mediator] ERROR: No se encontró $MSG_A"
  exit 1
fi

# Copia el contenido de message_a.txt a un archivo temporal tmp_message.txt
echo "[Mediator] Leyendo mensaje de: cliente_a..."
cat "$MSG_A" > "$TMP_MSG"
echo "[Mediator] El mensaje fue leído. Guardado en $TMP_MSG"