CREATE FUNCTION dba.sp_get_connection_usage (
  out connection_usage INTEGER
)
RETURNS INTEGER AS
$body$
BEGIN

  SELECT 
      (round((count(*)::FLOAT / s.setting::FLOAT)::NUMERIC, 2) * 100)::INTEGER
    INTO
      connection_usage
    FROM pg_settings s, pg_stat_activity sa
    WHERE s.name = 'max_connections'
    GROUP BY s.setting;

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY DEFINER;