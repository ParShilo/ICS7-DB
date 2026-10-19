create type space_coord as (x numeric(10,2), y numeric(10,2), z numeric(10,2));

create or replace function make_space_coord(x numeric, y numeric, z numeric)
returns space_coord 
language plpython3u 
immutable strict 
as $$
LIMIT = 10**7
for name, v in (("x", x), ("y", y), ("z", z)):
    if abs(v) >= LIMIT:
        plpy.error(f"Координата {name} вне допустимого диапазона!")
return {"x": x, "y": y, "z": z}
$$;

create or replace function coord_label(c space_coord)
returns text 
language plpython3u 
immutable strict 
as $$
return f"⟨{c['x']}; {c['y']}; {c['z']}⟩"
$$;


select coord_label(make_space_coord(10.5, 20.1, -5.0));
select make_space_coord(99999999, 0, 0);