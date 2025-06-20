data "terraform_remote_state" "facade" {
  backend = "local"
  config = {
    path = "../facade/terraform.tfstate"
  }
}

resource "null_resource" "mediator_read" {
  provisioner "local-exec" {
    command = "bash ${path.module}/mediator_read.sh"
    environment = {
      FACADE_FILE_PATH = data.terraform_remote_state.facade.outputs.facade_file_path
    }
  }
}

resource "null_resource" "mediator_forward" {
  provisioner "local-exec" {
    command = "bash ${path.module}/mediator_forward.sh"
  }
  depends_on = [null_resource.mediator_read]
}