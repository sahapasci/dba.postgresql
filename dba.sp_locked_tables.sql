CREATE OR REPLACE FUNCTION dba.sp_locked_tables (
  g_table_name varchar,
  out client_addr inet,
  out procpid integer,
  out usename name,
  out current_query text,
  out waiting boolean
)
RETURNS SETOF record AS
$body$
BEGIN
  RETURN QUERY 
    SELECT
        psa.client_addr,
        psa.procpid,
        psa.usename,
        psa.current_query,
        psa.waiting
      FROM pg_stat_activity psa 
      WHERE
        psa.procpid IN
      (
        SELECT
            pid
          FROM pg_locks
          WHERE
            relation IN (
              SELECT
                  OID
                FROM pg_class
                WHERE
                  relname = g_table_name 
                      )
       );
END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100 ROWS 1000;