    ### Import las librerías python que necesito para subir los datos incluidos en los archivos excel, para ejecutar las consultas SQL necesarias y para guardar los resultados
from sparky_bc import Sparky
import pandas as pd
import getpass

    ### Defino instancia para conectarme al entorno SQL con el que trabajaré mediante la librería Sparky
user = getpass.getuser()
spk = Sparky(user,dsn='IMPALA_PROD')
lz = spk.helper

    ### Obtengo datos de archivos xlsx utilizando la librería pandas

oblig_cli_xlsx = './obligaciones_clientes.xlsx'
df_oblig = pd.read_excel(oblig_cli_xlsx)

    ### Inicio carga al entorno SQL mediante el uso de la libreria Sparky: 
            # 1. Elimino tablas en caso que ya esten creadas. 
            # 2. Cargo tablas nuevamente. 
            # 3. Creo nuevas tablas con formato requerido. 
            # 4. Inserto datos en tablas formateadas previamente.

lz.ejecutar_consulta('drop table if exists proceso.ruortega_oblig_cli')
lz.ejecutar_consulta(
    '''CREATE TABLE proceso.ruortega_oblig_cli
        (
            radicado bigint,
            num_documento bigint,
            cod_segm_tasa string,
            cod_subsegm_tasa int,
            cal_interna_tasa string,
            id_producto string,
            tipo_id_producto string,
            valor_inicial double,
            fecha_desembolso timestamp,
            plazo double,
            cod_periodicidad decimal(5,0),
            periodicidad string,
            saldo_deuda double,
            modalidad string,
            tipo_plazo string
        )
        STORED AS PARQUET
        ;'''
)
lz.ejecutar_consulta('drop table if exists proceso.ruortega_oblig_cli_0 purge')
spk.subir_df (df_oblig, 'proceso.ruortega_oblig_cli_0')
lz.ejecutar_consulta(
    '''INSERT OVERWRITE proceso.ruortega_oblig_cli
        SELECT
            CAST(radicado as bigint) as radicado,
            CAST(num_documento as bigint) as num_documento,
            CAST(cod_segm_tasa as string) as cod_segm_tasa,
            CAST(cod_subsegm_tasa as int) as cod_subsegm_tasa,
            CAST(cal_interna_tasa as string) as cal_interna_tasa,
            CAST(id_producto as string) as id_producto,
            CAST(tipo_id_producto as string) as tipo_id_producto,
            CAST(valor_inicial as double) as valor_inicial,
            CAST(fecha_desembolso as timestamp) as fecha_desembolso,
            CAST(plazo as double) as plazo,
            CAST(cod_periodicidad as decimal(5,0)) as cod_periodicidad,
            CAST(periodicidad as string) as periodicidad,
            CAST(saldo_deuda as double) as saldo_deuda,
            CAST(modalidad as string) as modalidad,
            CAST(tipo_plazo as string) as tipo_plazo
        FROM proceso.ruortega_oblig_cli_0
        ;''')
lz.ejecutar_consulta('compute stats proceso.ruortega_oblig_cli')

    ### Obtengo datos de archivos xlsx utilizando la librería pandas

tasas_productos_xlsx = './tasas_productos.xlsx'
df_tasas = pd.read_excel(tasas_productos_xlsx)

    ### Inicio carga al entorno SQL mediante el uso de la libreria Sparky: 
            # 1.Elimino tablas en caso que ya esten creadas. 
            # 2. Cargo tablas nuevamente. 
            # 3. Creo nuevas tablas con formato requerido. 
            # 4. Inserto datos en tablas formateadas previamente.

lz.ejecutar_consulta('drop table if exists proceso.ruortega_tasas_prod')
lz.ejecutar_consulta(
    '''CREATE TABLE proceso.ruortega_tasas_prod
        (
            cod_segmento string,
            segmento string,
            cod_subsegmento string,
            calificacion_riesgos string,
            tasa_cartera double,
            tasa_operacion_especifica double,
            tasa_hipotecario double,
            tasa_leasing double,
            tasa_sufi double,
            tasa_factoring double,
            tasa_tarjeta double
        )
        STORED AS PARQUET
        ;'''
)
lz.ejecutar_consulta('drop table if exists proceso.ruortega_tasas_prod_0 purge')
spk.subir_df (df_tasas, 'proceso.ruortega_tasas_prod_0')
lz.ejecutar_consulta(
    '''INSERT OVERWRITE proceso.ruortega_tasas_prod
        SELECT
            CAST(cod_segmento as string)  as cod_segmento,
            CAST(segmento as string)  as segmento,
            CAST(cod_subsegmento as string)  as cod_subsegmento,
            CAST(calificacion_riesgos as string)  as calificacion_riesgos,
            CAST(tasa_cartera as double)  as tasa_cartera,
            CAST(tasa_operacion_especifica as double)  as tasa_operacion_especifica,
            CAST(tasa_hipotecario as double)  as tasa_hipotecario,
            CAST(tasa_leasing as double)  as tasa_leasing,
            CAST(tasa_sufi as double)  as tasa_sufi,
            CAST(tasa_factoring as double)  as tasa_factoring,
            CAST(tasa_tarjeta as double)  as tasa_tarjeta
        FROM proceso.ruortega_tasas_prod_0
        ;''')
lz.ejecutar_consulta('compute stats proceso.ruortega_tasas_prod')


    ### Se ejecuta script SQL con el que transformamos los datos recibidos para definir nuevos campos y/o calcular variables requeridas

SQL = './transformar_calcular.sql'
lz.ejecutar_archivo(SQL)

    ### Se guarda nuevo archivo xlsx con el resultado luego de calcular el valor final para cada obligacion
base_valor_final = lz.obtener_dataframe('select * from proceso.ruortega_calcular_valor_final')
base_valor_final.to_excel(('base_valor_final_SQL.xlsx'))

    ### Se guarda nuevo archivo xlsx con el resumen de clientes y la suma del valor final de sus obligaciones cuando la cuenta de productos es mayor o igual a dos
base_resumen_clientes = lz.obtener_dataframe('select * from proceso.ruortega_valor_final_resumen')
base_resumen_clientes.to_excel(('base_resumen_clientes_SQL.xlsx'))

