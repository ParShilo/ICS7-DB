-- Создание таблицы для логов
CREATE TABLE IF NOT EXISTS flight_log (
    log_id SERIAL PRIMARY KEY,
    arrival_id INT8,
    action_type VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Функция триггера
CREATE OR REPLACE FUNCTION log_flight_arrival_after()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO flight_log(arrival_id, action_type)
    VALUES (NEW.arrival_id, 'INSERT_AFTER');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Триггер AFTER INSERT
CREATE OR REPLACE TRIGGER trg_flight_arrival_after
AFTER INSERT ON flight_arrival
FOR EACH ROW
EXECUTE FUNCTION log_flight_arrival_after();

-- Проверка:
INSERT INTO flight_arrival (person_id, spaceship_id, spaceport_id, flight_number, arrival_datetime, seat_number, purpose_of_visit)
VALUES (1, 1, 1, 'FL-777', CURRENT_TIMESTAMP::timestamp, '01A', 'Туризм');
SELECT * FROM flight_log;




-- Представление
CREATE OR REPLACE VIEW v_spaceships_short AS
SELECT spaceship_id, name, model, capacity
FROM spaceship;

-- Функция триггера INSTEAD OF
CREATE OR REPLACE FUNCTION insert_instead_of_spaceship_view()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO spaceship (name, model, capacity, registration_number, max_speed)
    VALUES (NEW.name,  NEW.model, COALESCE(NEW.capacity, 0), 'REG-' || FLOOR(RANDOM() * 899999 + 100000)::TEXT, 1000.00);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Триггер INSTEAD OF INSERT
CREATE OR REPLACE TRIGGER trg_spaceship_instead_of
INSTEAD OF INSERT ON v_spaceships_short
FOR EACH ROW
EXECUTE FUNCTION insert_instead_of_spaceship_view();

-- Проверка:
INSERT INTO v_spaceships_short (name, model, capacity)
VALUES ('Millennium Falcon', 'Falcon', 100);
SELECT * FROM spaceship WHERE name = 'Millennium Falcon';

