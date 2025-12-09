CREATE OR REPLACE TABLE `{{ right_source.table }}_tmp` AS
SELECT
    *,
    ST_BUFFER(ST_GEOGFROMWKT({{ right_source.geometry }}), {{ options.distance }}) as buffer
FROM `{{ right_source.table }}`
{% if right_source.where is not none %}
WHERE {{ right_source.where }}
{% endif %};

CREATE OR REPLACE TABLE `{{ left_source.table }}_tmp` AS
SELECT
    *
FROM `{{ left_source.table }}`;

CREATE OR REPLACE TABLE `{{ target.table }}` AS
SELECT DISTINCT
    a.*
FROM `{{ left_source.table }}_tmp` AS a
JOIN `{{ right_source.table }}_tmp` AS b
ON ST_INTERSECTS(ST_GEOGFROMWKT(a.{{ left_source.geometry }}), b.buffer);

DROP TABLE `{{ left_source.table }}_tmp`;
DROP TABLE `{{ right_source.table }}_tmp`;
