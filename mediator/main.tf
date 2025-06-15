resource "null_resource" "mediator_read" {
  provisioner "local-exec" {
    command = "bash ${path.module}/mediator_read.sh"
  }
}

resource "null_resource" "mediator_forward" {
  provisioner "local-exec" {
    command = "bash ${path.module}/mediator_forward.sh"
  }
  depends_on = [null_resource.mediator_read]
}