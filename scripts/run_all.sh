#!/bin/bash

# Crear carpeta de logs si no existe
mkdir -p ../logs

# Función para registrar el log con fecha y mensaje
log_message() {
    echo "[$(date '+%F %T')] $1" >> ../logs/$2.log
}

# Función para ejecutar Terraform en un módulo
run_terraform() {
    MODULE=$1
    log_message "Iniciando Terraform en el módulo $MODULE" $MODULE
    cd ../$MODULE
    terraform init
    terraform apply -auto-approve
    log_message "Terraform apply en el módulo $MODULE completado" $MODULE
    cd ..
}

# Comprobamos el paso solicitado
if [ "$1" == "--step" ]; then
    STEP=$2
    case $STEP in
        adapter)
            run_terraform "adapter"
            cd $STEP
            chmod + adapter_parse.sh
            ./adapter_parse.sh
            ;;
        *)
            echo "Paso desconocido: $STEP"
            exit 1
            ;;
    esac
else
    echo "Por favor, especifique el paso usando --step <nombre_del_paso>"
    exit 1
fi