CREATE OR REPLACE FUNCTION dba.sp_revoke_all_sequences (
  i_role_name VARCHAR,
  i_privilege VARCHAR = 'ALL',
  i_schema_name VARCHAR = 'public'
)
RETURNS void AS
$body$
DECLARE
  l_sql VARCHAR;
BEGIN
 
  FOR l_sql IN 
    SELECT 
        'REVOKE ' || i_privilege || ' ON ' || i_schema_name || '.'|| c.relname || ' FROM ' || i_role_name || ';' 
      FROM pg_class c 
      JOIN pg_namespace n ON n.oid = c.relnamespace
      WHERE 
        c.relkind = 'S' AND 
        n.nspname = i_schema_name 
    LOOP
      EXECUTE l_sql;
    END LOOP;

END;
$body$
LANGUAGE 'plpgsql';
