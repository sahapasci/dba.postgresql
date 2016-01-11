CREATE OR REPLACE FUNCTION dba.sp_get_top_10_index_sizes (
  inout schemaname text = 'public',
  out tablename text,
  out table_disc_size text,
  out index_disc_size text
)
RETURNS SETOF record AS 
$body$
BEGIN
  RETURN QUERY
  SELECT 
      ds.schemaname::TEXT,
      ds.tablename::TEXT, 
      pg_size_pretty(sum(ds.table_disc_size))::TEXT AS table_disc_size,
      pg_size_pretty(sum(ds.index_disc_size))::TEXT AS index_disc_size
    FROM dba.v_disc_spaces ds
    WHERE 
      ds.schemaname = $1
    GROUP BY 
      ds.schemaname,
      ds.tablename
    ORDER BY 
      sum(ds.index_disc_size) DESC
    LIMIT 10;
END;
$body$
LANGUAGE 'plpgsql';