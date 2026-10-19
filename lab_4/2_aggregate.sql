-- Находит "центр масс" космодромов на планете (среднее по X и Y)
create or replace function centroid_step(state float8[], x float8, y float8)
returns  float8[]
language plpython3u
immutable strict
as $$
n, sx, sy = state
return [n + 1, sx + x, sy + y]
$$;

create or replace function centroid_final(state float8[])
returns float8[]
language plpython3u
immutable
as $$
n, sx, sy = state
return None if n == 0 else [round(sx / n, 2), round(sy / n, 2)]
$$;

create or replace aggregate centroid(float8, float8) (
    SFUNC     = centroid_step,
    STYPE     = float8[],
    FINALFUNC = centroid_final,
    INITCOND  = '{0,0,0}'
);

select p.name as planet, count(*) AS ports, centroid(s.coord_x::float8, s.coord_y::float8) as center
from spaceport s join planet p on s.planet_id = p.planet_id 
group by p.planet_id, p.name
order by ports desc
limit 10;