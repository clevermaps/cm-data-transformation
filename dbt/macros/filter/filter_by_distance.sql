WITH right_buffers AS (
    SELECT
        ST_Transform(
            ST_Buffer(
                ST_Transform({{ right_source.geometry }}, 'EPSG:4326', 'EPSG:3857'),
                {{ options.distance }}
            ),
            'EPSG:3857',
            'EPSG:4326'
        ) AS buffer
    FROM {{ right_source.table }}
    {% if right_source.where is defined %}
    WHERE {{ right_source.where }}
    {% endif %}
)

SELECT DISTINCT
    a.*
FROM {{ left_source.table }} AS a
JOIN right_buffers AS b
ON ST_Intersects(
    a.{{ left_source.geometry }},
    b.buffer
)