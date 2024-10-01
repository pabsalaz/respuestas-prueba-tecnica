-- PARTE 1:

-- 1.1 Se requiere tomar las obligaciones de cada cliente y agregar la tasa correspondiente al producto asignadoSELECT
    o.num_documento,
    o.id_nombre_producto,
    p.nombre_producto,
	ic.cod_segmento,
    ic.cod_subsegmento,
    ic.calificacion_riesgo,
    o.valor_inicial,
    o.saldo_deuda,
	pr.cod_periodicidad,
	pr.periodicidad,
    t.valor_tasa
FROM
    obligaciones_clientes AS o
INNER JOIN info_clientes AS ic ON o.num_documento = ic.num_documento
INNER JOIN productos AS p ON o.id_nombre_producto = p.id_nombre_producto
INNER JOIN tasas t ON 
    p.id_nombre_producto = t.id_nombre_producto AND
    ic.calificacion_riesgo = t.calificacion_riesgo AND
    ic.cod_segmento = t.cod_segmento AND
    ic.cod_subsegmento = t.cod_subsegmentoINNER JOIN periodicidad AS pr	ON (o.cod_periodicidad = pr.cod_periodicidad)ORDER BY num_documento DESC;-- 1.2 Se debe convertir la tasa a una tasa efectivaSELECT
    o.num_documento,
    p.nombre_producto,
    ic.cod_segmento,
    ic.calificacion_riesgo,
    o.valor_inicial,
    o.saldo_deuda,
    pr.cod_periodicidad,
    pr.periodicidad,
    t.valor_tasa,
    -- Cálculo de la tasa efectiva
	POWER(1 + (t.valor_tasa / pr.cod_periodicidad), pr.cod_periodicidad) - 1 AS tasa_efectiva
FROM
    obligaciones_clientes AS o
INNER JOIN info_clientes AS ic ON o.num_documento = ic.num_documento
INNER JOIN productos AS p ON o.id_nombre_producto = p.id_nombre_producto
INNER JOIN tasas t ON 
    p.id_nombre_producto = t.id_nombre_producto AND
    ic.calificacion_riesgo = t.calificacion_riesgo AND
    ic.cod_segmento = t.cod_segmento AND
    ic.cod_subsegmento = t.cod_subsegmento
INNER JOIN periodicidad AS pr
    ON (o.cod_periodicidad = pr.cod_periodicidad)
ORDER BY num_documento DESC;-- 1.3 Tomar la tasa efectiva, multiplicarla por el valor_inicial y dejar este resultado como valor_final, el resultado --     de esta tabla debe quedar almacenado.

-- Creación de una nueva tabla con la información de tasa efectiva. 
USE informacion_cartera;
CREATE TABLE resultados_TE (
    num_documento INT,
    nombre_producto VARCHAR(255),
    cod_segmento VARCHAR(50),
    calificacion_riesgo VARCHAR(50),
    valor_inicial DECIMAL(18, 2),
    saldo_deuda DECIMAL(18, 2),
    cod_periodicidad INT,
    periodicidad VARCHAR(50),
    valor_tasa DECIMAL(18, 6),
    tasa_efectiva DECIMAL(18, 6),
    valor_final DECIMAL(18, 2)
);

INSERT INTO resultados_TE
SELECT
    o.num_documento,
    p.nombre_producto,
    ic.cod_segmento,
    ic.calificacion_riesgo,
    o.valor_inicial,
    o.saldo_deuda,
    pr.cod_periodicidad,
    pr.periodicidad,
    t.valor_tasa,
    POWER(1 + (t.valor_tasa / pr.cod_periodicidad), pr.cod_periodicidad) - 1 AS tasa_efectiva,
    o.valor_inicial * (POWER((t.valor_tasa / pr.cod_periodicidad), pr.cod_periodicidad)) AS valor_final
FROM
    obligaciones_clientes AS o
INNER JOIN info_clientes AS ic ON o.num_documento = ic.num_documento
INNER JOIN productos AS p ON o.id_nombre_producto = p.id_nombre_producto
INNER JOIN tasas t ON 
    p.id_nombre_producto = t.id_nombre_producto AND
    ic.calificacion_riesgo = t.calificacion_riesgo AND
    ic.cod_segmento = t.cod_segmento AND
    ic.cod_subsegmento = t.cod_subsegmento
INNER JOIN periodicidad AS pr
    ON o.cod_periodicidad = pr.cod_periodicidad;

-- consultar el resultado
SELECT *FROM resultados_TE;-- 1.4 Se necesita sumar el valor_final de todas las obligaciones por cliente y dejar únicamente las que tenga una cantidad 
--     de productos mayor o igual a 2, el resultado de esta tabla debe quedar almacenado.-- Creación tabla total_obligaciones. USE informacion_cartera;

CREATE TABLE total_obligaciones (
    num_documento INT,
    total_valor_final DECIMAL(18, 2),
    num_productos INT
);-- Ingestar la data solicitada en la tabla WITH ResumenClientes AS (
    SELECT
        num_documento,
        SUM(valor_final) AS total_valor_final,
        COUNT(*) AS num_productos
    FROM
        resultados_TE
    GROUP BY
        num_documento
    HAVING
        COUNT(*) >= 2
)
INSERT INTO total_obligaciones (num_documento, total_valor_final, num_productos)
SELECT
    num_documento,
    total_valor_final,
    num_productos
FROM ResumenClientes;

-- Consulta con información del cliente y consolidado de productos.
SELECT 
	tt.num_documento,
	CONCAT(ic.nombre,' ', ic.primer_apellido,' ',ic.segundo_apellido) AS nombre_cliente,
	tt.num_productos,
	tt.total_valor_final
FROM total_obligaciones AS tt
INNER JOIN info_clientes AS ic
	ON (tt.num_documento = ic.num_documento);