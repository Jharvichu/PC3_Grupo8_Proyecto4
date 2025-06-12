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
  provisioner "local-exec" {
    command = "bash ${path.module}/start_service.sh"
  }
}