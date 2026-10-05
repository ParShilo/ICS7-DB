CREATE TABLE star_cluster (
    cluster_id BIGINT GENERATED ALWAYS AS IDENTITY,
    name VARCHAR(100) NOT NULL,
    coord_x NUMERIC(10, 2) NOT NULL,
    coord_y NUMERIC(10, 2) NOT NULL,
    coord_z NUMERIC(10, 2) NOT NULL,
    cluster_type VARCHAR(50) NOT NULL,
    parent_cluster_id BIGINT
);

CREATE TABLE planet (
    planet_id BIGINT GENERATED ALWAYS AS IDENTITY,
    name VARCHAR(100) NOT NULL,
    radius NUMERIC(10, 2) NOT NULL,
    coord_x NUMERIC(10, 2) NOT NULL,
    coord_y NUMERIC(10, 2) NOT NULL,
    atmosphere_type VARCHAR(50) NOT NULL,
    cluster_id BIGINT NOT NULL
);

CREATE TABLE spaceport (
    spaceport_id BIGINT GENERATED ALWAYS AS IDENTITY,
    name VARCHAR(100) NOT NULL,
    coord_x NUMERIC(10, 2) NOT NULL,
    coord_y NUMERIC(10, 2) NOT NULL,
    ship_capacity INT NOT NULL,
    planet_id BIGINT NOT NULL
);

CREATE TABLE spaceship (
    spaceship_id BIGINT GENERATED ALWAYS AS IDENTITY,
    name VARCHAR(100) NOT NULL,
    registration_number VARCHAR(50) NOT NULL,
    capacity INT NOT NULL,
    model VARCHAR(50) NOT NULL,
    max_speed NUMERIC(8, 2) NOT NULL
);

CREATE TABLE person (
    person_id BIGINT GENERATED ALWAYS AS IDENTITY,
    full_name VARCHAR(150) NOT NULL,
    birth_date DATE NOT NULL,
    race VARCHAR(50) NOT NULL,
    passport_code VARCHAR(30) NOT NULL,
    home_planet VARCHAR(100) NOT NULL
);

CREATE TABLE flight_arrival (
    arrival_id BIGINT GENERATED ALWAYS AS IDENTITY,
    person_id BIGINT NOT NULL,
    spaceship_id BIGINT NOT NULL,
    spaceport_id BIGINT NOT NULL,
    flight_number VARCHAR(20) NOT NULL,
    arrival_datetime TIMESTAMP NOT NULL,
    seat_number VARCHAR(10) NOT NULL,
    purpose_of_visit VARCHAR(100) NOT NULL
);