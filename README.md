# PC3_Grupo8_Proyecto4

## Archivo `setup.sh`

**Archivo importante, ejecutar al inicio.**

Este archivo automatiza la creación del setup adecuado para trabajar en este proyecto. Realiza las siguientes operaciones:

- Crea el entorno virtual `venv`. (si es que aún no está creado)
- Activa dicho entorno.
- Instalar las dependencias dentro de `requirements.txt` (si es que existe).
- Mueve los hooks de `hooks/` (`pre-commit`, `commit-msg` y `pre-push`) al directorio `.git/hooks/` y les de permisos de ejecución.

Dicho script bash se puede ejecutar de la siguiente manera

```
source setup.sh
```

Cabe mencionar que algunos comandos dentro de `setup.sh` (como `source venv/bin/activate`) solamente funcionan en sistemas tipo Unix, por lo cual, si se usa otro sistema operativo simplemente dichos comandos no tendrán efecto.

## Hooks personalizados

En este proyecto usamos hooks personalizados para mantener buenas prácticas de desarrollo. Los siguientes hooks los encontramos en `hooks/` y se instalan en `.git/hooks` al ejecutar `setup.sh`

### 1. `pre-commit`

Este hook se ejecuta antes de que se aplique un commit y cumple dos funciones importantes:

1. Evitar que se comiteen archivos en una rama donde no se pueda trabajar (en nuestro caso son las ramas 'main', 'develop' y 'release').
2. Ejecutar linters ágiles de manera automática sobre los archivos en el área de staged, para detectar errores antes de confirmar los cambios.

**Comportamiento:**

- Se añade un archivo al área 'staged'.
- Si nos encontramos trabajando en una rama "prohibida", entonces no se realiza el commit cuando querramos hacerlo.
- Si nos encontramos trabajando en una rama válida, entonces:
    - Se ejecuta `flake8` sobre los archivos `.py`.
    - Se ejecuta `shellcheck` sobre scripts `.sh`.
    - Se ejecuta `tflint` para validar sintaxis en archivos `.tf`.

**Ejemplo:**

```bash
# Trabajando en la rama 'develop'
$ git add archivo
$ git commit -m "mensaje de commit"

"ERROR: No está permitido hacer commit directamente en la rama 'develop'."
"Por favor, cree una rama de trabajo para hacer tus commits."
```

**Verificar que se tiene instaladas estas herramientas localmente. Puede ver cómo instalarlas en la sección `Herramientas usadas y cómo instalarlas`**

### 2. `commit-msg`

Este hook se ejecuta justo después de escribir el mensaje commit, antes de ser "aceptado" el commit.

Con este hook se verifica que el mensaje del commit siga un formato específico siguiendo las rúbricas del proyecto.

**Formato:**

```
<tipo>(<scope>): (Issue #<número>) <mensaje descriptivo entre 10 y 100 caracteres>
```

**Comportamiento:**

- Si el mensaje de commit sigue el formato indicado, el commit es aceptado.
- Si el mensaje de commit no cumple con el formato, entonces se cancela dicho commit y se muestra la estructura a seguir.

**Ejemplo:**

```bash
$ git commit -m "Cambios en archivo"

Error: Formato de commit inválido.
Debe seguir: <tipo>(<scope>): (Issue #<número>) <mensaje de 10-100 caracteres>
```

### 3. `pre-push`

Este hook se ejecuta justo antes de enviar los cambios al repositorio remoto usando `git push`.

Con este hook se ejecutan validaciones completas del proyecto, incluyendo linters para python, bash, terraform y pruebas si es que hay alguna.

**Comportamiento:**

- Al ejecutar `git push`, se lanza un pipeline local con:
    - `flake8`, para validar los códigos python.
    - `shellcheck` para analizar todos los scripts `.sh`.
    - `tflint`, `terraform fmt` y `terraform validate` para todas las carpetas con archivos `.tf`.
    - `pytest`, para ejecutar los tests.

**Ejemplo:**

```bash
$ git push origin feature/creando-archivos

[pre-push] Ejecutando linters y validaciones completas...
[pre-push] Analizando Terraform en adapter/
[pre-push] Todos los linters y pruebas pasaron.
```

**Verificar que se tiene instaladas estas herramientas localmente. Puede ver cómo instalarlas en la sección `Herramientas usadas y cómo instalarlas`**

## Herramientas usadas y cómo instalarlas

### 1. flake8 y Pytest:

- flake8: Linter para código python, que ayuda a la calidad y estilo del código.
- pytest: Framework para realizar pruebas unitarias en python.

Ambas herramientas ya están listadas en el archivo `requirements.txt` y que se instalan automáticamente al ejecutar el script `setup.sh`

### 2. ShellCheck

Este es un linter para scripts shell (bash, etc) que detecta errores y malas prácticas.

**Instalación**

Dirigirse a `home/` (`cd ~`)

Ejecutar:

```bash
sudo apt update
sudo apt install shellcheck
```

### 3. TFLint

Es una herramienta para analizar código terraform, para detectar problemas o malas prácticas

**Instalación**

Dirigirse a `home/` (`cd ~`)

Ejecutar:

```bash
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
```

### 4. JQ

Es una herramienta para procesar y manipular JSONs desde nuestra línea de comandos.

**Instalación**

Dirigirse a `home/` (`cd ~`)

Ejecutar:

```bash
sudo apt update
sudo apt install jq
```

## Scripts

### 1. `lint_all.sh`

Este script ejecuta todos los linters disponibles en el proyecto para archivos importantes (`.py`, `.tf` y `.tf`). Además, guarda el resultado en el archivo `lint.log` en `logs/`. Inclusive crea la carpeta `logs/` si es que no existe. 

El objetivo de este script es detectar errores comunes y malas prácticas antes de que el código llegue al controlados de versiones. 

Ejecuta:

- `flake8` sobre todos los archivos python del proyecto.
    - Analiza desde la raiz y sigue por los subdirectorios.
    - Detecta errores de sintaxis, variables no utilizadas, etc.
    - Toda la salida se redirigide y guarda en el log.
- `shellcheck` sobre todos los archivos bash, excluyendo la carpeta del entorno virtual, `venv/`.
    - Busca scripts `.sh` en el proyecto.
    - Para cada archivo muestra el nombre del script y el análisis realizado.
    - Informa malas prácticas, variables sin comillas, etc.
- `tflint` en cada carpeta que contenga archivos terraform (`.tf`).
    - Busca todos los archivos `.tf` en todo el proyecto y ejecuta tflint para cada caso.
    - Detecta problemas como recursos mal definidos, variables sin usar, sintaxis malos, etc.

**Uso:**

```bash
bash scripts/lint_all.sh
```

**Verificar que se tiene instaladas estas herramientas localmente. Puede ver cómo instalarlas en la sección `Herramientas usadas y cómo instalarlas`**

### 2. `validate_adapter.sh`

Este script valida la infraestructura en el directorio `adapter/`, usando herramientas nativas de terraform. También, guarda el resultado en el archivo `validate_adapter.log`, dentro de la carpeta `logs/`. Inclusive crea la carpeta `logs/` si es que no existe.

El objetivo es asegurar que los archivos terraform dentro de `adapter/` estén bien formateadas y sean validas sintácticamente.

Ejecuta:

- `terraform fmt -check` para verificar que los archivos terraform estén correctamente formateados.
    - No aplica cambios, solamente verifica si el formato es correcto.
    - Si hay errores, se registran en el log.
- `terraform validate` para verificar que los archivos `.tf` sean válidos según el punto de vista de terraform .
    - Revisa errores, como recursos mal definidos, sintaxis inválidas, etc.
    - La validación se realiza directamente desde el directorio `adapter/`.

**Uso:**

```bash
bash scripts/validate_adapter.sh
```

**Verificar que se tiene instaladas estas herramientas localmente. Puede ver cómo instalarlas en la sección `Herramientas usadas y cómo instalarlas`**