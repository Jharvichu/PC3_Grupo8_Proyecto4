variable "facade_dir" {
  description = "Nombre del directorio por crear"
  type        = string
  default     = "facade_dir"
}

variable "facade_file" {
  description = "Nombre del archivo por crear"
  type        = string
  default     = "facade_file.txt"
}

variable "adapter_status" {
  description = "Estado dado por el Adapter"
  type        = string
}
