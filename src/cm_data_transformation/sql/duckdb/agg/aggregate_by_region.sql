CREATE OR REPLACE TABLE {{ to.table }} AS
SELECT
    a.*,
    {{ func.options.agg }}
FROM {{ from.table }} AS a
LEFT JOIN {{ with.table }} AS b
ON ST_Intersects(a.{{ from.options.geometry }}, b.{{ with.options.geometry }})
GROUP BY a.*
