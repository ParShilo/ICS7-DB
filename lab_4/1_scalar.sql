-- Рассчитывает расстояние между двумя скоплениями
create or replace function dist3 (
	x1 numeric, y1 numeric, z1 numeric,
	x2 numeric, y2 numeric, z2 numeric)
returns double precision
language plpython3u
immutable strict
as $$
import math
a = (float(x1), float(y1), float(z1))
b = (float(x2), float(y2), float(z2))
return math.dist(a, b)
$$;

select dist3(0, 0, 0, 3, 4, 0);


select c2.name, round(dist3(c1.coord_x, c1.coord_y, c1.coord_z, c2.coord_x, c2.coord_y, c2.coord_z)::numeric, 2) AS dist
from star_cluster c1 join star_cluster c2 on c2.cluster_id <> c1.cluster_id
where c1.cluster_id = 1
order by dist
limit 10;

/*
create or replace function fmt_person(full_name text, race text) 
returns text
language plpython3u
immutable strict
as $$
return f"{full_name}, [{race}]"
$$;

select fmt_person(full_name, race) from person limit 10;


create or replace function fmt_person(full_name text, race text) 
returns text
language plpython3u
as $$
full_name = "Иван"
return f"{full_name}, [{race}]"
$$;

select fmt_person(full_name, race) from person limit 10;

*/

/*
create or replace function age_at(birth_date date, at_moment timestamp)
returns int
language plpython3u
immutable strict
as $$
from datetime import date, datetime

b_date = date.fromisoformat(birth_date)
a_moment = datetime.fromisoformat(at_moment).date()

age = a_moment.year - b_date.year
return age
$$;


select p.full_name, p.birth_date, f.arrival_datetime, age_at(p.birth_date, f.arrival_datetime) AS age_at_arrival
from flight_arrival f
join person p on f.person_id = p.person_id
where age_at(p.birth_date, f.arrival_datetime) < 18
order by age_at_arrival;
*/

