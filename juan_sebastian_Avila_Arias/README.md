# Orq 2 prueba tecnica originacion cobranza

## Desarrollado por: [Juan Sebastian Avila Arias]


### Descripción del Proyecto

Este proyecto está diseñado para realizar un proceso completo de **ETL** (Extracción, Transformación y Carga) de datos, enfocado en la información de obligaciones y productos financieros de clientes. El código procesa archivos Excel, ejecuta consultas SQL y genera reportes en formato Excel basados en las transformaciones realizadas. Además, se han implementado buenas prácticas de desarrollo y documentación para asegurar la mantenibilidad y escalabilidad del sistema.


### Objetivos

- Extraer datos desde archivos **Excel** proporcionados.
- Realizar transformaciones en los datos de productos y obligaciones utilizando **SQL**.
- Limpiar y normalizar la información de productos financieros.
- Calcular tasas efectivas y valores finales de las obligaciones.
- Generar resúmenes agregados por cliente, basados en sus productos y tasas.
- Guardar los resultados en archivos **Excel** listos para su análisis.



### Estructura del Proyecto

  
- **Clase `SubirData`:** Sube la información de los archivos Excel de obligaciones y productos financieros a la zona de landing (LZ) para ser procesada.
  
- **Clase `transformarDatosSQL`:** Ejecuta las consultas SQL necesarias para realizar la limpieza, concatenación de segmentos y asignación de tasas a los productos. Además, genera un archivo Excel con los resultados de las transformaciones y resúmenes.
  
- **Clase `TransformarDatosPython`:** Realiza las transformaciones en Python, como la limpieza de productos, la concatenación de segmentos, la asignación de tasas, y el cálculo de valores finales. Genera archivos Excel con los datos finales y los resúmenes por cliente.


### Resultados Generados

En el archivo etl.py que se encuentra en la ruta src\vghu_prueba_tecnica_originacion_cobranza\etl.py se han generado 3 clases para toda la ETL solicitada:

- `obligacionesValorFinalSQL.xlsx`: Archivo que contiene los resultados procesados con las tasas efectivas y valores finales de las obligaciones.
- `obligacionesResumenClientesSQL.xlsx`: Resumen por cliente, mostrando la cantidad de productos y el valor final total de sus obligaciones.
- `prueba_obligaciones_con_valor_final`: Archivo que contiene los resultados procesados con las tasas efectivas y valores finales de las obligaciones (Python).
- `prueba_obligaciones_resumen_clientes`: Resumen por cliente, mostrando la cantidad de productos y el valor final total de sus obligaciones.(Python).


### Documentos Adjuntos

Se adjuntaron los siguientes documentos:

Los resultados se guardaron en la ruta src\vghu_prueba_tecnica_originacion_cobranza\static\Excel\Resultados:

- **`Analisis descriptivo cobranza - Visualización.pdf`**: Documento que presenta el análisis descriptivo realizado a través de las visualizaciones generadas en Power BI.
- **`Resultados del Análisis Descriptivo.pdf`**: Documento que describe los resultados obtenidos tras el análisis de los datos de obligaciones y productos financieros.



### EJECUTAR EL PROYECTO:


## Se recomienda instalar ambiente Virtual

Se recomienda realizar la instalación en un Ambiente Virtual

Realizar la instalación del ambiente virtual dentro de la carpeta del Orquestador escribiendo en la consola: 
    >> "python -m venv .venv"

(Es posible que Visual Studio solicite emplear ese entorno por defecto, le podemos decir que Si, de esta manera cuando se vuelva a abrir el Visual Studio este abrirá por defecto).

Activar el ambiente virtual ubicandose en la nueva carpeta **.venv/Scripts** y escribiendo en la consola **activate**, para acceder a la carpeta podemos acceder con los siguientes comandos:
    >> "cd .venv" > "cd Scripts" > "activate" > cd.. > cd.. > cls
    ó más rápido
    >> "source .venv/Scripts/activate"

Actualizar el Bibliotecario (Importante para mitigar conflictos de librerías):

    >> "python -m pip install --upgrade pip"

    Si se desea verificar antes la versión se puede ejecutar el comando:

    >> "pip list"

    Nota: Es importante que la actualización se haga desde el artifactory, para ello lo más práctico es tener un archivo llamado pip.ini dentro de una carpeta llamada pip en la carpeta del usuario del computador. El archivo pip.ini debe contener lo siguiente:

    [global]
    index-url=https://artifactory.apps.bancolombia.com/api/pypi/pypi-bancolombia/simple
    trusted-host=artifactory.apps.bancolombia.com
    user=false

Instalar los paquetes que requiere el orquetador escribiendo en la consola: 
    >> "pip install -e." (Más rápido) o 
    >> "pip install --no-cache-dir -e." (En caso que no funcione la anterior probar con esta)

Escribir el DSN y usuario en el archivo config.json, ubicado en la carpeta: 
    src > static > config.json.


## Prerrequisitos

El paquete ha sido generado para la versión de Python
	
    3.9.12
    
. Las librerías o paquetes necesarios para la ejecución son:
>> "pyodbc==4.0.27"
>> "orquestador2>=1.2.2"
>> "openpyxl=3.1.5"


## Ejecución

Si se trabaja con un ambiente virtual, se debe activar primero. 

*Se debe ejecutar el siguiente comando:*

 >> "python -m vghu_prueba_tecnica_originacion_cobranza.ejecucion"



## Prueba Funcional 

1. Configuración del Ambiente Virtual
Crear y activar el ambiente virtual:

>>"source .venv/Scripts/activate"

Instalar las dependencias:

>> "pip install -e ."


2. Cargar los Datos

Asegúrate de que los archivos de insumos (obligaciones y tasas) están en la carpeta src/vghu_prueba_tecnica_originacion_cobranza/static/Excel/Insumos/.

>> obligaciones_clientes.xlsx
>> tasas_productos.xlsx

3. Ejecutar el Proyecto
Una vez configurado el ambiente virtual y cargados los datos, el siguiente paso es ejecutar el proyecto. En la raíz del proyecto, ejecuta:


>> python -m vghu_prueba_tecnica_originacion_cobranza.ejecucion

4. Verificar Resultados
Archivos generados: Después de la ejecución, revisa los archivos de salida en la carpeta src/vghu_prueba_tecnica_originacion_cobranza/static/Excel/Resultados/:

>> obligacionesValorFinalSQL.xlsx: Contiene los resultados procesados con tasas efectivas y valores finales.
>> obligacionesResumenClientesSQL.xlsx: Resumen por cliente, mostrando la cantidad de productos y el valor final total.
>> prueba_obligaciones_con_valor_final.xlsx: Resultados generados en Python con tasas efectivas y valores finales.
>> prueba_obligaciones_resumen_clientes.xlsx: Resumen por cliente en Python, mostrando la cantidad de productos y valores finales.



## Estructura de las Carpetas
La estructura del proyecto es la siguiente:

VGHU-PRUEBA-TECNICA-ORIGINACION-COBRANZA/
│
├── .azuredevops/                  # Configuración para integración continua (si aplica)
├── .venv/                         # Ambiente virtual del proyecto
├── logs/                          # Logs de ejecución
├── src/
│   └── vghu_prueba_tecnica_originacion_cobranza/
│       ├── __pycache__/           # Archivos compilados por Python
│       ├── static/
│       │   ├── Excel/
│       │   │   ├── Insumos/       # Archivos de entrada (obligaciones y tasas)
│       │   │   │   ├── obligaciones_clientes.xlsx
│       │   │   │   ├── tasas_productos.xlsx
│       │   │   ├── Resultados/    # Archivos de resultados
│       │   │   │   ├── obligacionesValorFinalSQL.xlsx
│       │   │   │   ├── obligacionesResumenClientesSQL.xlsx
│       │   │   │   ├── prueba_obligaciones_con_valor_final.xlsx
│       │   │   │   ├── prueba_obligaciones_resumen_clientes.xlsx
│       │   │── Resultados/    # Documentos PDF con los análisis descriptivos
│       │   │   │   ├── Analisis descriptivo cobranza - Visualización.pdf
│       │   │   │   ├── Resultados del Análisis Descriptivo.pdf
│       ├── sql/                   # SQLs utilizados para la transformación de datos
│       ├── config.json            # Configuración del proyecto
│       ├── ejecucion.py           # Archivo de ejecución principal del proyecto
│       ├── etl.py                 # Código para el proceso de ETL
├── .gitignore                     # Archivos y carpetas ignorados por Git
├── README.md                      # Documentación del proyecto
├── setup.py                       # Archivo de configuración del paquete Python
├── setup.cfg                      # Configuraciones adicionales del proyecto
├── versioneer.py                  # Manejo de versiones del proyecto
└── MANIFEST.in                    # Archivos a incluir en la distribución del proyecto
