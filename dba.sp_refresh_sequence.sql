CREATE OR REPLACE FUNCTION dba.sp_refresh_sequence (
  i_sequence_name VARCHAR,
  i_table_name VARCHAR,
  i_table_field VARCHAR = 'id'
)
RETURNS void AS
$body$
DECLARE
  l_new_value INTEGER;
  l_sql VARCHAR;
BEGIN
  l_sql = format('SELECT COALESCE(max(%s), 0) + 1 FROM %s;', i_table_field, i_table_name);
  EXECUTE l_sql INTO l_new_value;
  
  l_sql = format('ALTER SEQUENCE %s RESTART %s;', i_sequence_name, l_new_value);  
  EXECUTE l_sql;

END;
$body$
LANGUAGE 'plpgsql';