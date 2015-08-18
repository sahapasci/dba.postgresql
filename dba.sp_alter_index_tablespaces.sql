CREATE OR REPLACE FUNCTION dba.sp_alter_index_tablespaces (
  i_table_space_name varchar,
  i_schema_name varchar = 'public'::character varying
)
RETURNS TABLE (
  sql text
) AS
$body$
DECLARE
  l_schemas VARCHAR[];
BEGIN
  l_schemas = string_to_array(i_schema_name, ',');
  RETURN QUERY
    SELECT 
        'ALTER INDEX ' || i.schemaname || '.' || i.indexname || 
          ' SET TABLESPACE ' || i_table_space_name || ';' 
      FROM pg_indexes i
      WHERE i.schemaname = ANY (l_schemas);

END;
$body$
LANGUAGE 'plpgsql';