CREATE OR REPLACE FUNCTION dba.sp_get_replica_delay_sec (
  out delay_sec integer
)
RETURNS integer AS
$body$
BEGIN
  IF (pg_is_in_recovery()) THEN
    delay_sec = ceil(EXTRACT(EPOCH FROM (clock_timestamp() - pg_last_xact_replay_timestamp())));
  ELSE 
    delay_sec = 0;
  END IF;
  
END;
$body$
LANGUAGE 'plpgsql';