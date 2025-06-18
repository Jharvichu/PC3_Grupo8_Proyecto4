resource "null_resource" "create_folder" {
  provisioner "local-exec" {
    command = "bash ${path.module}/create_folder.sh"
  }
}

resource "null_resource" "create_file" {
  depends_on = [null_resource.create_folder]
  provisioner "local-exec" {
    command = "bash ${path.module}/create_file.sh"
  }
}

resource "null_resource" "start_service" {
  depends_on = [null_resource.create_file]
  # Verificador, evita que se despliegue el servicio si Adapter manda un estado diferente de OK.
  count = var.adapter_status == "OK" ? 1 : 0
  provisioner "local-exec" {
    command = "bash ${path.module}/start_service.sh"
  }
  # correr el health check después de iniciar el servicio
  provisioner "local-exec" {
    command = "bash ${path.module}/health_check.sh"
  }
}