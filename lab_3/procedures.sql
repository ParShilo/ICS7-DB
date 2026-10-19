--1 
CREATE OR REPLACE PROCEDURE add_flight_arrival(
    p_flight_number VARCHAR,
    p_person_id INT8,
    p_spaceship_id INT8,
    p_spaceport_id INT8,
    p_arrival_time TIMESTAMP,
    p_seat_number VARCHAR DEFAULT '1A',
    p_purpose_of_visit VARCHAR DEFAULT 'Туризм'
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM person WHERE person_id = p_person_id) THEN
        RAISE EXCEPTION 'Человек с ID % не найден в базе!', p_person_id;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM spaceship WHERE spaceship_id = p_spaceship_id) THEN
        RAISE EXCEPTION 'Корабль с ID % не найден в базе!', p_spaceship_id;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM spaceport WHERE spaceport_id = p_spaceport_id) THEN
        RAISE EXCEPTION 'Космодром с ID % не найден в базе!', p_spaceport_id;
    END IF;

    INSERT INTO flight_arrival (
        person_id, 
        spaceship_id, 
        spaceport_id, 
        flight_number, 
        arrival_datetime, 
        seat_number, 
        purpose_of_visit
    )
    VALUES (
        p_person_id, 
        p_spaceship_id, 
        p_spaceport_id, 
        p_flight_number, 
        p_arrival_time, 
        p_seat_number, 
        p_purpose_of_visit
    );
    
    RAISE NOTICE 'Прилёт рейса % успешно зарегистрирован для person_id %', p_flight_number, p_person_id;
END;
$$;
 

CALL add_flight_arrival('FL-101', 1, 1, 1, CURRENT_TIMESTAMP::timestamp, '12B', 'Деловая поездка');


-- на вход космопорт, процент прилётов с целью визита
CREATE OR REPLACE PROCEDURE get_tyrism(p_spaceport_id INT8)
LANGUAGE plpgsql
AS $$
DECLARE
    v_turism INT;
    all_flights INT;
    precent NUMERIC;
BEGIN
    select count(*) into v_turism
    from spaceport SP
    left join flight_arrival FA ON SP.spaceport_id = FA.spaceport_id
    where TRIM(purpose_of_visit) ILIKE TRIM('Туризм') AND SP.spaceport_id = p_spaceport_id;
    
    select count(*) into all_flights
    from spaceport SP
    left join flight_arrival FA ON SP.spaceport_id = FA.spaceport_id
    where SP.spaceport_id = p_spaceport_id;
    
    
    select v_turism / all_flights into precent;
    
    RAISE NOTICE 'Процент %', precent;
END;
$$;

call get_tyrism(362);

--2
CREATE OR REPLACE PROCEDURE print_cluster_tree(p_root_id INT8)
LANGUAGE plpgsql
AS $$
DECLARE
    v_cluster_record RECORD;
BEGIN
    FOR v_cluster_record IN
        WITH RECURSIVE ClusterTree AS (
            SELECT cluster_id, name, parent_cluster_id, 0 AS level
            FROM star_cluster
            WHERE cluster_id = p_root_id

            UNION ALL

            SELECT C.cluster_id, C.name, C.parent_cluster_id, CT.level + 1
            FROM star_cluster C
            JOIN ClusterTree CT ON C.parent_cluster_id = CT.cluster_id
        )
        SELECT cluster_id, name, level FROM ClusterTree ORDER BY level, cluster_id
    LOOP
        RAISE NOTICE 'Уровень %: Скопление ID = %, Название = %', 
            v_cluster_record.level, 
            v_cluster_record.cluster_id, 
            v_cluster_record.name;
    END LOOP;
END;
$$;

CALL print_cluster_tree(2);


--3
CREATE OR REPLACE PROCEDURE increase_spaceship_capacity(p_percent NUMERIC)
LANGUAGE plpgsql
AS $$
DECLARE
    cur_spaceship CURSOR FOR 
        SELECT spaceship_id, name, capacity 
        FROM spaceship 
        FOR UPDATE;
        
    v_ship RECORD;
    v_new_capacity INT;
BEGIN
    OPEN cur_spaceship;
    
    LOOP
        FETCH cur_spaceship INTO v_ship;
        EXIT WHEN NOT FOUND;
        
        v_new_capacity := ROUND(v_ship.capacity * (1 + p_percent / 100.0));
        
        UPDATE spaceship 
        SET capacity = v_new_capacity 
        WHERE CURRENT OF cur_spaceship;
        
        RAISE NOTICE 'Корабль % (ID %): вместимость изменена с % на %', 
            v_ship.name, v_ship.spaceship_id, v_ship.capacity, v_new_capacity;
    END LOOP;
    
    CLOSE cur_spaceship;
END;
$$;


CALL increase_spaceship_capacity(10.0);


/*
CREATE OR REPLACE PROCEDURE cancel_flight(p_flight_number VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Выполняем удаление по номеру рейса
    DELETE FROM flight_arrival
    WHERE flight_number = p_flight_number;

    -- Проверяем системную переменную FOUND
    -- Она автоматически становится TRUE, если DELETE затронул хотя бы одну строку
    IF FOUND THEN
        RAISE NOTICE 'Рейс % успешно отменен', p_flight_number;
    ELSE
        -- Если FOUND = FALSE, значит ни одна строка не была удалена
        RAISE NOTICE 'Рейс % не найден, отменять нечего', p_flight_number;
    END IF;
END;
$$;
*/

--4 
CREATE OR REPLACE PROCEDURE get_schema_metadata(p_schema_name VARCHAR DEFAULT 'public')
LANGUAGE plpgsql
AS $$
DECLARE
    v_table RECORD;
BEGIN
    RAISE NOTICE '=== Метаданные схемы: % ===', p_schema_name;
    
    FOR v_table IN 
        SELECT table_name, table_type 
        FROM information_schema.tables 
        WHERE table_schema = p_schema_name
        ORDER BY table_name
    LOOP
        RAISE NOTICE 'Таблица/Представление: % | Тип: %', 
            v_table.table_name, v_table.table_type;
    END LOOP;
END;
$$;


CALL get_schema_metadata('public');