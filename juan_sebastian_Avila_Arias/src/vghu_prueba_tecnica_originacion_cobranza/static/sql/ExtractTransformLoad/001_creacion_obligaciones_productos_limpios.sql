-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- Equipo Vicepresidencia de Gestión Humana
-----------------------------------------------------------------------------
-- Fecha Creación: 20240927
-- Última Fecha Modificación: 20240927
-- Autores: juavila
-- Últimos Autores: juavila
-- Descripción: Este código SQL tiene como objetivo crear una nueva tabla llamada proceso.prueba_obligaciones_productos_limpios a partir de una 
-- tabla existente llamada proceso.prueba_obligaciones_clientes. Durante este proceso, se seleccionan y transforman varias columnas 
--de la tabla original, y se realizan ciertas operaciones para limpiar y normalizar la columna id_producto.


DROP TABLE IF EXISTS proceso.prueba_obligaciones_productos_limpios;

CREATE TABLE proceso.prueba_obligaciones_productos_limpios AS
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
    LOWER(
        CASE 
            -- Si el id_producto finaliza en 'Cartera Total' o 'cartera'
            WHEN REGEXP_LIKE(oblg.id_producto, '-?\\s*cartera tota[l]*$', 'i') THEN 'cartera'
            WHEN REGEXP_LIKE(oblg.id_producto, '-?\\s*cartera$', 'i') THEN 'cartera'
            
            -- Si el id_producto finaliza en 'Tarjeta de Crédito' o 'tarjeta'
            WHEN REGEXP_LIKE(oblg.id_producto, '-?\\s*tarjeta de cr[ée]dito$', 'i') THEN 'tarjeta'
            WHEN REGEXP_LIKE(oblg.id_producto, '-?\\s*tarjeta$', 'i') THEN 'tarjeta'
            
            -- Si el id_producto finaliza en 'tarjeta de crÃ©dito' (corrige la codificación)
            WHEN REGEXP_LIKE(oblg.id_producto, '-?\\s*tarjeta de crÃ©dito$', 'i') THEN 'tarjeta'

            -- Si el id_producto finaliza en 'operacion_especifica'
            WHEN REGEXP_LIKE(oblg.id_producto, '-?\\s*operacion_especifica$', 'i') THEN 'operacion_especifica'
            
            -- Si el id_producto finaliza en 'sufi'
            WHEN REGEXP_LIKE(oblg.id_producto, '-?\\s*sufi$', 'i') THEN 'sufi'
            
            -- Si el id_producto finaliza en 'leasing'
            WHEN REGEXP_LIKE(oblg.id_producto, '-?\\s*leasing$', 'i') THEN 'leasing'
            
            -- Si el id_producto finaliza en 'hipotecario'
            WHEN REGEXP_LIKE(oblg.id_producto, '-?\\s*hipotecario$', 'i') THEN 'hipotecario'
            
            -- Si el id_producto finaliza en 'factoring'
            WHEN REGEXP_LIKE(oblg.id_producto, '-?\\s*factoring$', 'i') THEN 'factoring'
            
            -- De lo contrario, devuelve el texto original sin números ni guiones
            ELSE TRIM(REGEXP_REPLACE(oblg.id_producto, '^[0-9]+-*\\s*', ''))
        END
    ) AS producto_limpio
FROM proceso.prueba_obligaciones_clientes oblg;
