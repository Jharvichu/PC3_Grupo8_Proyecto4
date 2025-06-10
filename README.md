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

Este hook se ejecuta antes de que se aplique un commit.

Con este hook, se evita que se comiteen archivos en una rama donde no se pueda trabajar (en nuestro caso son las ramas 'main', 'develop' y 'release').

**Comportamiento:**

- Se añade un archivo al área 'staged'.
- Si nos encontramos trabajando en una rama "prohibida", entonces no se realiza el commit cuando querramos hacerlo.
- Si nos encontramos trabajando en una rama válida, entonces pasará el commit cuando querramos hacerlo.

**Ejemplo:**

```bash
# Trabajando en la rama 'develop'
$ git add archivo
$ git commit -m "mensaje de commit"

"ERROR: No está permitido hacer commit directamente en la rama 'develop'."
"Por favor, cree una rama de trabajo para hacer tus commits."
```

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

Con este hook se ejecutan pruebas automáticas antes de subir el código al repositorio. En este estado actual, solo se simula la validación.

**Comportamiento:**

- Al ejecutar `git push`, se muestra un mensaje que indica que se están ejecutando pruebas automáticas.
- Por ahora, el hook siempre retorna éxito.
- En el futuro se planea ejecutar herramientas como pytest, shellcheck, etc.

**Ejemplo:**

```bash
$ git push origin feature/creando-archivos

Ejecutando pruebas automáticas...
```