CREATE OR REPLACE FUNCTION dba.sp_alter_index_tablespaces (
  i_tablespace varchar,
  i_schema varchar = 'public'
)
RETURNS TABLE (
  sql text
) AS
$body$
DECLARE
  l_schemas VARCHAR[];
BEGIN
  l_schemas = string_to_array(i_schema, ',');
  RETURN QUERY
    SELECT 
        'ALTER INDEX ' || i.schemaname || '.' || i.indexname || 
          ' SET TABLESPACE ' || i_tablespace || ';' 
      FROM pg_indexes i
      WHERE 
        i.schemaname = ANY (l_schemas) AND 
        i.tablespace IS DISTINCT FROM i_tablespace
    ORDER BY pg_relation_size((i.schemaname || '.' || i.indexname)::regclass);

END;
$body$
LANGUAGE 'plpgsql';
