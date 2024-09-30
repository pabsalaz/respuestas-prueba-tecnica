# -*- coding: utf-8 -*-

"""
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- Equipo Vicepresidencia de Gestión Humana
-----------------------------------------------------------------------------
-- Fecha Creación: 20240927
-- Última Fecha Modificación: 20240927
-- Autores: juavila
-- Últimos Autores: juavila
-- Descripción: Script de ejecución de los ETLs
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
"""
from orquestador2.step 	    import Step
import pandas as pd
import os


class ExtractTransformLoad(Step):
    def ejecutar(self):
        print("Quiero dar las gracias por esta oportunidad, saludos")

class SubirData(Step):
    def ejecutar(self):
        try:
            print("Subir data desde un excel/csv a la LZ")
            sparky = self.getSparky()

            # Verificar que la ruta sea correcta
            ruta = self.getFolderPath() + "Excel/Insumos/"
            if not os.path.exists(ruta):
                raise FileNotFoundError(f"La ruta {ruta} no existe.")

            # Leer archivos Excel, con validación de que los archivos existan
            archivo_obligaciones = os.path.join(ruta, "obligaciones_clientes.xlsx")
            archivo_tasas = os.path.join(ruta, "tasas_productos.xlsx")

            if not os.path.exists(archivo_obligaciones):
                raise FileNotFoundError(f"El archivo {archivo_obligaciones} no fue encontrado.")
            if not os.path.exists(archivo_tasas):
                raise FileNotFoundError(f"El archivo {archivo_tasas} no fue encontrado.")

            df_obligaciones = pd.read_excel(archivo_obligaciones)
            df_tasas = pd.read_excel(archivo_tasas)

            self.log.info(f"Archivos leídos correctamente: {archivo_obligaciones} y {archivo_tasas}")
            self.log.info(f"Cantidad de registros en obligaciones: {len(df_obligaciones)}")
            self.log.info(f"Cantidad de registros en tasas: {len(df_tasas)}")

            # Subir df_obligaciones a la tabla en la LZ
            sparky.subir_df(df=df_obligaciones, nombre_tabla="prueba_obligaciones_clientes",
                            zona="proceso", modo="overwrite")
            self.log.info(f"Datos de obligaciones cargados exitosamente en 'prueba_obligaciones_clientes'")

            # Subir df_tasas a la tabla en la LZ
            sparky.subir_df(df=df_tasas, nombre_tabla="prueba_tasas_productos",
                            zona="proceso", modo="overwrite")
            self.log.info(f"Datos de tasas cargados exitosamente en 'prueba_tasas_productos'")

        except FileNotFoundError as fnf_error:
            self.log.error(f"Error: {fnf_error}")
        except Exception as e:
            self.log.error(f"Ocurrió un error inesperado: {e}")


class transformarDatosSQL(Step):
    def ejecutar(self):
        try:
            print("Ejecuta todos los SQL que hacen las transformaciones necesarias del punto 1")

            # Obtener la ruta de los archivos SQL
            ruta = self.getSQLPath()
            if not os.path.exists(ruta):
                raise FileNotFoundError(f"La ruta de SQL {ruta} no existe.")

            # Log de inicio de la ejecución de SQL
            self.log.info(f"Iniciando la ejecución de los archivos SQL en la ruta: {ruta}")

            # Ejecutar los SQL en el directorio
            self.executeFolder(ruta)

            self.log.info(f"Ejecución de los SQL en la ruta {ruta} finalizada correctamente.")

            # Volver un dataframe la consulta de Obligaciones con Valor_Final
            help = self.getHelper()
            obligacionesValorFinal = help.obtener_dataframe(consulta = f"""SELECT num_documento,
                                                                            id_producto,
                                                                            producto,
                                                                            cod_segm_tasa,
                                                                            segmento,
                                                                            cod_subsegm_tasa,
                                                                            cal_interna_tasa,
                                                                            valor_inicial,
                                                                            plazo,
                                                                            cod_periodicidad,
                                                                            periodicidad,
                                                                            tasa_aplicada,
                                                                            tasa_efectiva,
                                                                            valor_final FROM proceso.prueba_obligaciones_con_valor_final""") 
            
            obligacionesResumenClientes = help.obtener_dataframe(consulta = f"""SELECT num_documento, cantidad_productos, total_valor_final
                                                                  FROM proceso.prueba_obligaciones_resumen_clientes""") 

        
            # Verificar o crear la carpeta "Excel/Resultados"
            ruta_resultados = os.path.join(self.getFolderPath(), "Excel/Resultados")
            if not os.path.exists(ruta_resultados):
                os.makedirs(ruta_resultados)
                self.log.info(f"Carpeta creada: {ruta_resultados}")

            # Guardar e imprimir resultados
            obligacionesValorFinal.to_excel(os.path.join(ruta_resultados, "obligacionesValorFinalSQL.xlsx"), index=False)
            print(obligacionesValorFinal.shape)
            self.log.info("Datos guardados exitosamente en 'obligacionesValorFinalSQL.xlsx'")

            # Guardar e imprimir resultados
            obligacionesResumenClientes.to_excel(os.path.join(ruta_resultados, "obligacionesResumenClientesSQL.xlsx"), index=False)
            print(obligacionesResumenClientes.shape)
            self.log.info("Datos guardados exitosamente en 'obligacionesResumenClientesSQL.xlsx'")

        except FileNotFoundError as fnf_error:
            self.log.error(f"Error de archivo no encontrado: {fnf_error}")

        except Exception as e:
            self.log.error(f"Ocurrió un error inesperado durante la ejecución de los SQL: {e}")
            raise e  # Relanzar la excepción para asegurar que no se ignoren errores críticos


class TransformarDatosPython(Step):
    """
    Esta clase maneja todo el proceso de carga, transformación y generación de un resumen
    por cliente a partir de datos de obligaciones y tasas de productos.
    """

    def ejecutar(self):
        """
        Método principal de la clase que ejecuta el proceso de transformación y cálculo de datos.
        Sigue la misma estructura de logging y manejo de errores como las otras clases.
        """
        try:
            # Cargar los datos
            self.cargar_datos()

            # Limpiar los productos en la tabla de obligaciones
            self.limpiar_productos()

            # Concatenar las columnas necesarias en ambos DataFrames
            self.concatenar_segmentos()

            # Unir las tablas de obligaciones y tasas
            self.unir_tasas()

            # Calcular la tasa efectiva y el valor final
            self.calcular_tasa_efectiva()

            # Guardar la tabla de obligaciones con valor final
            self.guardar_tabla_obligaciones_valor_final()

            # Generar resumen por cliente
            df_resumen_final = self.resumen_por_cliente()

            # Guardar la tabla resumen por cliente
            self.guardar_tabla_resumen_clientes(df_resumen_final)

            self.log.info("Proceso completado con éxito y archivos guardados.")
        
        except FileNotFoundError as e:
            self.log.error(f"Error al cargar archivos: {e}")
        except Exception as e:
            self.log.error(f"Ocurrió un error inesperado durante el proceso: {e}")
            raise e

    def cargar_datos(self):
        """
        Carga los datos de obligaciones y tasas desde archivos Excel o CSV.
        Levanta un error si los archivos no se encuentran en la ruta especificada.
        """
        try:
            ruta = self.getFolderPath() + "Excel/Insumos/"
            archivo_obligaciones = os.path.join(ruta, "obligaciones_clientes.xlsx")
            archivo_tasas = os.path.join(ruta, "tasas_productos.xlsx")

            # Leer los archivos
            self.df_obligaciones = pd.read_excel(archivo_obligaciones)
            self.df_tasas = pd.read_excel(archivo_tasas)
            self.log.info("Datos cargados correctamente.")
        
        except FileNotFoundError as e:
            self.log.error(f"Error al cargar archivos: {e}")
            raise

    def limpiar_productos(self):
        """
        Limpia y normaliza la columna 'id_producto' en el DataFrame de obligaciones.
        """
        def limpiar_producto(producto):
            producto = producto.lower()
            if "cartera total" in producto or "cartera" in producto:
                return "cartera"
            if "tarjeta de crédito" in producto or "tarjeta" in producto:
                return "tarjeta"
            if "operacion_especifica" in producto:
                return "operacion_especifica"
            if "sufi" in producto:
                return "sufi"
            if "leasing" in producto:
                return "leasing"
            if "hipotecario" in producto:
                return "hipotecario"
            if "factoring" in producto:
                return "factoring"
            return producto.strip()

        # Aplicar la función de limpieza a la columna 'id_producto'
        self.df_obligaciones['producto_limpio'] = self.df_obligaciones['id_producto'].apply(limpiar_producto)
        self.log.info("Productos limpios.")

    def concatenar_segmentos(self):
        """
        Concatena las columnas cod_segm_tasa, cod_subsegm_tasa, y cal_interna_tasa en el
        DataFrame de obligaciones, y las columnas cod_segmento, cod_subsegmento, y calificacion_riesgos
        en el DataFrame de tasas.
        """
        # Concatenar columnas en df_obligaciones
        self.df_obligaciones['concatenacion_segmento'] = (
            self.df_obligaciones['cod_segm_tasa'].astype(str) + '-' +
            self.df_obligaciones['cod_subsegm_tasa'].astype(str) + '-' +
            self.df_obligaciones['cal_interna_tasa']
        )
        self.log.info("Concatenación de segmentos en obligaciones.")

        # Concatenar columnas en df_tasas
        self.df_tasas['concatenacion_segmento_riesgo'] = (
            self.df_tasas['cod_segmento'].astype(str) + '-' +
            self.df_tasas['cod_subsegmento'].astype(str) + '-' +
            self.df_tasas['calificacion_riesgos']
        )
        self.log.info("Concatenación de segmentos en tasas.")

    def unir_tasas(self):
        """
        Une las tablas de obligaciones y tasas según las concatenaciones de segmentos generadas anteriormente.
        Asigna la tasa correspondiente al producto de cada obligación.
        """
        # Realizar un merge entre las tablas de obligaciones y tasas
        self.df_obligaciones_con_tasas = pd.merge(
            self.df_obligaciones,
            self.df_tasas,
            how="left",
            left_on="concatenacion_segmento",
            right_on="concatenacion_segmento_riesgo"
        )

        # Asignar la tasa correspondiente al producto limpio
        def asignar_tasa(row):
            if row['producto_limpio'] == 'cartera':
                return row['tasa_cartera']
            if row['producto_limpio'] == 'operacion_especifica':
                return row['tasa_operacion_especifica']
            if row['producto_limpio'] == 'leasing':
                return row['tasa_leasing']
            if row['producto_limpio'] == 'tarjeta':
                return row['tasa_tarjeta']
            if row['producto_limpio'] == 'sufi':
                return row['tasa_sufi']
            if row['producto_limpio'] == 'factoring':
                return row['tasa_factoring']
            if row['producto_limpio'] == 'hipotecario':
                return row['tasa_hipotecario']
            return None

        # Aplicar la función para asignar tasas
        self.df_obligaciones_con_tasas['tasa_aplicada'] = self.df_obligaciones_con_tasas.apply(asignar_tasa, axis=1)
        self.log.info("Tasas asignadas.")

    def calcular_tasa_efectiva(self):
        """
        Calcula la tasa efectiva (te) y el valor final multiplicando la tasa efectiva por el valor inicial.
        """
        # Calcular la tasa efectiva
        self.df_obligaciones_con_tasas['tasa_efectiva'] = (
            (1 + self.df_obligaciones_con_tasas['tasa_aplicada']) ** 
            (1 / (12 / self.df_obligaciones_con_tasas['cod_periodicidad'])) - 1
        )

        # Calcular el valor final
        self.df_obligaciones_con_tasas['valor_final'] = (
            self.df_obligaciones_con_tasas['tasa_efectiva'] * self.df_obligaciones_con_tasas['valor_inicial']
        )
        self.log.info("Tasa efectiva y valor final calculados.")

    def guardar_tabla_obligaciones_valor_final(self):
        """
        Guarda el DataFrame de obligaciones con valor final en un archivo Excel.
        """
        ruta_resultados = os.path.join(self.getFolderPath(), "Excel/Resultados")
        if not os.path.exists(ruta_resultados):
            os.makedirs(ruta_resultados)
            self.log.info(f"Carpeta creada: {ruta_resultados}")

        # Guardar el DataFrame en un archivo Excel
        self.df_obligaciones_con_tasas.to_excel(os.path.join(ruta_resultados, "prueba_obligaciones_con_valor_final.xlsx"), index=False)
        self.log.info("Tabla 'prueba_obligaciones_con_valor_final' guardada correctamente.")

    def resumen_por_cliente(self):
        """
        Crea un resumen por cliente que suma el valor final de todas las obligaciones.
        Solo incluye a los clientes con 2 o más productos distintos.
        """
        # Agrupar por cliente y sumar valor_final
        df_resumen = self.df_obligaciones_con_tasas.groupby('num_documento').agg(
            cantidad_productos=('id_producto', 'nunique'),
            total_valor_final=('valor_final', 'sum')
        ).reset_index()

        # Filtrar clientes con 2 o más productos
        df_resumen_filtrado = df_resumen[df_resumen['cantidad_productos'] >= 2]
        self.log.info("Resumen por cliente calculado.")
        return df_resumen_filtrado

    def guardar_tabla_resumen_clientes(self, df_resumen_final):
        """
        Guarda el resumen por cliente en un archivo Excel.
        """
        ruta_resultados = os.path.join(self.getFolderPath(), "Excel/Resultados")
        if not os.path.exists(ruta_resultados):
            os.makedirs(ruta_resultados)
            self.log.info(f"Carpeta creada: {ruta_resultados}")

        # Guardar el DataFrame en un archivo Excel
        df_resumen_final.to_excel(os.path.join(ruta_resultados, "prueba_obligaciones_resumen_clientes.xlsx"), index=False)
        self.log.info("Tabla 'prueba_obligaciones_resumen_clientes' guardada correctamente.")

 