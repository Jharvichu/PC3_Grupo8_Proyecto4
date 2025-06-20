import subprocess  # Para ejecutar comandos del sistema como si se escribieran en la terminal
import json
from pathlib import Path  # Para manipular rutas y archivos


def ejecutar_script():
    '''
    Ejecuta el script adapter_output.py mediante un subproceso.
    
    Retorna:
        - Una cadena con la salida estándar si la ejecución fue exitosa.
        - None y un mensaje de error si ocurrió un problema al ejecutar.
    '''
    try:
        # Ejecuta el comando: python3 adapter_output.py
        # Captura la salida estándar y de error como texto.
        # Lanza  excepción si el comando falla (check=True).
        resultado = subprocess.run(
            ['python3', 'adapter_output.py'],
            capture_output=True,
            text=True,
            check=True
        )
        # Devuelve la salida quitando espacios al principio y al final
        return resultado.stdout.strip(), None
    except Exception as e:
        # En caso de error me devuelve el mensaje de error
        return None, f'Error al ejecutar adapter_output.py: {e}'


def validar_salida_json(salida):
    '''
    Valida que la salida sea un JSON válido y que tenga las claves esperadas: "status" y "code".
    
    Devuelve:
        - Un diccionario con los datos si el JSON es válido y contiene las claves.
        - None y un mensaje de error si el JSON es inválido o faltan claves.
    '''
    try:
        # Intenta convertir la cadena en un diccionario de Python
        datos = json.loads(salida)
        
        #Se cerciora que el resultado sea un diccionario (objeto JSON)
        if not isinstance(datos, dict):
            return None, 'La salida no es un objeto JSON.'
        
        # Verifica la existencia de las claves 'status' y 'code' en el JSON
        if 'status' not in datos or 'code' not in datos:
            return None, "El JSON no contiene las claves 'status' y 'code'."
        
        return datos, None
    except Exception as e:
        # Devuelve error si no se puede parsear el JSON
        return None, f'JSON inválido: {e}'


def escribir(path, contenido):
    '''
    Escribe el contenido dado en el archivo especificado por 'path'.
    Sobrescribe el archivo si ya existe.
    '''
    # Escribe el contenido en el archivo usando codificación UTF-8
    Path(path).write_text(contenido, encoding='utf-8')


def main():
    '''
    Función principal que coordina:
    1. La ejecución del script.
    2. La validación del JSON.
    3. La escritura del reporte.
    '''
    # Paso 1: Ejecutar el script adapter_output.py
    salida, error = ejecutar_script()

    if error:
        # Si hay error en la ejecución, se crea un reporte con el error
        escribir('adapter_report.md', f'# Adapter Report\n\n **Error:** {error}\n')
        exit(1)

    # Paso 2: Validar que la salida sea un JSON válido y tenga las claves esperadas
    datos, error = validar_salida_json(salida)

    if error:
        # Si hay error en la validación del JSON, se crea un reporte con el error
        escribir('adapter_report.md', f'# Adapter Report\n\n **Error:** {error}\n')
        exit(1)

    # Paso 3: Crear un reporte exitoso, donde estaran los datos creados o generados
    reporte = (
        '# Adapter Report\n\n'
        ' **Validación exitosa**\n\n'
        f'- status: `{datos["status"]}`\n'
        f'- code: `{datos["code"]}`\n'
    )
    escribir('adapter_report.md', reporte)


if __name__ == '__main__':
    # Si el archivo se ejecuta directamente, se llama a la función main
    main()
