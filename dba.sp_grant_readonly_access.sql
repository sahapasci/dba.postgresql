CREATE OR REPLACE FUNCTION dba.sp_grant_readonly_access (
  i_role text,
  i_password text,
  i_database_name text = 'current'::text,
  i_schema_name text = 'public'::text,
  out sql text
)
RETURNS SETOF text AS
$body$
DECLARE 
  database_name TEXT;
BEGIN
  IF i_database_name = 'current' THEN
    database_name = current_database();
  ELSE
    database_name = i_database_name;
  END IF;

  sql = '-- Create role';
  RETURN NEXT;
  
  sql = 'CREATE ROLE ' || i_role || ' LOGIN PASSWORD ''' || i_password || ''';';
  RETURN NEXT;

  sql = '-- Existing objects';
  RETURN NEXT;
  
  sql = 'GRANT CONNECT ON DATABASE ' || database_name || ' TO ' || i_role || ';';
  RETURN NEXT;
  
  sql = 'GRANT USAGE ON SCHEMA ' || i_schema_name || ' TO ' || i_role || ';';
  RETURN NEXT;
  
  sql = 'GRANT SELECT ON ALL TABLES IN SCHEMA ' || i_schema_name || ' TO ' || i_role || ';';
  RETURN NEXT;

  sql = 'GRANT SELECT ON ALL SEQUENCES IN SCHEMA ' || i_schema_name || ' TO ' || i_role || ';';
  RETURN NEXT;
  
  sql = 'GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA ' || i_schema_name || ' TO ' || i_role || ';';
  RETURN NEXT;

  sql = '-- New objects';
  RETURN NEXT;

  sql = 'ALTER DEFAULT PRIVILEGES IN SCHEMA ' || i_schema_name || ' GRANT SELECT ON TABLES TO ' || i_role || ';';
  RETURN NEXT;

  sql = 'ALTER DEFAULT PRIVILEGES IN SCHEMA ' || i_schema_name || ' GRANT SELECT ON SEQUENCES TO ' || i_role || ';';
  RETURN NEXT;
  
  sql = 'ALTER DEFAULT PRIVILEGES IN SCHEMA ' || i_schema_name || ' GRANT EXECUTE ON FUNCTIONS TO ' || i_role || ';';
  RETURN NEXT;

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100 ROWS 1000;