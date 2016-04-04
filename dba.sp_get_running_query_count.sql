CREATE OR REPLACE FUNCTION dba.sp_get_running_query_count (
  out running_query integer
)
RETURNS integer AS
$body$
BEGIN

  SELECT 
      count(*)
    INTO 
      running_query
    FROM pg_stat_activity sa
    WHERE 
      sa.state = 'active' AND 
      sa.state_change < now() -  ('5' ||' minutes')::INTERVAL;
END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY DEFINER;
