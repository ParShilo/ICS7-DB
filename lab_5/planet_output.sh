#!/bin/bash
docker compose exec -T postgres_db psql -U postgres -d space_db -At -c "SELECT jsonb_pretty(jsonb_agg(to_jsonb(p) ORDER BY planet_id)) FROM planet p;" > planet.json
docker compose exec -T postgres_db psql -U postgres -d space_db -At -c "select jsonb_pretty(jsonb_agg(to_jsonb(f) order by arrival_datetime)) from flight_arrival f;" > lab_5/flight_arrival.json
