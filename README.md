# PC3_Grupo8_Proyecto4

# **`SPRINT 01`**

[Video del Sprint_01-Grupo_8-Proyecto_4](https://www.youtube.com/watch?v=b1zwGS-fzuc)

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

### 3. `run_all.sh`

Este script orquesta la ejecución de los módulos de Terraform en el proyecto, registrando la salida de cada paso en archivos de log dentro de la carpeta logs/. Si la carpeta logs/ no existe, la crea automáticamente.

El objetivo es gestionar y ejecutar los módulos de Terraform de manera secuencial y controlada, permitiendo la ejecución selectiva de cada paso según se especifique en el parámetro --step.

Ejecuta:

- `log_message()`: Creación de la carpeta de logs

  - Si la carpeta `logs/` no existe, se crea automáticamente.
  - Los logs de cada paso se guardan en archivos dentro de esta carpeta.

- `run_terraform()`: Ejecución de Terraform

  - Ejecuta el comando `terraform init` para inicializar el módulo.
  - Ejecuta el comando `terraform apply` para aplicar los cambios definidos en el módulo.
  - Registra los resultados de la ejecución en un archivo de log.

- Control del flujo con el parámetro `--step`:

  - Permite ejecutar módulos específicos (como `adapter`, `facade`, `mediator`, etc.) al indicar el paso deseado.
  - Si se proporciona un paso desconocido o no válido, el script muestra un mensaje de error.

Uso general:

``` bash
chmod +x run_all.sh
./run_all.sh --step <nombre_del_paso>
```

#### Paso Adapter

Se comprueba que el paso solicitado sea el adapter y ejecuta los siguiente:

- Se ejecuta `run_terraform` en el modulo **adapter**
- Se cambia de directorio del modulo **adapter**
- Se ejecuta el script `adapter_parse.sh` para que quede registro en `logs/adapter.log`.

Ejemplo:

``` bash
./run_all.sh --step adapter
```

## Modulo Adapter

### 1. Archivo `adapter_output.py`
Este script tiene como objetivo generar una salida `JSON` estática que puede ser utilizada por otros componentes del sistema. Realiza las siguientes operaciones:

- Importa el módulo estándar `json` de `Python`, que permite trabajar con datos en formato `JSON`.

- Utiliza la función `json.dumps()` para convertir un diccionario de `Python` en una cadena `JSON` válida.

- Imprime el resultado en la salida estándar, lo que permite redirigirlo a un archivo (> adapter_output.json) o capturarlo desde otros scripts.

Este script se puede ejecutar primero con :

```
python3 adapter_output.py
```


Esto imprimirá:


```
{"status": "OK", "code": 200}
```


Este tipo de script se usa generalmente para: generar archivos `json` de forma automática dentro de flujos como Terraform (local-exec), pipelines CI/CD, o procesos de prueba.



### 2. Archivo `adapter_parse.sh`

Este archivo automatiza la lectura de datos generados por un script Python `adapter_output.py` y transforma dicha información en un archivo `.tfvars` legible por Terraform. También registra logs y exporta variables de entorno para su posible reutilización. Realiza las siguientes operaciones:

- Verificación de dependencias
- Verificación de archivo de entrada
- Ejecución del script Python y parseo JSON
- Creación de archivo Terraform .tfvars
- Registro en log
- Exportación de variables de entorno

Se puede ejecutar primero dando permisos:

``` bash
chmod +x adapter/adapter_parse.sh
```

después :

``` bash
./adapter_parse.sh
```

Este script es bastante útil para automatizar flujos donde:

- Se generan valores dinámicos desde scripts.
- Esos valores deben ser leídos por Terraform.
- Se quieren reutilizar variables en otras partes del sistema.

### 3. Archivo `main.tf`

Este archivo es importante porque:

- Se encarga de generar archivos locales con datos incluidos( `adapter/.terraform.lock.hcl`, `adapter/.terraform/`, `adapter/adapter_output.json`, `adapter/terraform.tfstate` ), que luego podemos utilizar en el proyecto.
- Convierte información o estados previos en un archivo para que luego se consuma.
- Automatiza tareas externas como generar configuraciones, hacer parsing, ejecutar validaciones.

Este script se puede ejecutar primero haciendo `terraform init`, luego `terraform plan` y después `terraform apply`.

Lastimosamente no es portable: si otra persona usa Windows o no tiene instalado `python3` , fallará.

Si se desea instalar `python3` desde Ubuntu puedes ejecutar:

``` bash
sudo apt update
sudo apt install python3 python3-pip -y
```

y verificas mediante:

``` bash
python3 --versión
```

## Flujo de los mensajes entre Clientes y  Mediator

1. **cliente_a/send_message.sh** genera `cliente_a/message_a.txt` con el mensaje en formato JSON.
2. El Mediator (por medio de los scripts `mediator_read.sh` y `mediator_forward.sh`) toma ese archivo y lo copia a `mediator/message_b.txt`.
3. **cliente_b/recibir_message.sh** lee el archivo `mediator/message_b.txt` y lo imprime en la terminal.

#### Diagrama
cliente_a/send_message.sh
        │
        ▼
cliente_a/message_a.txt
        │
        ▼
cp message_a.txt ../mediator/tmp_message.txt
        │
        ▼
mediator/mediator_forward.sh
        │
        ▼
mediator/message_b.txt
        │
        ▼
cliente_b/recibir_message.sh

---

### Ejemplo de prueba aislada

```bash
# Se ejecuta en cliente_a/
bash send_messageejecuta.sh "Hola Mediator"

# Se mueve el mensaje al Mediator desde la raiz del proyecto

bash cp message_a.txt ../mediator/tmp_message.txt

# Desde Mediator/  se ejecuta manualmente el script de mediator
bash mediator_forward.sh

# Luego se  ejecuta en cliente_b/
bash recibir_message.sh

Ejemplo de prueba:

### Ejemplo de output

```bash
# En cliente_a
bash send_message.sh "Hola Mediators"
[cliente_a] Mensaje escrito en message_a.txt:
{"msg": "Hola Mediators", "timestamp": "2025-06-13T21:53:56-04:00"}

# Desde Cliente_a
cp  message_a.txt ../mediator/tmp_message.txt

# Desde la raiz
bash mediator/mediator_forward.sh
[Mediator] Reenviando el mensaje a mediator/message_b.txt...
[Mediator] Mensaje reenviado exitosamente.

# Contenido en mediator/message_b.txt:
{"msg": "Hola Mediators", "timestamp": "2025-06-13T21:53:56-04:00"}

# En cliente_b
bash receive_message.sh
[cliente_b] Mensaje recibido de ../mediator/message_b.txt:
{"msg": "Hola Mediators", "timestamp": "2025-06-13T21:53:56-04:00"}


## Script `generar_dependencies.py`
 
Este script crea un archivo dependencies.json con contenido estático, que describe las dependencias entre los módulos del proyecto.


**Funcionalidad:**

- **Generación de dependencies.json**: El script define un diccionario con las dependencias de los módulos:

    - `adapter` no tiene dependencias.
    - `facade` depende de `adapter`.
    - `mediator` depende de `adapter` y `facade`.

- **Escritura del Archivo JSON**: El diccionario de dependencias se guarda en un archivo llamado `dependencies.json`, utilizando formato JSON con indentación de 4 espacios.

**Uso:**
```bash
python3 generar_dependencies.py
```

**Salida:** (dependencies.json):

```json
{
    "adapter": [],
    "facade": ["adapter"],
    "mediator": ["adapter", "facade"]
}
```

## Pruebas

Para asegurar que el código funcione correctamente y cumpla con los requisitos, se ha añadido este apartado de pruebas usando **pytest**. Las pruebas se encuentran en la carpeta `test/`

### Archivo `pytest.ini`

El archivo `pytest.ini` se ha configurado para personalizar el comportamiento de las pruebas y establecer ciertas reglas, como la cobertura minima y la ejecucion de tests. El contenido es el siguiente:

```ini
[pytest]
addopts = --maxfail=1 --disable-warnings --cov=adapter --cov=facade --cov=mediator --cov=cliente_a --cov=cliente_b --cov-fail-under=80
python_files = tests/test_*.py
```

**Addopts**

- `--maxfile=1`: Limita la ejecucion de pruebas a un solo fallo. Si un test falla, pytest se detendra y no ejecutara los tests restantes.
- `--disable-warnings`: Desactiva la visualización de advertencias no criticas y hace que la salida sea más limpia de leer.
- `--cov=<module>`: Aqui indica que mida la cobertura en los modulos asignados.
- `--cov-fail-under=80`: Establece un umbral mínimo de 80% de cobertura para módulos indicados. Si la cobertura es menor del 80%, los test fallaran.

**Python_files**

- `tests/test_*.py`: Todos los archivos de prueba dentro de la carpeta `tests/` que sigan el patrón `test_*.py` serán ejecutados.

Esto nos facilita ya que al ejecutar **pytest** en el proyecto, las opciones definidas en `pytest.ini` se aplicaran automaticamente. Solamente basta con escribir en lo siguiente en la linea de comandos para que se ejecute las pruebas:

```bash
pytest
```

# **`SPRINT 02`**

## Facade

### 1. `variables.tf`

Este archivo define las variables de entrada para el módulo que permitirán parametrizar el nombre del directorio y del archivo que se crearán.

- `facade_dir`: Nombre del directorio por crear (por defecto, `facade_dir`).
- `facade_file`: Nombre del archivo por crear dentro del directorio (por defecto, `facade_file.txt`)

### 2. `main.tf`

Este archivo contiene los recursos principales de terraform:

- `create_folder`: Ejecuta el script `create_folder.sh` para crear el directorio `facade_dir/`.
- `create_file`: Este depende de `create_folder`. Ejecuta el script `create_file.sh`, que crea el archivo `facade_file.txt` dentro de `facade_dir/`.
- `start_service`: Este depende de `create_file`. Ejecuta el script `start_service.sh`, que lanza un servicio python y lo ejecuta en segundo plano.

Gracias a la aplicación de `depends_on` nos aseguramos que los scripts se ejecuten en un orden correcto.

### 3. `outputs.tf`

Este archivo muestra salidas del módulo para que puedan ser consultadas desde otros módulos o luego de ejecutar `terrafrom apply`:

- `facade_dir`: Nombre del directorio creado.
- `facade_file`: Ruta del archivo creado (`facade_file`) dentro del directorio ya mencionado.

### 4. `create_folder.sh`

- Crea el directorio `facade_dir/` si es que no existe.
- Usa el comando `mkdir -p` para que no falle en caso que el directorio ya exista.

### 5. `create_file.sh`

- Crea un archivo dentro de `facade_dir` de nombre `facade_file.txt`.
- Se escribe en el archivo el texto "create_file creó este archivo" como una opción para comprobar que el script funcionó.

### 6. `start_service.sh`

- Crea en la raiz del proyecto el directorio `logs/` en caso que no exista.
- Lanza el script `service_dummy.py` usando `nohup` para que el proceso siga ejecutandose en segundo plano.
- Redirige las salidas al archivo `logs/facade_service.log`.
- Con `$(dirname "$0")` nos garantizamos que el script se ejecute desde la dirección relativa correcta.

### 7. `service_dummy.py`

- Simula un servicio.
- Permanece ejecutándose en un bucle infinito, con pausas de 10 segundos.
- El parámetro `flush=True` nos asegura que el mensaje se escriba en el log.

### Flujo de ejecución

1. Se ejecuta `terraform init` para prepara el módulo.

2. Se ejecuta `terraform apply`, con esto conseguimos:
    - Crear el directorio.
    - Crear el archivo.
    - Lanzar el servicio python.
    - Generar los logs.

## Mediator

Este módulo va a coordinar el flujo de los mensajes entre `cliente_a` y `cliente_b`

### 1. `main.tf`

Es el archivo principal de terraform para este módulo.

- Se define los recursos terraform necesarios para la coordinación de los mensajes entre `cliente_a` y `cliente_b`.
- Contiene 02 recursos `null_resource`:
    - `mediator_read`: Ejecuta el script que leerá el mensaje de `cliente_a`.
    - `mediator_forward`: Ejecuta el script que reenviará el mensaje a `cliente_b`.
- Adicionalmente, se usa `depends_on` para asegurarnos que los scripts se ejecutarán en el orden correcto.

### 2. `mediator_read.sh`

Es un script bash que es ejecutado por Terraform.

- Valida que exista el archivo `cliente_a/message_a.txt`, que es generado por `cliente_a`.
- Lee el contenido de dicho archivo (mensaje).
- Copia el mensaje a un archivo temporal (`tmp_message.txt`), dentro del módulo mediator, para su posterior proceso.

### 2. `mediator_forward.sh`

Es un script bash que es ejecutado luego de `mediator_read.sh`.

- Captura el mensaje dentro de `tmp_message.txt`.
- Lo copia como `message_b.txt`, que será tomado por `cliente_b`.

### Ejecución

1. Primero, debemos asegurarnos que el archivo `message_a.txt` esté creado dentro del directorio `cliente_a/`, por el momento podemos ejecutarlo usando el siguiente comando desde la raiz del proyecto:
```bash
$ bash cliente_a/send_message.sh
```
2. Ya creado el archivo `message_a.txt`, nos dirigimos al directorio `mediator/`:
```bash
$ cd mediator
```
3. Ejecutamos:
```bash
$ terraform init
$ terraform apply -auto-approve
```
Luego de ejecutar terraform, se generarán `tmp_message.sh` y también `message_b.txt`, este último será leído por `cliente_b/`. Dicha función se implementará en el **Sprint 3**.

## `generar_dependencies.py`

Este archivo, `dependencies.json`, contiene un listado de dependencias entre los módulos de Terraform en el proyecto. Este archivo se utiliza para mantener un registro de las relaciones entre los módulos.

### ¿Como se genera?

El archivo `dependencies.json` es generado automáticamente mediante el script `generar_dependencies.py`, el cual analiza los archivos `.tf` en los módulos `adapter`, `facade`, y `mediator`. El script busca las declaraciones de dependencias dentro de los archivos Terraform y las organiza en el archivo `dependencies.json`.

#### Pasos para generar `dependencies.json`:

Para generar el archivo `dependencies.json`, simplemente ejecuta el siguiente comando en la raíz del proyecto:

```bash
python3 generar_dependencies.py
```

#### ¿Qué hace el script?:

- El script recorre las carpetas de los módulos adapter, facade, y mediator.
- Dentro de cada módulo, busca los archivos main.tf.
- Extrae las dependencias definidas con las palabras clave depends_on, module, var, y data.
- Genera el archivo dependencies.json con las dependencias de cada módulo.

#### Ejemplo de salida al ejecutar al final del sprint 02

```json
{
    "adapter": [
        "adapter_status",
        "adapter_code"
    ],
    "facade": [
        "null_resource.create_folder",
        "null_resource.create_file"
    ],
    "mediator": [
        "null_resource.mediator_read"
    ]
}
=======
## Scripts

### `run_all.sh`
Este script sirve como orquestador general del proyecto, automatizando la ejecución de los distintos módulos Terraform (`adapter`, `facade`, `mediator`, `cliente_a`, `cliente_b`) en el orden correcto y registrando sus resultados.

**Funciones**
- `log_message(mensaje, módulo)`: Registra un mensaje en el archivo logs/<módulo>.log, añadiendo un timestamp para seguimiento.
Útil para trazabilidad durante la ejecución de los pasos.

- `run_terraform(módulo, archivo_tfvars)`: Ejecuta terraform init y terraform apply en el módulo indicado. Si se proporciona un archivo .tfvars, lo aplica con sus variables; si no, ejecuta sin parámetros adicionales. También registra en el log correspondiente.

**Pasos definidos (`--step`)**
- **`adapter`**: Ejecuta el módulo `adapter/` con sus variables definidas. Antes de aplicar Terraform, se ejecuta el script `adapter_parse.sh` para convertir la salida de un script Python en variables legibles por Terraform.

- **`facade`**: Ejecuta el módulo `facade/`, que encapsula la creación de una carpeta (`facade_dir`), un archivo (`facade_file.txt`) y el inicio de un servicio dummy. Registra una línea indicando que se generaron los recursos simulados.

- **`mediator`**: Corre el módulo `mediator/`, el cual actúa como intermediario entre cliente_a y cliente_b. Antes de aplicar, ejecuta `send_message.sh` dentro de `cliente_a/`, simulando el envío de un mensaje. Luego aplica Terraform y se deja constancia en el log.

- **`cliente_a`**: Ejecuta únicamente el script send_message.sh, que escribe un mensaje JSON (`message_a.txt`) que será leído por el mediator.

- **`cliente_b`**: Ejecuta el script `receive_message.sh`, que lee el mensaje reenviado por el mediator y lo muestra en consola.

**Uso general**

```bash
./run_all.sh --step <nombre_del_paso>
```

**Ejemplo de ejecución**

```bash
# Ejecutar el módulo adapter
./run_all.sh --step adapter

# Ejecutar todos los pasos de forma manual
./run_all.sh --step facade
./run_all.sh --step mediator
./run_all.sh --step cliente_a
./run_all.sh --step cliente_b
```