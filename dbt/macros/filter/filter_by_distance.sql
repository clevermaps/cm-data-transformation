{% macro filter_by_distance(from, by, options) %}

WITH right_buffers AS (
    SELECT
        ST_Transform(
            ST_Buffer(
                ST_Transform({{ by.geometry }}, 'EPSG:4326', 'EPSG:3857'),
                {{ options.distance }}
            ),
            'EPSG:3857',
            'EPSG:4326'
        ) AS buffer
    FROM {{ by.table }}
    {% if by.where is defined %}
    WHERE {{ by.where }}
    {% endif %}
)

SELECT DISTINCT
    a.*
FROM {{ from.table }} AS a
JOIN right_buffers AS b
ON ST_Intersects(
    a.{{ from.geometry }},
    b.buffer
)

{% endmacro %}