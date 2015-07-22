CREATE OR REPLACE FUNCTION dba.sp_refresh_all_sequences (
  i_schema_name VARCHAR = 'public'
)
RETURNS void AS
$body$
BEGIN
PERFORM 
    dba.sp_refresh_sequence(i_schema_name || '.' || c.relname::VARCHAR, 
                            left(c.relname, length(c.relname) - 7))
  FROM pg_class c 
  JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE 
    c.relkind = 'S' AND 
    n.nspname = i_schema_name;

END;
$body$
LANGUAGE 'plpgsql';