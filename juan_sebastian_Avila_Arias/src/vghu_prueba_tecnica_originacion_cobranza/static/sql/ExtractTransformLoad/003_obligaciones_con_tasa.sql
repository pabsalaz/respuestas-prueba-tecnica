-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- Equipo Vicepresidencia de Gestión Humana
-----------------------------------------------------------------------------
-- Fecha Creación: 20240927
-- Última Fecha Modificación: 20240927
-- Autores: juavila
-- Últimos Autores: juavila
-- Descripción: Este código SQL realiza la creación de la tabla proceso.prueba_obligaciones_con_tasas, cuyo objetivo es combinar la información de las
-- obligaciones financieras de los clientes con las tasas correspondientes, utilizando una combinación de columnas concatenadas para realizar la relación
-- entre ambas tablas


DROP TABLE IF EXISTS proceso.prueba_obligaciones_con_tasas;

CREATE TABLE proceso.prueba_obligaciones_con_tasas AS
SELECT 
    oblg.num_documento, 
    oblg.id_producto, 
    oblg.producto_limpio AS producto, 
    oblg.cod_segm_tasa,
    oblg.cod_subsegm_tasa,
    oblg.cal_interna_tasa,
    oblg.plazo,
    oblg.cod_periodicidad,
    oblg.periodicidad,
    oblg.valor_inicial,
    t.concatenacion_segmento_riesgo, 
    t.segmento,
    oblg.concatenacion_segmento,
    -- Asignar la tasa dependiendo del producto
    CASE 
        WHEN oblg.producto_limpio = 'cartera' THEN t.tasa_cartera
        WHEN oblg.producto_limpio = 'operacion_especifica' THEN t.tasa_operacion_especifica
        WHEN oblg.producto_limpio = 'leasing' THEN t.tasa_leasing
        WHEN oblg.producto_limpio = 'tarjeta' THEN t.tasa_tarjeta
        WHEN oblg.producto_limpio = 'sufi' THEN t.tasa_sufi
        WHEN oblg.producto_limpio = 'factoring' THEN t.tasa_factoring
        WHEN oblg.producto_limpio = 'hipotecario' THEN t.tasa_hipotecario
        ELSE NULL
    END AS tasa_aplicada
FROM proceso.prueba_obligaciones_concatenadas oblg
LEFT JOIN proceso.prueba_tasas_concatenadas t
ON oblg.concatenacion_segmento = t.concatenacion_segmento_riesgo;

--------------------------------- Query End ---------------------------------