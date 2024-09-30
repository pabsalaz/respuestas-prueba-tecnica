-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- Equipo Vicepresidencia de Gestión Humana
-----------------------------------------------------------------------------
-- Fecha Creación: 20240927
-- Última Fecha Modificación: 20240927
-- Autores: juavila
-- Últimos Autores: juavila
-- Descripción: Este código SQL crea una tabla llamada proceso.prueba_obligaciones_resumen_clientes, que resume el número de productos y 
-- el valor total de las obligaciones financieras por cliente.

DROP TABLE IF EXISTS proceso.prueba_obligaciones_resumen_clientes;

CREATE TABLE proceso.prueba_obligaciones_resumen_clientes AS
SELECT 
    num_documento,
    COUNT(DISTINCT id_producto) AS cantidad_productos,
    SUM(valor_final) AS total_valor_final
FROM proceso.prueba_obligaciones_con_valor_final
GROUP BY num_documento
HAVING COUNT(DISTINCT id_producto) >= 2;



--------------------------------- Query End ---------------------------------