-- 1
CREATE OR REPLACE FUNCTION get_person_age(p_person_id INT8)
RETURNS INT AS $$
DECLARE
    v_birth_date DATE;
    v_age INT;
BEGIN
    SELECT birth_date INTO v_birth_date
    FROM person
    WHERE person_id = p_person_id;

    IF v_birth_date IS NULL THEN
        RETURN NULL;
    END IF;

    v_age := EXTRACT(YEAR FROM AGE(CURRENT_DATE, v_birth_date));
    RETURN v_age;
END;
$$ LANGUAGE plpgsql;


SELECT get_person_age(1) AS person_age;


-- 2
CREATE OR REPLACE FUNCTION get_spaceships_by_model(p_model VARCHAR)
RETURNS TABLE (
    ship_id INT8,
    ship_name VARCHAR,
    ship_capacity INT,
    ship_max_speed NUMERIC
) AS $$
    SELECT 
        spaceship_id, 
        name, 
        capacity, 
        max_speed
    FROM spaceship
    WHERE TRIM(model) ILIKE TRIM(p_model);
$$ LANGUAGE sql;


SELECT * 
FROM get_spaceships_by_model('Разведчик')
ORDER BY ship_capacity DESC;

--3
CREATE OR REPLACE FUNCTION get_spaceport_stats()
RETURNS TABLE (
    port_id INT8,
    port_name VARCHAR,
    total_arrivals INT8,
    unique_spaceships INT8
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        SP.spaceport_id,
        SP.name,
        COUNT(FA.arrival_id) AS total_arrivals,
        COUNT(DISTINCT FA.spaceship_id) AS unique_spaceships
    FROM spaceport SP
    LEFT JOIN flight_arrival FA ON SP.spaceport_id = FA.spaceport_id
    GROUP BY SP.spaceport_id, SP.name
    ORDER BY total_arrivals DESC;
END;
$$ LANGUAGE plpgsql;


SELECT * 
FROM get_spaceport_stats();


--4
CREATE OR REPLACE FUNCTION get_subclusters_hierarchy(p_root_cluster_id INT8)
RETURNS TABLE (
    cluster_id INT8,
    cluster_name VARCHAR,
    parent_id INT8,
    tree_level INT
) AS $$
BEGIN
    RETURN QUERY
    WITH RECURSIVE SubClusters AS (
        SELECT 
            SC.cluster_id, 
            SC.name, 
            SC.parent_cluster_id, 
            0 AS level
        FROM star_cluster SC
        WHERE SC.cluster_id = p_root_cluster_id

        UNION ALL

        SELECT 
            C.cluster_id, 
            C.name, 
            C.parent_cluster_id, 
            CH.level + 1
        FROM star_cluster C
        JOIN SubClusters CH ON C.parent_cluster_id = CH.cluster_id
    )
    SELECT 
        S.cluster_id, 
        S.name, 
        S.parent_cluster_id, 
        S.level
    FROM SubClusters S;
END;
$$ LANGUAGE plpgsql;


SELECT * 
FROM get_subclusters_hierarchy(2);

