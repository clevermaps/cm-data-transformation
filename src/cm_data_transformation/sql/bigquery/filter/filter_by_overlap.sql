CREATE OR REPLACE TABLE `{{ target.table }}` AS
SELECT
    a.*
FROM `{{ left_source.table }}` AS a
JOIN `{{ right_source.table }}` AS b
ON ST_INTERSECTS(ST_GEOGFROMWKT(a.{{ left_source.geometry }}), ST_GEOGFROMWKT(b.{{ right_source.geometry }}))
{% if right_source.where is not none %}
AND {{ right_source.where }}
{% endif %};
