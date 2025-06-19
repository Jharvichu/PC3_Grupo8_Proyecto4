import json
import os
import re


# Crea dependencies.json con contenido estatico
def generar_dependencies():
    """
    Analiza los módulos 'adapter', 'facade' y 'mediator' para extraer sus dependencias,
    genera el archivo 'dependencies.json' con la información obtenida y crea el archivo
    'dependencies.dot' para visualizar el grafo de dependencias.
    """
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

    print("Archivo dependencies.dot generado correctamente.")

    generar_diagrama_dot(dependencies)


def obtener_dependencias(module) -> list:
    """
    Analiza los archivos 'main.tf' dentro del 'módulo' especificado para extraer dependencias.
    Utiliza expresiones regulares para identificar dependencias.
    Devuelve una lista con los nombres de todas las dependencias encontradas.
    """
    dependencias = []

    patrones = [
        r'module\s*"([^"]+)"',              # module "nombre"
        r'depends_on\s*=\s*\[([^\]]+)\]',   # depends_on = [x, y, z]
        r'var\.([a-zA-Z0-9_-]+)',           # var.nombre_variable
        r'data\.([a-zA-Z0-9_-]+)',          # data.tipo_recurso
        r'source\s*=\s*"../([a-zA-Z0-9_-]+)"',  # source = "../modulo"
        r'source\s*=\s*"([./a-zA-Z0-9_-]+)"',   # source = "./ruta/o/relativa"
        r'data\s+"terraform_remote_state"\s+"([^"]+)"\s*{[^}]*path\s*=\s*["\']../([a-zA-Z0-9_-]+)/terraform.tfstate["\']'
    ]

    for archivo in os.listdir(module):
        if archivo.endswith("main.tf"):
            with open(os.path.join(module, archivo), 'r') as f:
                contenido = f.read()
                for patron in patrones[:-1]:
                    coincidencias = re.findall(patron, contenido)
                    dependencias.extend(coincidencias)
                coincidencias_remote = re.findall(patrones[-1], contenido, re.DOTALL)
                for coincidencia in coincidencias_remote:
                    # coincidencia será una tupla, el nombre del módulo está en la segunda posición
                    dependencias.append(coincidencia[1])

    return dependencias


def generar_diagrama_dot(dependencies):
    """
    Genera un archivo 'dependencies.dot' en formato DOT para visualizar el grafo de dependencias entre módulos.
    """
    with open('dependencies.dot', 'w') as f:
        f.write('digraph Dependencies {\n')
        for modulo, deps in dependencies.items():
            for dep in deps:
                f.write(f'    "{modulo}" -> "{dep}";\n')
        f.write('}\n')


if __name__ == "__main__":
    generar_dependencies()
