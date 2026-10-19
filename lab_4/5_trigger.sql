create or replace function trg_flight_capacity()
returns trigger language plpython3u as $$
if "cap" not in SD:
    SD["cap"] = plpy.prepare("select capacity from spaceship where spaceship_id = $1", ["bigint"])
    SD["seats"] = plpy.prepare("""
        select count(*) as cnt 
        from flight_arrival
        where spaceship_id = $1 and flight_number = $2 and arrival_datetime = $3""", 
        ["bigint", "text", "timestamp"])

new = TD["new"]
cap = plpy.execute(SD["cap"], [new["spaceship_id"]])[0]["capacity"]
seats_taken = plpy.execute(SD["seats"], [new["spaceship_id"], new["flight_number"], new["arrival_datetime"]])[0]["cnt"]

if seats_taken + 1 > cap:
    plpy.error(f"Рейс {new['flight_number']} переполнен! Мест: {cap}, занято: {seats_taken}")
return None
$$;

create trigger flight_capacity
before insert or update on flight_arrival
for each row execute function trg_flight_capacity();



begin;
insert into flight_arrival (person_id, spaceship_id, spaceport_id, flight_number, arrival_datetime, seat_number, purpose_of_visit)
values (
    1,  
    429,  -- spaceship_id
    1,  -- spaceport_id
    'TEST-TRIGGER-01',
    '2200-01-01 10:00:00',
    '1A',
    'тест триггера'
);

select * from flight_arrival where flight_number = 'TEST-TRIGGER-01';
rollback;




begin;
insert into flight_arrival (person_id, spaceship_id, spaceport_id, flight_number, arrival_datetime, seat_number, purpose_of_visit)
values (
    1,  
    429,  -- spaceship_id
    1,  -- spaceport_id
    'TEST-TRIGGER-01',
    '2200-01-01 10:00:00',
    '1A',
    'тест триггера'
);

insert into flight_arrival (person_id, spaceship_id, spaceport_id, flight_number, arrival_datetime, seat_number, purpose_of_visit)
values (
    2,  
    429,  -- spaceship_id
    1,  -- spaceport_id
    'TEST-TRIGGER-01',
    '2200-01-01 10:00:00',
    '2A',
    'тест триггера'
);

insert into flight_arrival (person_id, spaceship_id, spaceport_id, flight_number, arrival_datetime, seat_number, purpose_of_visit)
values (
    3,  
    429,  -- spaceship_id
    1,  -- spaceport_id
    'TEST-TRIGGER-01',
    '2200-01-01 10:00:00',
    '3A',
    'тест триггера'
);

select * from flight_arrival where flight_number = 'TEST-TRIGGER-01';
rollback;



