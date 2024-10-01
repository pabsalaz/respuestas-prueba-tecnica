DROP TABLE IF EXISTS proceso.ruortega_transformar PURGE
;
CREATE TABLE proceso.ruortega_transformar STORED AS PARQUET AS
WITH 
fuente_tasas as (
    SELECT
        cod_segmento,
        segmento,
        cod_subsegmento,
        calificacion_riesgos,
        tasa_cartera,
        tasa_operacion_especifica,
        tasa_hipotecario,
        tasa_leasing,
        tasa_sufi,
        tasa_factoring,
        tasa_tarjeta
    FROM proceso.ruortega_tasas_prod
)
,
fuente_obligaciones AS (
    SELECT 
        t1.radicado,
        t1.num_documento,
        t1.cod_segm_tasa,
        t1.cod_subsegm_tasa,
        t1.cal_interna_tasa,
        t1.id_producto,
        t1.tipo_id_producto,
        t1.valor_inicial,
        t1.fecha_desembolso,
        t1.plazo,
        t1.cod_periodicidad,
        t1.periodicidad,
        t1.saldo_deuda,
        t1.modalidad,
        t1.tipo_plazo,
        (CASE 
        WHEN lower(id_producto) like '%tarjeta%' then 'tarjeta'
        WHEN (lower(t1.id_producto) like '%cartera%') and (lower(t1.id_producto) not like '%leasing cartera%') then 'cartera'
        WHEN lower(t1.id_producto) like '%hipotecario%' then 'hipotecario'
        WHEN lower(t1.id_producto) like '%leasing%' then 'leasing'
        WHEN lower(t1.id_producto) like '%operacion_especifica%' then 'operacion_especifica'
        WHEN lower(t1.id_producto) like '%factoring%' then 'factoring'
        WHEN lower(t1.id_producto) like '%sufi%' then 'sufi'
        else 'producto por definir'
        end) as producto
    FROM proceso.ruortega_oblig_cli t1   
)
,
define_tasa_producto as (
    SELECT 
        t1.radicado,
        t1.num_documento,
        t1.cod_segm_tasa,
        t1.cod_subsegm_tasa,
        t1.cal_interna_tasa,
        t1.id_producto,
        t1.tipo_id_producto,
        t1.valor_inicial,
        t1.fecha_desembolso,
        t1.plazo,
        t1.cod_periodicidad,
        t1.periodicidad,
        t1.saldo_deuda,
        t1.modalidad,
        t1.tipo_plazo,
        t1.producto,
        (CASE
        WHEN T1.producto='tarjeta' then t2.tasa_tarjeta
        WHEN T1.producto='cartera' then t2.tasa_cartera
        WHEN T1.producto='hipotecario' then t2.tasa_hipotecario
        WHEN T1.producto='leasing' then t2.tasa_leasing
        WHEN T1.producto='operacion_especifica' then t2.tasa_operacion_especifica
        WHEN T1.producto='factoring' then t2.tasa_factoring
        WHEN T1.producto='sufi' then t2.tasa_sufi
        else cast(null as double)
        end) as tasa_producto
    FROM fuente_obligaciones t1  
    LEFT JOIN fuente_tasas t2 on t1.cod_segm_tasa=t2.cod_segmento and cast(t1.cod_subsegm_tasa as string)=t2.cod_subsegmento and t1.cal_interna_tasa=t2.calificacion_riesgos
)
select * from define_tasa_producto
;

compute stats proceso.ruortega_transformar
;


DROP TABLE IF EXISTS proceso.ruortega_calcular_valor_final PURGE
;
CREATE TABLE proceso.ruortega_calcular_valor_final STORED AS PARQUET AS
WITH 
tasa_efectiva as (
    SELECT
        t1.radicado,
        t1.num_documento,
        t1.cod_segm_tasa,
        t1.cod_subsegm_tasa,
        t1.cal_interna_tasa,
        t1.id_producto,
        t1.tipo_id_producto,
        t1.valor_inicial,
        t1.fecha_desembolso,
        t1.plazo,
        t1.cod_periodicidad,
        t1.periodicidad,
        t1.saldo_deuda,
        t1.modalidad,
        t1.tipo_plazo,
        t1.producto,
        t1.tasa_producto,
        ROUND((POWER((1 + t1.tasa_producto), 1/t1.cod_periodicidad) - 1),2) AS tasa_efectiva   
    FROM proceso.ruortega_transformar t1
)
,
valor_final as (
    select 
        t1.radicado,
        t1.num_documento,
        t1.cod_segm_tasa,
        t1.cod_subsegm_tasa,
        t1.cal_interna_tasa,
        t1.id_producto,
        t1.tipo_id_producto,
        t1.valor_inicial,
        t1.fecha_desembolso,
        t1.plazo,
        t1.cod_periodicidad,
        t1.periodicidad,
        t1.saldo_deuda,
        t1.modalidad,
        t1.tipo_plazo,
        t1.producto,
        t1.tasa_producto,
        t1.tasa_efectiva,
        ROUND((t1.tasa_efectiva*t1.valor_inicial),2) as valor_final
    FROM tasa_efectiva t1
)
select
        radicado,
        num_documento,
        cod_segm_tasa,
        cod_subsegm_tasa,
        cal_interna_tasa,
        id_producto,
        tipo_id_producto,
        valor_inicial,
        fecha_desembolso,
        plazo,
        cod_periodicidad,
        periodicidad,
        saldo_deuda,
        modalidad,
        tipo_plazo,
        producto,
        tasa_producto,
        tasa_efectiva,
        valor_final
from valor_final
;
compute stats proceso.ruortega_calcular_valor_final
;

DROP TABLE IF EXISTS proceso.ruortega_valor_final_resumen PURGE
;
CREATE TABLE proceso.ruortega_valor_final_resumen STORED AS PARQUET AS
SELECT
    num_documento,
    COUNT(DISTINCT producto) as cantidad_producto,
    sum(valor_final) as valor_final_total
FROM proceso.ruortega_calcular_valor_final
Group by num_documento
having COUNT(DISTINCT producto) >= 2
;
compute stats proceso.ruortega_valor_final_resumen
;






