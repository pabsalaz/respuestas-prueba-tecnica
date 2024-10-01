    ### Import las librerías python que necesito para cargar en dataframes de python los datos incluidos en los archivos excel y para luego guardar los resultados en nuevos archivos excel
import pandas as pd
import numpy as np

    ### Obtengo datos de archivos xlsx utilizando la librería pandas

oblig_cli_xlsx = './obligaciones_clientes.xlsx'
df_oblig1 = pd.read_excel(oblig_cli_xlsx)

    ### Obtengo datos de archivos xlsx utilizando la librería pandas

tasas_productos_xlsx = './tasas_productos.xlsx'
df_tasas1 = pd.read_excel(tasas_productos_xlsx)

    ### Defino función para identificar el producto de cada obligacion y crear el nuevo campo 'producto'
def definir_producto(row):
    id_producto = row['id_producto'].lower()
    if 'tarjeta' in id_producto:
        return 'tarjeta'
    elif 'cartera' in id_producto and 'leasing cartera' not in id_producto:
        return 'cartera'
    elif 'hipotecario' in id_producto:
        return 'hipotecario'
    elif 'leasing' in id_producto:
        return 'leasing'
    elif 'operacion_especifica' in id_producto:
        return 'operacion_especifica'
    elif 'factoring' in id_producto:
        return 'factoring'
    elif 'sufi' in id_producto:
        return 'sufi'
    else:
        return 'producto por definir'
    
    ### Aplico función a cada fila del dataframe con las obligaciones de los clientes para definir el producto de cada obligación
df_oblig1['producto'] = df_oblig1.apply(definir_producto, axis=1)

    ### Uno al dataframe de obligaciones los campos del dataframe con las tasas

df_oblig3 = pd.merge(df_oblig1, df_tasas1, 
                        left_on=['cod_segm_tasa', 'cod_subsegm_tasa', 'cal_interna_tasa'], 
                        right_on=['cod_segmento', 'cod_subsegmento', 'calificacion_riesgos'], 
                        how='left')

    ### Defino función para crear el campo 'tasa_producto' que concuerde con el 'producto'
def definir_tasa(row):
    producto = row['producto'].lower()
    if producto=='tarjeta':
        return row['tasa_tarjeta']
    elif producto=='cartera':
        return row['tasa_cartera']
    elif producto=='hipotecario':
        return row['tasa_hipotecario']
    elif producto=='leasing':
        return row['tasa_leasing']
    elif producto=='operacion_especifica':
        return row['tasa_operacion_especifica']
    elif producto=='factoring':
        return row['tasa_factoring']
    elif producto=='sufi':
        return row['tasa_sufi']
    else:
        return 0

    
    ### Aplico función a cada fila del dataframe con las obligaciones de los clientes para obtener la tasa producto que corresponde segun segmento, subsegmento, calificacion riesgo y producto
df_oblig3['tasa_producto'] = df_oblig3.apply(definir_tasa, axis=1)


    ### Genero el nuevo campo tasa efectiva utilzando la librería numpy que permite aplicar la función de pontenciación y redondeo a solo dos decimales la tasa_efectiva

df_oblig3['tasa_efectiva'] = np.power((1 + df_oblig3['tasa_producto']), 1 / df_oblig3['cod_periodicidad']) - 1
df_oblig3['tasa_efectiva'] = df_oblig3['tasa_efectiva'].round(2)

    ### Genero el nuevo campo valor_final multiplicando el valor_inicial por la tasa efectiva calculada anteriormente y redondeo el resultado a solo dos decimales

df_oblig3['valor_final'] = df_oblig3['valor_inicial'] * df_oblig3['tasa_efectiva']
df_oblig3['valor_final'] = df_oblig3['valor_final'].round(2)

    ### Selecciono campos a descargar en documento con el valor final calculado

campos = ['radicado',
          'num_documento',
          'cod_segm_tasa',
          'cod_subsegm_tasa',	
          'cal_interna_tasa',	
          'id_producto',	
          'tipo_id_producto',	
          'valor_inicial',	
          'fecha_desembolso',	
          'plazo',	
          'cod_periodicidad',	
          'periodicidad',	
          'saldo_deuda',	
          'modalidad',	
          'tipo_plazo',	
          'producto',	
          'tasa_producto',	
          'tasa_efectiva',	
          'valor_final']
base_valor_final = df_oblig3[campos]

    ### Se guarda nuevo archivo xlsx con el resultado luego de calcular el valor final para cada obligacion

base_valor_final.to_excel(('base_valor_final_python.xlsx'))

    ### Se guarda nuevo archivo xlsx con el resumen de clientes y la suma del valor final de sus obligaciones cuando la cuenta de productos es mayor o igual a dos

base_resumen_clientes = base_valor_final.groupby('num_documento').agg(cantidad_producto=('producto', 'nunique'), valor_final_total=('valor_final', 'sum')).reset_index()
base_resumen_clientes = base_resumen_clientes[base_resumen_clientes['cantidad_producto'] >= 2]
base_resumen_clientes.to_excel(('base_resumen_clientes.xlsx'))

