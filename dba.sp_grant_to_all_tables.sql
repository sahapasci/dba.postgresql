CREATE OR REPLACE FUNCTION dba.sp_grant_to_all_tables (
  i_role_name VARCHAR,
  i_privilege VARCHAR = 'SELECT, INSERT, UPDATE, DELETE',
  i_schema_name VARCHAR = 'public'
)
RETURNS void AS
$body$
DECLARE
  l_sql VARCHAR;
  l_schemas VARCHAR[];
BEGIN

  l_schemas = string_to_array(i_schema_name, ',');
  FOR l_sql IN 
    SELECT 
        'GRANT ' || i_privilege || ' ON ' || t.schemaname || '.'|| t.tablename || ' TO ' || i_role_name || ';' 
      FROM pg_tables t 
      WHERE 
        t.schemaname = ANY (l_schemas)
    LOOP
      EXECUTE l_sql;
    END LOOP;

END;
$body$
LANGUAGE 'plpgsql';
