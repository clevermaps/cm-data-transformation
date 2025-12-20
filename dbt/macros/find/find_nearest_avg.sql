
{% macro find_nearest_avg(from, to, options) %}


WITH pairs AS (
    SELECT
        a.*,
        b.{{ to.id }} AS pair_id,
        ST_Distance(
            ST_Transform(a.{{ from.geometry }}, 'EPSG:4326', 'EPSG:3857'),
            ST_Transform(b.{{ to.geometry }}, 'EPSG:4326', 'EPSG:3857')
        ) AS pair_distance
    FROM {{ from.table }} AS a
    LEFT JOIN {{ to.table }} AS b
    ON (
        ST_Intersects(
            ST_Transform(
                ST_Buffer(
                    ST_Transform(a.{{ from.geometry }}, 'EPSG:4326', 'EPSG:3857'),
                    {{ options.max_distance }}
                ),
                'EPSG:3857',
                'EPSG:4326'
            ),
            b.{{ to.geometry }}
        )
    )
    {% if to.where is defined %}
        AND {{ to.where }}
    {% endif %}
)
SELECT
    a.*,
    avg(pair_distance) as avg_distance
from {{ from.table }} AS a
left join (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY {{ from.id }}
            ORDER BY pair_distance
        ) AS rn
    FROM pairs
) ranked
on a.{{ from.id }} = ranked.{{ from.id }}
and rn <= {{ options.max_neighbours }}
GROUP BY
    a.*
{% endmacro %}
