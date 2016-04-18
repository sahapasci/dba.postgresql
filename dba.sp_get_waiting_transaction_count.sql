CREATE OR REPLACE FUNCTION dba.sp_get_waiting_transaction_count (
  out waiting_count integer
)
RETURNS integer AS
$body$
BEGIN

  SELECT 
      count(*)
    INTO 
      waiting_count
    FROM pg_stat_activity sa
    WHERE 
      sa.waiting = true;
END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY DEFINER;
