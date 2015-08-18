CREATE OR REPLACE FUNCTION dba.sp_grant_all_sequences (
  i_role_name VARCHAR,
  i_privilege VARCHAR = 'SELECT, UPDATE',
  i_schema_name VARCHAR = 'public'
)
RETURNS void AS
$body$
DECLARE
  l_sql VARCHAR;
BEGIN
 
  l_sql = format('GRANT %s ON ALL SEQUENCES IN SCHEMA %s TO %s;', i_privilege, i_schema_name, i_role_name);
  EXECUTE l_sql;

END;
$body$
LANGUAGE 'plpgsql';
