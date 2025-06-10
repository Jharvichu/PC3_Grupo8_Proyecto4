import json
import subprocess
import sys
import os

def test_adapter_output_json():
    """
    Ejecuta adapter_output.py y comprueba que imprima JSON válido
    con las claves 'status' y 'code' y los valores esperados.
    """
    # Ruta al script
    script = os.path.join(os.path.dirname(__file__), '..', 'adapter', 'adapter_output.py')
    result = subprocess.run([sys.executable, script], capture_output=True, text=True)
    
    # Intentar cargar JSON
    data = json.loads(result.stdout)
    
    assert isinstance(data, dict), "La salida no es un objeto JSON"
    assert data.get("status") == "OK"
    assert data.get("code") == 200
