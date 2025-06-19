import subprocess  # Util para ejecutar comandos del sistema como si estuviesen en la terminal
import json
from pathlib import Path  # Librería útil para manejo de errores

def ejecutar_script():
    '''
    Ejecuta el script adapter_output.py mediante un subproceso.
    Retorna:
        - Un texto de salida si la ejecución fue exitosa.
        - None y un mensaje de error si ocurrió un problema al ejecutar.
    '''
    try:
        resultado = subprocess.run(
            ['python3', 'adapter_output.py'],  # Se ejecuta adapter_output.py
            capture_output=True,               # Captura la salida estándar y de error
            text=True,                         # Devuelve las salidas como string
            check=True                         # Lanza excepción si el comando falla
        )
        return resultado.stdout.strip(), None  # Si todo sale bien entonces devuelve la salida sin espacios extra 
    except Exception as e:
        # Si falla el comando, devuelve el error
        return None, f'Error al ejecutar adapter_output.py: {e}'

def validar_salida_json(salida):
    '''
    Valida que la salida sea un JSON y que tenga las claves esperadas.
    Retorna:
        - El objeto JSON como diccionario si es válido.
        - None y un mensaje de error si no es válido o no tiene las claves.
    '''
    try:
        datos = json.loads(salida)  # Intenta cargar el JSON.
        if not isinstance(datos, dict):
            # Se encarga de verificar que JSON sea un diccionario.
            return None, 'La salida no es un objeto JSON.'
        
        if 'status' not in datos or 'code' not in datos:
            return None, "El JSON no contiene las claves 'status' y 'code'."
        return datos, None
    except Exception as e:
        # Si falla el parseo del JSON
        return None, f'JSON inválido: {e}'

def escribir(path, contenido):
    '''
    Escribe el contenido dado en un archivo especificado por 'path'.
    Sobrescribe si el archivo ya existe.
    '''
    Path(path).write_text(contenido, encoding='utf-8')

if __name__ == '__main__':
    # Paso 1: Ejecutar el script
    salida, error = ejecutar_script()

    if error:
        # Si hubo error al ejecutar el script entonces hace un reporte con un mensaje de error
        escribir('adapter_report.md', f'# Adapter Report\n\n **Error:** {error}\n')
        exit(1)

    # Paso 2: Validar que la salida sea un JSON válido
    datos, error = validar_salida_json(salida)

    if error:
        escribir('adapter_report.md', f'# Adapter Report\n\n **Error:** {error}\n')
        exit(1)

    # Paso 3: Si todo estuvo bien, entonces se escribe un reporte exitoso
    reporte = (
        '# Adapter Report\n\n'
        ' **Validación exitosa**\n\n'
        f'- status: `{datos["status"]}`\n'
        f'- code: `{datos["code"]}`\n'
    )
    escribir('adapter_report.md', reporte)


    