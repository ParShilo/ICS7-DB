--1 (Поиск планет с несколькими космодромами)
SELECT S1.planet_id, S1.name AS spaceport_name
FROM spaceport S1 
JOIN spaceport S2 ON S1.planet_id = S2.planet_id
WHERE S1.spaceport_id <> S2.spaceport_id
ORDER BY S1.planet_id, S1.name;


--2 (Фильтрация людей по дате рождения)
SELECT person_id, full_name, birth_date
FROM person
WHERE birth_date BETWEEN '1990-01-01' AND '2000-12-31'
ORDER BY birth_date;


--3 (Поиск людей по шаблону имени)
SELECT person_id, full_name, race
FROM person
WHERE full_name LIKE '%Иван%' OR full_name LIKE '%Ivan%';


--4 (Выборка прилётов жителей Тавды с использованием IN и вложенного подзапроса)
SELECT arrival_id, flight_number, arrival_datetime, person_id
FROM flight_arrival
WHERE person_id IN (
    SELECT person_id 
    FROM person 
    WHERE home_planet = 'Планета с. Тавда'
);


--5 (Поиск космодромов без единого прилёта)
SELECT spaceport_id, name
FROM spaceport S
WHERE NOT EXISTS (
    SELECT *
    FROM flight_arrival FA 
    WHERE FA.spaceport_id = S.spaceport_id
);


--6 (Поиск кораблей с вместимостью больше, чем у ВСЕХ кораблей 'Falcon')
SELECT spaceship_id, name, model, capacity
FROM spaceship
WHERE capacity > ALL (
    SELECT capacity 
    FROM spaceship 
    WHERE model = 'Falcon'
);


--7 (Расчёт среднего значения агрегированной вместимости)
SELECT AVG(total_capacity) AS actual_avg
FROM (
    SELECT spaceport_id, SUM(ship_capacity) AS total_capacity
    FROM spaceport
    GROUP BY spaceport_id
) AS spaceport_totals;


--8 (Расчёт средней и минимальной вместимости модели)
SELECT 
    S.spaceship_id, 
    S.name, 
    S.model, 
    S.capacity,
    (SELECT AVG(capacity) FROM spaceship WHERE model = S.model) AS avg_model_capacity,
    (SELECT MIN(capacity) FROM spaceship WHERE model = S.model) AS min_model_capacity
FROM spaceship S;


--9 (Классификация типов атмосферы планет)
SELECT name, atmosphere_type,
    CASE atmosphere_type
        WHEN 'Кислородная' THEN 'Пригодна для дыхания'
        WHEN 'Азотная' THEN 'Нужен дыхательный аппарат'
        ELSE 'Требуется скафандр высшей защиты'
    END AS habitability_status
FROM planet;


--10 (Категоризация кораблей по скоростным диапазонам)
SELECT name, max_speed,
    CASE 
        WHEN max_speed < 1000 THEN 'Дозвуковой / Медленный'
        WHEN max_speed BETWEEN 1000 AND 5000 THEN 'Стандартный класс'
        WHEN max_speed > 5000 THEN 'Гиперсветовой'
        ELSE 'Неизвестно'
    END AS speed_category
FROM spaceship;


DROP TABLE IF EXISTS temp_planet_capacity;

--11 (Создание и заполнение временной таблицы суммарной вместимости по планетам)
SELECT planet_id, SUM(ship_capacity) AS total_capacity, COUNT(spaceport_id) AS ports_count
INTO TEMP TABLE temp_planet_capacity
FROM spaceport
GROUP BY planet_id;

--12 (Объединение лучших кораблей по вместимости и скорости)
SELECT 'By capacity' AS criteria, name AS best_spaceship
FROM spaceship S 
JOIN (
    SELECT spaceship_id
    FROM spaceship
    ORDER BY capacity DESC
    LIMIT 1
) AS C ON C.spaceship_id = S.spaceship_id

UNION

SELECT 'By speed' AS criteria, name AS best_spaceship
FROM spaceship S 
JOIN (
    SELECT spaceship_id
    FROM spaceship
    ORDER BY max_speed DESC
    LIMIT 1
) AS M ON M.spaceship_id = S.spaceship_id;


--13 (Поиск человека с максимальным числом прилётов)
SELECT full_name
FROM person
WHERE person_id = (
    SELECT person_id
    FROM flight_arrival
    GROUP BY person_id
    HAVING COUNT(arrival_id) = (
        SELECT MAX(flight_cnt)
        FROM (
            SELECT COUNT(arrival_id) AS flight_cnt
            FROM flight_arrival
            GROUP BY person_id
        ) AS max_flights
    )
);


--14 (Подсчёт числа полетов для кораблей 'Разведчик')
SELECT S.spaceship_id, S.name, COUNT(FA.arrival_id) AS flight_count
FROM spaceship S 
LEFT JOIN flight_arrival FA ON S.spaceship_id = FA.spaceship_id
WHERE S.model = 'Разведчик'
GROUP BY S.spaceship_id, S.name;


--15 (Поиск моделей кораблей со средней скоростью выше общей средней)
SELECT model, AVG(max_speed) AS avg_model_speed
FROM spaceship
GROUP BY model
HAVING AVG(max_speed) > (
    SELECT AVG(max_speed) 
    FROM spaceship
);


--16 (Вставка одной новой строки в таблицу spaceship)
INSERT INTO spaceship (name, registration_number, capacity, model, max_speed)
VALUES ('Восток-1', 'REG-0001-999', 1, 'Исследовательский', 11000.00);


--17 (Многострочная вставка технических прилётов для космодромов Земли из подзапроса)
INSERT INTO flight_arrival (person_id, spaceship_id, spaceport_id, flight_number, arrival_datetime, seat_number, purpose_of_visit)
SELECT 
    (SELECT MAX(person_id) FROM person), 
    (SELECT MAX(spaceship_id) FROM spaceship), 
    spaceport_id, 
    'TECH-01', 
    NOW(), 
    'A1', 
    'Технический осмотр'
FROM spaceport
WHERE planet_id IN (SELECT planet_id FROM planet WHERE name = 'Земля');


--18 (Увеличение вместимости всех кораблей 'Falcon' на 10%)
UPDATE spaceship
SET capacity = capacity * 1.1
WHERE model = 'Разведчик';


--19 (Обновление вместимости космодрома средним значением)
UPDATE spaceport
SET ship_capacity = (SELECT AVG(ship_capacity) FROM spaceport)
WHERE spaceport_id = 1;


--20 (Удаление записей прилётов с пустой целью визита)
DELETE FROM flight_arrival
WHERE purpose_of_visit = '';


--21 (Удаление пассажиров без единого прилёта)
DELETE FROM person
WHERE person_id IN (
    SELECT P.person_id
    FROM person P 
    LEFT JOIN flight_arrival FA ON P.person_id = FA.person_id
    WHERE FA.arrival_id IS NULL
);


--22 (Расчёт среднего числа полетов на человека)
WITH PersonFlights (person_id, total_flights) AS (
    SELECT person_id, COUNT(*)
    FROM flight_arrival
    GROUP BY person_id
)
SELECT AVG(total_flights) AS avg_flights_per_person
FROM PersonFlights;


--23 (Рекурсивный обход иерархии звёздных скоплений с уровнем вложенности)
WITH RECURSIVE ClusterHierarchy AS (
    SELECT cluster_id, name, parent_cluster_id, 0 AS level
    FROM star_cluster
    WHERE parent_cluster_id IS NULL

    UNION ALL

    SELECT C.cluster_id, C.name, C.parent_cluster_id, CH.level + 1
    FROM star_cluster C
    JOIN ClusterHierarchy CH ON C.parent_cluster_id = CH.cluster_id
)
SELECT cluster_id, name, parent_cluster_id, level
FROM ClusterHierarchy;


--24 (Расчёт статистик скорости по моделям кораблей)
SELECT 
    S.spaceship_id, 
    S.name, 
    S.model, 
    S.max_speed,
    AVG(S.max_speed) OVER(PARTITION BY S.model) AS avg_model_speed,
    MIN(S.max_speed) OVER(PARTITION BY S.model) AS min_model_speed,
    MAX(S.max_speed) OVER(PARTITION BY S.model) AS max_model_speed
FROM spaceship S;

--25 (Устранение искусственно созданных дубликатов строк)
WITH DuplicatedArrivals AS (
    SELECT 
        FA.*,
        ROW_NUMBER() OVER(
            PARTITION BY FA.person_id, FA.spaceship_id, FA.flight_number, FA.arrival_datetime
            ORDER BY FA.arrival_id
        ) AS row_num
    FROM flight_arrival FA
    JOIN flight_arrival FA_DUPE ON FA.flight_number = FA_DUPE.flight_number
)
SELECT arrival_id, person_id, spaceship_id, flight_number, arrival_datetime
FROM DuplicatedArrivals
WHERE row_num = 1;