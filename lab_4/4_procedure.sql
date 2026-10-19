-- Переносит скопление под нового родителя
create or replace procedure move_cluster(p_cluster bigint, p_new_parent bigint)
language plpython3u
as $$
get_parent = plpy.prepare("""
	select parent_cluster_id 
	from star_cluster
	where cluster_id = $1""", 
	["bigint"])

if p_new_parent is not None:
    cur = p_new_parent
    while cur is not None:
        if cur == p_cluster:
            plpy.error(f"Ошибка: нельзя сделать скопление потомком самого себя (цикл)!")
        rows = plpy.execute(get_parent, [cur])
        if rows.nrows() == 0: 
        	break
        cur = rows[0]["parent_cluster_id"]

upd = plpy.prepare("""
	update star_cluster 
	set parent_cluster_id = $2 
	where cluster_id = $1""",
    ["bigint", "bigint"])
    
plpy.execute(upd, [p_cluster, p_new_parent])
plpy.notice(f"Скопление {p_cluster} успешно перенесено.")
$$;


select * from star_cluster where cluster_id = 2;


begin;
call move_cluster(2, 1);
select * from star_cluster where cluster_id = 2;
rollback;