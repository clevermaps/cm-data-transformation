CREATE OR REPLACE TABLE {{ to.table }} AS
SELECT
    a.*
FROM {{ from.table }} AS a
JOIN {{ with.table }} AS b
ON ST_Intersects(a.{{ from.options.geometry }}, b.{{ with.options.geometry }})
{% if func.options.where is defined %}
AND {{ func.options.where }}
{% endif %}