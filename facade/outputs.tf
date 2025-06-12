output "facade_dir" {
  description = "Directorio creado por módulo Facade"
  value       = var.facade_dir
}

output "facade_file" {
  description = "Archivo creado por módulo Facade"
  value       = "${var.facade_dir}/${var.facade_file}"
}