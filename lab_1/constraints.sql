ALTER TABLE star_cluster ADD CONSTRAINT pk_star_cluster PRIMARY KEY (cluster_id);
ALTER TABLE planet ADD CONSTRAINT pk_planet PRIMARY KEY (planet_id);
ALTER TABLE spaceport ADD CONSTRAINT pk_spaceport PRIMARY KEY (spaceport_id);
ALTER TABLE spaceship ADD CONSTRAINT pk_spaceship PRIMARY KEY (spaceship_id);
ALTER TABLE person ADD CONSTRAINT pk_person PRIMARY KEY (person_id);
ALTER TABLE flight_arrival ADD CONSTRAINT pk_flight_arrival PRIMARY KEY (arrival_id);

-- Рекурсивная связь скоплений
ALTER TABLE star_cluster 
    ADD CONSTRAINT fk_star_cluster_parent 
    FOREIGN KEY (parent_cluster_id) REFERENCES star_cluster(cluster_id) ON DELETE SET NULL;

-- Планета -> Скопление
ALTER TABLE planet 
    ADD CONSTRAINT fk_planet_cluster 
    FOREIGN KEY (cluster_id) REFERENCES star_cluster(cluster_id) ON DELETE CASCADE;

-- Космодром -> Планета
ALTER TABLE spaceport 
    ADD CONSTRAINT fk_spaceport_planet 
    FOREIGN KEY (planet_id) REFERENCES planet(planet_id) ON DELETE CASCADE;

-- Тернарная связь: Прилёт -> Человек, Корабль, Космодром
ALTER TABLE flight_arrival 
    ADD CONSTRAINT fk_arrival_person 
    FOREIGN KEY (person_id) REFERENCES person(person_id) ON DELETE CASCADE;

ALTER TABLE flight_arrival 
    ADD CONSTRAINT fk_arrival_spaceship 
    FOREIGN KEY (spaceship_id) REFERENCES spaceship(spaceship_id) ON DELETE CASCADE;

ALTER TABLE flight_arrival 
    ADD CONSTRAINT fk_arrival_spaceport 
    FOREIGN KEY (spaceport_id) REFERENCES spaceport(spaceport_id) ON DELETE CASCADE;

ALTER TABLE spaceship ADD CONSTRAINT uq_spaceship_reg_num UNIQUE (registration_number);
ALTER TABLE person ADD CONSTRAINT uq_person_passport UNIQUE (passport_code);

ALTER TABLE planet ADD CONSTRAINT chk_planet_radius CHECK (radius > 0);
ALTER TABLE spaceport ADD CONSTRAINT chk_spaceport_capacity CHECK (ship_capacity > 0);
ALTER TABLE spaceship ADD CONSTRAINT chk_spaceship_capacity CHECK (capacity > 0);
ALTER TABLE spaceship ADD CONSTRAINT chk_spaceship_speed CHECK (max_speed > 0);