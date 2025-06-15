import json
import os
import re


# Crea dependencies.json con contenido estatico
def generar_dependencies():
    dependencies = {
        "adapter": [],
        "facade": [],
        "mediator": []
    }

    for modulo in ["adapter", "facade", "mediator"]:
        dependencies[modulo] = obtener_dependencias(modulo)

    print("Archivo dependencies.json generado correctamente.")

    with open('dependencies.json', 'w') as f:
        json.dump(dependencies, f, indent=4)


def obtener_dependencias(module) -> list:
    dependencias = []

    patrones = [
        r'module\s*"([^"]+)"',              # module "nombre"
        r'depends_on\s*=\s*\[([^\]]+)\]',   # depends_on = [x, y, z]
        r'var\.([a-zA-Z0-9_-]+)',           # var.nombre_variable
        r'data\.([a-zA-Z0-9_-]+)',          # data.tipo_recurso
    ]

    for archivo in os.listdir(module):
        if archivo.endswith("main.tf"):
            with open(os.path.join(module, archivo), 'r') as f:
                contenido = f.read()
                for patron in patrones:
                    coincidencias = re.findall(patron, contenido)
                    dependencias.extend(coincidencias)

    return dependencias


if __name__ == "__main__":
    generar_dependencies()
