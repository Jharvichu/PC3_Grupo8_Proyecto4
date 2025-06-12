#!/bin/bash

# Si es que no existiera la carpeta logs, entonces se procede a crearla
mkdir -p ../logs

# Acá puse las rutas
LOG="../logs/adapter.log"
TFVARS="terraform.tfvars"

# Ejecutar el script  adapter_output.py y guardar salida; registrar errores si falla
if ! OUTPUT=$(python3 adapter_output.py 2>>"$LOG"); then
echo "Error ejecutando adapter_output.py" >> "$LOG"
exit 1
fi

# Extraer valores desde la salida del JSON
STATUS=$(jq -r '.status' <<< "$OUTPUT")
CODE=$(jq -r '.code' <<< "$OUTPUT")

# Se verifica si estos archivos existen
[[ -z "$STATUS" || -z "$CODE" ]] && {
echo "Error extrayendo status o code de la salida" >> "$LOG"
exit 1
}

# Se escribe en el archivo tfvars  estas 2 variables
cat <<EOF > "$TFVARS"
adapter_status = "$STATUS"
adapter_code = $CODE
EOF

# Aca registro la documentación exitosa
echo "$(date '+%Y-%m-%d %H:%M:%S') | adapter_parse.sh ejecutado correctamente" >> "$LOG"

if [[ ! -f terraform.tfvars ]]; then
echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR: terraform.tfvars no fue generado" >> ../logs/adapter.log
exit 1
fi

