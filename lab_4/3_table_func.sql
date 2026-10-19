-- Возвращает таблицу (набор строк). Выведем историю путешествий человека с расчетом времени между прилётами.
create or replace function person_travels(p_person_id bigint)
returns table (
    arrival_datetime timestamp,
    flight_number    text,
    ship             text,
    hours_since_prev double precision
)
language plpython3u
stable strict 
as $$
from datetime import datetime

plan = plpy.prepare("""
    select f.arrival_datetime, f.flight_number, sh.name as ship
    from flight_arrival f
    join spaceship sh on sh.spaceship_id = f.spaceship_id
    where f.person_id = $1
    order by f.arrival_datetime
""", ["bigint"])

prev = None
for r in plpy.execute(plan, [p_person_id]):
    t = datetime.fromisoformat(r["arrival_datetime"])
    gap = None if prev is None else (t - prev).total_seconds() / 3600
    prev = t
    yield {
        "arrival_datetime": r["arrival_datetime"],
        "flight_number": r["flight_number"],
        "ship": r["ship"],
        "hours_since_prev": gap
    }
$$;

-- Проверка:
SELECT * FROM person_travels(1);