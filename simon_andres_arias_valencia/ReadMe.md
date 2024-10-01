# Prueba Técnica para Ingeniero de Datos

Este repositorio contiene la solución a la prueba técnica propuesta para el rol de Ingeniero de Datos. La prueba incluye la manipulación de datos utilizando SQL y Python, el análisis de tasas y productos financieros, y la implementación de buenas prácticas de desarrollo.

## Estructura del Proyecto

- **Parte 1:** Implementación de la solución en SQL para agregar tasas, calcular tasas efectivas y realizar agregaciones por cliente.
- **Parte 2:** Desarrollo de la solución en Python utilizando Pandas para replicar las tareas de la Parte 1.
- **Parte 3:** Análisis descriptivo del comportamiento de los productos financieros versus las tasas utilizando herramientas de visualización como Power BI.

### Archivos Incluidos en la Carpeta Scripts

- **`_Script_Punto_1.ipynb`**: Notebook con la implementación de la Parte 1 utilizando Python y la librería Pandas.
- **`_Script_Punto_2.ipynb`**: Notebook con la implementación de la Parte 2, continuando con los análisis solicitados.
- **`consulta_obligaciones.sql`**: Script SQL que contiene las consultas necesarias para la Parte 1.
- **`utils.py`**: Módulo Python con funciones auxiliares para el procesamiento de datos.
- **`PBI`**: PBI con análisis descriptivo.
-**`analisisDescriptivo.docx`**: Documento con análisis descriptivo. 

## Requisitos Previos

- Python 3.8 o superior
- Librerías de Python:
  - `pandas`
  - `numpy`
- Jupyter Notebook
- Power BI (para el análisis descriptivo)

## Instalación

1. Clonar este repositorio:
   ```bash
   git clone <URL_DEL_REPOSITORIO>

2. Crear un entorno virtual e instalar las dependencias:
   ```bash
   python -m venv env
   source env/bin/activate  # En Windows: env\Scripts\activate
   pip install -r requirements.txt


## Descripción de los Ejercicios

### Parte 1: Implementación en SQL
- **Objetivo:** Procesar los datos de las obligaciones de los clientes y agregar la tasa correspondiente al producto.
- **Pasos Realizados:**
  1. Asignar la tasa correspondiente a cada producto.
  2. Convertir la tasa a una tasa efectiva usando la fórmula proporcionada.
  3. Calcular el valor final multiplicando la tasa efectiva por el valor inicial.
  4. Agrupar las obligaciones por cliente, sumando el valor final y seleccionando solo aquellos con dos o más productos.

### Parte 2: Implementación en Python
- **Objetivo:** Replicar el proceso de la Parte 1 utilizando Python y la librería Pandas.
- **Pasos Realizados:**


### Parte 3: Análisis Descriptivo
- **Objetivo:** Analizar el comportamiento de los productos frente a las tasas.
- **Herramientas:** Power BI para visualización y análisis descriptivo.
- **Resultado:** Gráficos y hallazgos documentados en un informe aparte.

## Cómo Ejecutar los Scripts
1. **Python:** Abrir y ejecutar los notebooks `_Script_Punto_1.ipynb` y `_Script_Punto_2.ipynb` utilizando Jupyter Notebook.
2. **Análisis Descriptivo:** Utilizar Power BI para cargar los datos procesados y generar las visualizaciones necesarias. Para este es necesario tener python activo en power BI y cambiar el parametro llamado ruta_data que va hasta la carpeta data.