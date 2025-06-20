output "facade_dir" {
  description = "Directorio creado por módulo Facade"
  value       = var.facade_dir
}

output "facade_file" {
  description = "Archivo creado por módulo Facade"
  value       = "${var.facade_dir}/${var.facade_file}"
}

output "facade_file_path" {
  description = "Ruta al archivo creado por facade"
  value       = "${path.module}/facade_dir/facade_file.txt"
}