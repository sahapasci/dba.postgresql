CREATE OR REPLACE FUNCTION dba.sp_get_idle_in_transaction_count (
  out idle_in_transaction integer
)
RETURNS integer AS
$body$
BEGIN

  SELECT 
      count(*)
    INTO 
      idle_in_transaction
    FROM pg_stat_activity sa
    WHERE 
      sa.state = 'idle in transaction' AND 
      sa.state_change < now() -  ('5' ||' minutes')::INTERVAL;
END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY DEFINER;
