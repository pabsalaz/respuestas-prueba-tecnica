-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- Equipo Vicepresidencia de Gestión Humana
-----------------------------------------------------------------------------
-- Fecha Creación: 20240927
-- Última Fecha Modificación: 20240927
-- Autores: juavila
-- Últimos Autores: juavila
-- Descripción: Este código SQL tiene como propósito la creación de dos tablas, proceso.prueba_obligaciones_concatenadas y 
-- proceso.prueba_tasas_concatenadas, las cuales contienen datos transformados y normalizados a partir de las tablas de obligaciones y productos 
-- financieros, respectivamente. Las columnas clave de ambas tablas se concatenan para facilitar su combinación posterior, 
-- con el fin de realizar análisis y cálculos más eficientes.

DROP TABLE IF EXISTS proceso.prueba_obligaciones_concatenadas;

CREATE TABLE proceso.prueba_obligaciones_concatenadas AS
SELECT 
    oblg.radicado, 
    oblg.num_documento, 
    oblg.cod_segm_tasa,
    oblg.cod_subsegm_tasa,
    oblg.cal_interna_tasa,
    oblg.id_producto,
    oblg.tipo_id_producto,
    oblg.valor_inicial,
    oblg.fecha_desembolso,
    oblg.plazo,
    oblg.cod_periodicidad,
    oblg.periodicidad,
    oblg.saldo_deuda,
    oblg.modalidad,
    oblg.tipo_plazo,
    oblg.producto_limpio,
    -- Concatenación de cod_segm_tasa, cod_subsegm_tasa y cal_interna_tasa
    CONCAT(
        CAST(oblg.cod_segm_tasa AS STRING), '-', 
        CAST(oblg.cod_subsegm_tasa AS STRING), '-', 
        oblg.cal_interna_tasa  -- Asumiendo que esta columna ya es de tipo STRING
    ) AS concatenacion_segmento
FROM proceso.prueba_obligaciones_productos_limpios oblg;


DROP TABLE IF EXISTS proceso.prueba_tasas_concatenadas;

CREATE TABLE proceso.prueba_tasas_concatenadas AS
SELECT 
    t.cod_segmento, 
    t.segmento,
    t.cod_subsegmento,
    t.calificacion_riesgos,
    t.tasa_cartera,
    t.tasa_operacion_especifica,
    t.tasa_hipotecario,
    t.tasa_leasing,
    t.tasa_sufi,
    t.tasa_factoring,
    t.tasa_tarjeta,
    -- Concatenación de cod_segmento, cod_subsegmento y calificacion_riesgos
    CONCAT(
        CAST(t.cod_segmento AS STRING), '-', 
        CAST(t.cod_subsegmento AS STRING), '-', 
        t.calificacion_riesgos  -- Asumiendo que esta columna ya es de tipo STRING
    ) AS concatenacion_segmento_riesgo
FROM proceso.prueba_tasas_productos t;
--------------------------------- Query End ---------------------------------