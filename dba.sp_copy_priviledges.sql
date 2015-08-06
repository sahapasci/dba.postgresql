CREATE OR REPLACE FUNCTION dba.sp_copy_priviledges (
  i_from_schema varchar,
  i_from_table varchar,
  i_to_schema varchar,
  i_to_table varchar,
  i_revoke_previous boolean = true
)
RETURNS void AS
$body$
DECLARE
  l_sql VARCHAR;
BEGIN
  IF i_revoke_previous THEN
    FOR l_sql IN 
      SELECT 
          'REVOKE ' || string_agg(tg.privilege_type, ', ') || ' ON ' || tg.table_schema || '.'|| tg.table_name || ' FROM ' || tg.grantee || ';' 
        FROM information_schema.role_table_grants tg
        WHERE 
          tg.table_schema = i_to_schema AND
          tg.table_name = i_to_table
        GROUP BY tg.grantee, tg.table_schema, tg.table_name
      LOOP
        EXECUTE l_sql;
      END LOOP;  
  END IF;

  FOR l_sql IN 
    SELECT 
        'GRANT ' || string_agg(tg.privilege_type, ', ') || ' ON ' || tg.table_schema || '.'|| tg.table_name || ' TO ' || tg.grantee || ';' 
      FROM information_schema.role_table_grants tg
      WHERE 
        tg.table_schema = i_from_schema AND
        tg.table_name = i_from_table
      GROUP BY tg.grantee, tg.table_schema, tg.table_name
    LOOP
      EXECUTE l_sql;
    END LOOP;
    
  SELECT 
      'ALTER TABLE ' || i_from_schema || '.' || i_from_table || ' OWNER TO '|| t.tableowner || ';'
    INTO
      l_sql
    FROM pg_tables t
    WHERE t.schemaname = i_from_schema AND
          t.tablename = i_from_table;    
  EXECUTE l_sql;
    
END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;