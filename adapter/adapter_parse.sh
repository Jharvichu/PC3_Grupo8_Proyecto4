#!/bin/bash

# Se verifica dependencias y el archivo
command -v python3 >/dev/null || { echo "Falta python3"; exit 1; }
command -v jq >/dev/null || { echo "Falta jq"; exit 1; }
[ -r adapter_output.py ] || { echo "No se puede leer adapter_output.py"; exit 1; }

# Se procede a ejecutar Python y extraer datos
output=$(python3 adapter_output.py)
status=$(jq -r '.status' <<< "$output")
code=$(jq -r '.code' <<< "$output")

# Escribir archivo .tfvars
cat > adapter.auto.tfvars <<EOF
adapter_status = "$status"
adapter_code = $code
EOF

# Registrar log
mkdir -p ../logs
[ -w ../logs ] || { echo "No se puede escribir en ../logs"; exit 1; }
echo "[$(date '+%F %T')] status=$status code=$code" >> ../logs/adapter.log

# Exportar variables al entorno
export adapter_status="$status"
export adapter_code=$code
