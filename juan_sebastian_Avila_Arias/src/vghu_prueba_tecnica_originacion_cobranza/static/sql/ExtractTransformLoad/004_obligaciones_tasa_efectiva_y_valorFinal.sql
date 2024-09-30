-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- Equipo Vicepresidencia de Gestión Humana
-----------------------------------------------------------------------------
-- Fecha Creación: 20240927
-- Última Fecha Modificación: 20240927
-- Autores: juavila
-- Últimos Autores: juavila
-- Descripción: Este código SQL crea una tabla llamada proceso.prueba_obligaciones_con_valor_final, que contiene información procesada de las
-- obligaciones financieras de los clientes, incluidas las tasas efectivas y el valor final de cada obligación



DROP TABLE IF EXISTS proceso.prueba_obligaciones_con_valor_final;

CREATE TABLE proceso.prueba_obligaciones_con_valor_final AS
SELECT 
    num_documento,
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
    -- Cálculo de la tasa efectiva usando cod_periodicidad
    POWER(1 + tasa_aplicada, 1.0 / (12 / cod_periodicidad)) - 1 AS tasa_efectiva,
    -- Cálculo del valor final multiplicando tasa efectiva por el valor inicial
    (POWER(1 + tasa_aplicada, 1.0 / (12 / cod_periodicidad)) - 1) * valor_inicial AS valor_final
FROM proceso.prueba_obligaciones_con_tasas;



--------------------------------- Query End ---------------------------------