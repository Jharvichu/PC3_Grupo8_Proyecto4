# Librerías de pruebas
import pytest  # Framework principal de testing
from unittest.mock import patch, MagicMock  # Para simular funciones y comportamientos
from pathlib import Path

# Importamos funciones a testear desde el módulo adapter_validate
from adapter.adapter_validate import ejecutar_script, validar_salida_json, escribir

# -------------------------------------------------------
# TEST 1: Verifica que ejecutar_script funcione correctamente si el script devuelve salida válida
def test_ejecutar_script_exito():
    mock_result = MagicMock()  # Creamos un objeto simulado
    mock_result.stdout = '{"status": "ok", "code": 200}'  # Simulamos salida del script

    # Parchamos subprocess.run para que devuelva mock_result en vez de ejecutarse realmente
    with patch('subprocess.run', return_value=mock_result):
        salida, error = ejecutar_script()
        assert error is None  # No debe haber error
        assert salida == '{"status": "ok", "code": 200}'  # La salida debe ser la esperada

# -------------------------------------------------------
# TEST 2: Verifica el comportamiento cuando ejecutar_script falla
def test_ejecutar_script_falla():
    # Simulo un fallo al ejecutar subprocess.run
    with patch('subprocess.run', side_effect=Exception("falló el comando")):
        salida, error = ejecutar_script()
        assert salida is None  # No hay salida válida
        assert "falló el comando" in error  # El mensaje de error debe contener el texto simulado

# -------------------------------------------------------
# TEST 3: Valida varios casos de salida JSON usando parametrización
@pytest.mark.parametrize("salida,espera_error,espera_status", [
    ('{"status": "ok", "code": 200}', None, "ok"),  # Caso válido
    ('{"foo": "bar"}', "El JSON no contiene las claves", None),  # Faltan claves importantes
    ('no es json', "JSON inválido", None),  # No es un JSON válido
    ('[]', "La salida no es un objeto JSON", None),  # JSON no es un diccionario
])
def test_validar_salida_json_casos(salida, espera_error, espera_status):
    datos, error = validar_salida_json(salida)
    if espera_error:
        assert datos is None  # Si se espera error, no debe haber datos
        assert espera_error in error  # El mensaje de error debe ser el esperado
    else:
        assert error is None  # No debe haber error
        assert datos["status"] == espera_status  # Debe coincidir con el status esperado

# -------------------------------------------------------
# TEST 4: Verifica que la función escribir() escriba el texto en el archivo
def test_escribir(tmp_path):
    file_path = tmp_path / "salida.txt"  # Archivo temporal
    contenido = "Hola mundo"
    escribir(file_path, contenido)  # Se escribe el contenido en el archivo
    texto = file_path.read_text(encoding='utf-8')  # Se lee el contenido del archivo
    assert texto == contenido  # Debe coincidir con lo que escribimos

# -------------------------------------------------------
# TEST 5: Verifica ejecución completa de main() cuando todo funciona correctamente
def test_main_exito(tmp_path):
    salida_valida = '{"status": "ok", "code": 200}'  # Salida simulada válida
    mock_result = MagicMock()
    mock_result.stdout = salida_valida

    report_path = tmp_path / "adapter_report.md"

    # Simulamos subprocess.run y también la función escribir
    with patch("subprocess.run", return_value=mock_result), \
        patch("adapter.adapter_validate.escribir") as mock_escribir:
        
        from adapter.adapter_validate import main  # Importamos main dinámicamente
        main()  # Ejecutamos main()

        mock_escribir.assert_called_once()  # Se debe llamar una vez
        contenido = mock_escribir.call_args[0][1]  # Extraemos contenido del archivo generado
        assert "Validación exitosa" in contenido  # Verificamos contenido del reporte
        assert "- status: `ok`" in contenido
        assert "- code: `200`" in contenido

# -------------------------------------------------------
# TEST 6: Simula error al ejecutar el script -> main() debe capturarlo y salir
def test_main_error_ejecucion():
    with patch("subprocess.run", side_effect=Exception("falló el script")), \
        patch("adapter.adapter_validate.escribir") as mock_escribir:
        
        from adapter.adapter_validate import main
        with pytest.raises(SystemExit):  # Esperamos que el programa se detenga
            main()
        
        contenido = mock_escribir.call_args[0][1]  # Revisamos el contenido escrito
        assert "Error al ejecutar" in contenido

# -------------------------------------------------------
# TEST 7: Simula salida malformada (no es JSON) -> main() debe dar error y salir
def test_main_json_invalido():
    salida_invalida = 'no es json'
    mock_result = MagicMock()
    mock_result.stdout = salida_invalida

    with patch("subprocess.run", return_value=mock_result), \
        patch("adapter.adapter_validate.escribir") as mock_escribir:
        
        from adapter.adapter_validate import main
        with pytest.raises(SystemExit):  # Debe salir del programa por error de validación
            main()
        
        contenido = mock_escribir.call_args[0][1]
        assert "JSON inválido" in contenido

