-- 1. Agregar columna 'nombre_producto' a la tabla 'obligaciones'
ALTER TABLE obligaciones ADD COLUMN nombre_producto TEXT;

-- 2.. Actualizar 'nombre_producto' utilizando la función personalizada
UPDATE obligaciones
SET nombre_producto = extraer_nombre_producto(id_producto);

-- 3. Agregar columna para la tasa asignada
ALTER TABLE obligaciones ADD COLUMN tasa_asignada REAL;

-- 4. Asignar las tasas utilizando JOIN y redondear a 6 decimales
UPDATE obligaciones
SET tasa_asignada = ROUND((
    SELECT CASE
        WHEN nombre_producto = 'cartera' THEN t.tasa_cartera
        WHEN nombre_producto = 'operacion_especifica' THEN t.tasa_operacion_especifica
        WHEN nombre_producto = 'hipotecario' THEN t.tasa_hipotecario
        WHEN nombre_producto = 'leasing' THEN t.tasa_leasing
        WHEN nombre_producto = 'sufi' THEN t.tasa_sufi
        WHEN nombre_producto = 'factoring' THEN t.tasa_factoring
        WHEN nombre_producto = 'tarjeta' THEN t.tasa_tarjeta
        ELSE NULL
    END
    FROM tasas t
    WHERE t.cod_segmento = obligaciones.cod_segm_tasa
      AND t.cod_subsegmento = obligaciones.cod_subsegm_tasa
      AND t.calificacion_riesgos = obligaciones.cal_interna_tasa
), 6);

-- 5. Calcular la tasa efectiva con 6 decimales
ALTER TABLE obligaciones ADD COLUMN tasa_efectiva REAL;

UPDATE obligaciones
SET tasa_efectiva = ROUND(
    CASE
        WHEN periodicidad = 'MENSUAL' THEN (POWER(1 + tasa_asignada, 1.0 / 12) - 1) 
        WHEN periodicidad = 'BIMENSUAL' THEN (POWER(1 + tasa_asignada, 1.0 / 6) - 1)
        WHEN periodicidad = 'TRIMESTRAL' THEN (POWER(1 + tasa_asignada, 1.0 / 4) - 1) 
        WHEN periodicidad = 'SEMESTRAL' THEN (POWER(1 + tasa_asignada, 1.0 / 2) - 1) 
        WHEN periodicidad = 'ANUAL' THEN tasa_asignada
        ELSE NULL
    END, 6
);

-- 6. Calcular el valor final
ALTER TABLE obligaciones ADD COLUMN valor_final REAL;

UPDATE obligaciones
SET valor_final = valor_inicial * tasa_efectiva;

-- 7. Actualizar o crear la tabla 'clientesConMultiplesProductos'
-- Eliminar la tabla si existe
DROP TABLE IF EXISTS clientesConMultiplesProductos;

-- Crear la tabla
CREATE TABLE clientesConMultiplesProductos (
    num_documento TEXT,
    total_valor_final REAL,
    num_productos INTEGER
);

-- Insertar nuevos datos en la tabla
INSERT INTO clientesConMultiplesProductos (num_documento, total_valor_final, num_productos)
SELECT num_documento, 
       ROUND(SUM(valor_final), 6) AS total_valor_final, 
       COUNT(id_producto) AS num_productos
FROM obligaciones
WHERE saldo_deuda > 0
GROUP BY radicado
HAVING num_productos >= 2;
