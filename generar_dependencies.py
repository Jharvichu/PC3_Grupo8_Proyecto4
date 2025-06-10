import json

# Crea dependencies.json con contenido estatico
def generar_dependencies():
    dependencies = {
        "adapter": [],
        "facade": ["adapter"],
        "mediator": ["adapter", "facade"]
    }

    with open('dependencies.json', 'w') as f:
        json.dump(dependencies, f, indent=4)

if __name__ == "__main__":
    generar_dependencies()
