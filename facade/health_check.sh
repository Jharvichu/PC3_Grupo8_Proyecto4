#!/bin/bash


# Nombre del servicio a chequear
SERVICE_NAME="service_dummy.py"

# Usamos pgrep para buscar el proceso de Python
if pgrep -f "$SERVICE_NAME" > /dev/null; then
    echo "[OK] $SERVICE_NAME sí se está corriendo."
    exit 0
else
    echo "[ERROR] $SERVICE_NAME no se está corriendo."
    exit 1
fi