resource "null_resource" "adapter_exec" {
  #se crea un recurso nulo dentro de Terraform.
  provisioner "local-exec" {
    # especifica que se va a ejecutar un comando local en la maquina de Terraform
    command = "python3 ${path.module}/adapter_output.py > adapter_output.json"
    # Ejecuta el script Python, dentro del módulo actual (${path.module}

  }

}