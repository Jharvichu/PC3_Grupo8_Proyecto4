variable "adapter_status" {
  description = "Estado reportado por el adapter"
  type        = string
}

variable "adapter_code" {
  description = "Código reportado por el adapter"
  type        = number
}

output "adapter_status" {
  value = var.adapter_status
}

output "adapter_code" {
  value = var.adapter_code
}