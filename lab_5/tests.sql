-- Планета целиком в json
select to_jsonb(p) as palnet_json
from planet p
limit 3;

-- Атрибуты планеты в json
select jsonb_build_object(
	'id', p.planet_id,
	'title', p.name,
	'atmosphere', p.atmosphere_type
) as palnet_json
from planet p
limit 3;

-- Все планеты в один json
select jsonb_agg(to_jsonb(planet) order by planet.planet_id) as all_planets
from planet;

--
/*
select *
from (
(select jsonb_agg(to_jsonb(p) order by p.planet_id) as all
from planet p)
union all
(select jsonb_agg(to_jsonb(sp) order by sp.spaceport_id) as all
from spaceport sp)
union all
(select jsonb_agg(to_jsonb(per) order by per.spaceport_id) as all
from person per)

) as all;
*/

--
select jsonb_pretty(jsonb_agg(
	json_build_object(
		'planet', p.name,
		'atmosphere', p.atmosphere_type,
		'spaceports', (
			select coalesce(jsonb_agg(json_build_object(
				'port_name', sp.name,
				'capacity', sp.ship_capacity)
			order by sp.name), '[]'::jsonb)
			from spaceport sp 
			where sp.planet_id = p.planet_id)
	) order by p.name 
)) as galaxy_doc
from planet p;

-- 2
create table if not exists json_import (
    id         bigint generated always as identity primary key,
    file_name  text        not null,
    loaded_at  timestamptz not null default now(),
    doc        jsonb       not null
);

create table if not exists planet_copy (like planet including all);
insert into planet_copy overriding system value
select * from jsonb_populate_recordset(null::planet, (select doc from json_import where file_name = 'planet.json' order by id desc limit 1));

(select * from planet except select * from planet_copy)
union all
(select * from planet_copy except select * from planet);

drop table planet_copy;

-- 3
drop table if exists space_probe;
create table space_probe (
    probe_id     bigint generated always as identity primary key,
    name         text   not null,
    target_body  text   not null,
    launch_year  int    not null,
    specs        jsonb  not null,
    constraint chk_specs_is_object check (jsonb_typeof(specs) = 'object')
);

-- Вставка
insert into space_probe (name, target_body, launch_year, specs)
values (
    'Вояджер-7',
    'Юпитер',
    2024,
    '{
        "status": "active",
        "autonomous": true,
        "power_source": {"type": "РИТЭГ", "output_w": 450},
        "telemetry": {"signal_db": -92.4, "frequency_ghz": 8.4},
        "instruments": [
            {"name": "спектрометр", "mass_kg": 14.5, "active": true},
            {"name": "магнитометр", "mass_kg": 5.2, "active": true},
            {"name": "камера высокого разрешения", "mass_kg": 22.0, "active": false}
        ]
    }'::jsonb
);

insert into space_probe (name, target_body, launch_year, specs)
values (
    'Кеплер-X',
    'Марс',
    2025,
    '{
        "status": "orbiting",
        "autonomous": false,
        "power_source": {"type": "солнечные панели", "efficiency_pct": 32.5},
        "instruments": [
            {"name": "радар подповерхностного зондирования", "mass_kg": 35.0, "active": true},
            {"name": "газоанализатор", "mass_kg": 8.1, "active": true}
        ]
    }'::jsonb
);

insert into space_probe (name, target_body, launch_year, specs)
values (
    'Горизонт-3',
    'Титан',
    2026,
    '{
        "status": "en_route",
        "autonomous": true,
        "power_source": {"type": "термоядерный микрореактор", "output_w": 1200},
        "telemetry": {"signal_db": -110.8, "frequency_ghz": 32.0},
        "instruments": [
            {"name": "атмосферный посадочный зонд", "mass_kg": 80.0, "active": false}
        ],
        "shields": {"radiation": "lead-composite"}
    }'::jsonb
);

-- Изменение
update space_probe
set specs = jsonb_set(specs, '{power_source,output_w}', '475'::jsonb)
where name = 'Вояджер-7';

update space_probe
set specs = specs || '{"last_calibration": "2026-10-15", "certified": true}'::jsonb
where name = 'Кеплер-X';

update space_probe
set specs = jsonb_insert(
    specs, 
    '{instruments, -1}', 
    '{"name": "криогенный термодатчик", "mass_kg": 1.2, "active": true}'::jsonb, 
    true
)
where name = 'Горизонт-3';

select probe_id, name, jsonb_pretty(specs) 
from space_probe;



-- 4 
-- извлечение json фрагмента
select 
    name,
    specs -> 'power_source'           as power_source_json,
    specs -> 'instruments'            as instruments_array,
    specs -> 'instruments' -> 0       as first_instrument,
    specs #> '{power_source,type}'    as power_type_json
from space_probe;

-- извлечение скалярных значений
select 
    name,
    specs ->> 'status'                                     as status,
    (specs ->> 'autonomous')::boolean                      as is_autonomous,
    specs #>> '{power_source,type}'                        as power_type,
    (specs #>> '{power_source,output_w}')::int             as power_output_w,
    (specs #>> '{telemetry,signal_db}')::numeric           as signal_strength
from space_probe
where (specs #>> '{power_source,output_w}')::int > 400;

-- проверка существования
select name, specs ? 'telemetry' as has_telemetry
from space_probe;

select 
    name,
    specs ?| array['shields', 'telemetry'] as has_shields_or_telemetry,
    specs ?& array['status', 'power_source'] as has_required_keys
from space_probe;

select * 
from space_probe 
where specs @> '{"status": "active"}';


-- изменение json документа
begin;
update space_probe
set specs = jsonb_set(specs, '{power_source,output_w}', '500'::jsonb)
where name = 'Вояджер-7';
select probe_id, name, jsonb_pretty(specs) 
from space_probe
where name = 'Вояджер-7';
rollback;


begin;
update space_probe
set specs = specs - 'last_calibration'
where name = 'Кеплер-X';
select probe_id, name, jsonb_pretty(specs) 
from space_probe
where name = 'Кеплер-X';
rollback;

begin;
update space_probe
set specs = specs || '{"in_service": true, "revision": 2}'::jsonb
where name = 'Горизонт-3';
select probe_id, name, jsonb_pretty(specs) 
from space_probe
where name = 'Горизонт-3';
rollback;

begin;
update space_probe
set specs = jsonb_insert(
    specs, 
    '{instruments, 0}', 
    '{"name": "гамма-спектрометр", "mass_kg": 4.5, "active": true}'::jsonb
)
where name = 'Кеплер-X';
select probe_id, name, jsonb_pretty(specs) 
from space_probe
where name = 'Кеплер-X';
rollback;


-- разделение json
select 
    sp.name,
    p.key   as param_name,
    p.value as param_value
from space_probe sp
cross join jsonb_each(sp.specs -> 'power_source') as p;
