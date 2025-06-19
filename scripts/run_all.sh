#!/bin/bash

# Se detecta el directorio donde está el script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$DIR/.."

# Crear carpeta de logs si no existe
mkdir -p "$BASE_DIR/logs"

# Función para registrar el log con fecha y mensaje
log_message() {
    echo "[$(date '+%F %T')] $1" >> "$BASE_DIR/logs/$2.log"
}

# Función para ejecutar Terraform en un módulo
run_terraform() {
    MODULE=$1
    TFVARS=$2
    log_message "Iniciando Terraform en el módulo $MODULE" "$MODULE"
    cd "$BASE_DIR/$MODULE" || exit 0
    terraform init
    if [[ -n "$TFVARS" ]]; then
        terraform apply -auto-approve -var-file="$TFVARS"
        log_message "Terraform apply en el módulo $MODULE completado con variables en $TFVARS" "$MODULE"
    else 
        terraform apply -auto-approve
    log_message "Terraform apply en el módulo $MODULE completado" "$MODULE"
    fi
    cd "$BASE_DIR" || exit 0
}

# Comprobamos el paso solicitado
if [ "$1" == "--step" ]; then
    STEP=$2
    case $STEP in
        adapter)
            cd "$BASE_DIR/adapter" || exit 0
            # shellcheck disable=SC1091
            source "adapter_parse.sh"
            run_terraform "$STEP" terraform.tfvars
            ;;
        facade)
            # El terraform apply de facade ahora depende de terraform.tfvars generado por adapter
            run_terraform "$STEP" "../adapter/terraform.tfvars"
            log_message "Se creo la caperta facade_dir con el archivo facade_file.txt" "$STEP"
            ;;
        mediator)
            cd "$BASE_DIR/cliente_a" || exit 0
            # shellcheck disable=SC1091 
            source "send_message.sh" "Se utilizo run_all.sh"
            run_terraform "$STEP"
            log_message "Se recepciona el mensaje de A para que B lo reciba" "$STEP"
            ;;
        cliente_a)
            cd "$BASE_DIR/cliente_a" || exit 0
            # shellcheck disable=SC1091
            source "send_message.sh" "Se utilizo run_all.sh"
            cd "$BASE_DIR" || exit 0
            log_message "El cliente A envio su mensaje" "$STEP"
            ;;
        cliente_b)
            cd "$BASE_DIR/cliente_b" || exit 0
            # shellcheck disable=SC1091
            source "receive_message.sh"
            cd "$BASE_DIR" || exit 0
            log_message "El cliente B envio recibio su mensaje" "$STEP"
            ;;
        *)
            echo "Paso desconocido: $STEP"
            exit 0
            ;;
    esac
else
    echo "Por favor, especifique el paso usando --step <nombre_del_paso>"
    exit 0
fi