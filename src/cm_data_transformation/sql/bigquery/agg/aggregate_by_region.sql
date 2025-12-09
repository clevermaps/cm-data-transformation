CREATE OR REPLACE TABLE `{{ target.table }}` AS
SELECT
    a.*,
    {{ options.agg }}
FROM `{{ left_source.table }}` AS a
LEFT JOIN 
(
    select
        *
    from `{{ right_source.table }}`
    {% if right_source.where is not none %}
    WHERE {{ right_source.where }}
    {% endif %}
) AS b
ON ST_INTERSECTS(ST_GEOGFROMWKT(a.{{ left_source.geometry }}), ST_GEOGFROMWKT(b.{{ right_source.geometry }}))
GROUP BY a.*;
