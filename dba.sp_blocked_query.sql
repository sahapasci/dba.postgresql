CREATE OR REPLACE FUNCTION dba.sp_blocked_query (
  g_blocked_pid integer,
  out blocked_pid integer,
  out blocked_user varchar,
  out blocked_process_age interval,
  out blocked_transaction_age interval,
  out blocked_query_age interval,
  out blocked_query varchar,
  out blocked_application_name varchar,
  out blocked_client_addr varchar,
  out blocked_client_port varchar,
  out blocking_pid integer,
  out blocking_user varchar,
  out blocking_process_age interval,
  out blocking_transaction_age interval,
  out blocking_query_age interval,
  out blocking_query varchar,
  out blocking_application_name varchar,
  out blocking_client_addr varchar,
  out blocking_client_port varchar
)
RETURNS SETOF record AS
$body$
BEGIN
  SELECT
      psa_bed.pid AS blocked_pid,
      psa_bed.usename::VARCHAR AS blocked_user,
      age(now(), psa_bed.backend_start) AS blocked_process_age,
      age(now(), psa_bed.xact_start) AS blocked_transaction_age,
      age(now(), psa_bed.query_start) AS blocked_query_age,
      psa_bed.query::VARCHAR AS blocked_query,
      psa_bed.application_name::VARCHAR AS blocked_application_name,
      psa_bed.client_addr::VARCHAR AS blocked_client_addr,
      psa_bed.client_port::VARCHAR AS blocked_client_port,
      psa_bing.pid AS blocking_pid,
      psa_bing.usename::VARCHAR AS blocking_user,
      age(now(), psa_bing.backend_start) AS blocking_process_age,
      age(now(), psa_bing.xact_start) AS blocking_transaction_age,
      age(now(), psa_bing.query_start) AS blocking_query_age,
      psa_bing.query::VARCHAR AS blocking_query,
      psa_bing.application_name::VARCHAR AS blocking_application_name,
      psa_bing.client_addr::VARCHAR AS blocking_client_addr,
      psa_bing.client_port::VARCHAR AS blocking_client_port
    INTO
      blocked_pid,
      blocked_user,
      blocked_process_age,
      blocked_transaction_age,
      blocked_query_age,
      blocked_query,
      blocked_application_name,
      blocked_client_addr,
      blocked_client_port,
      blocking_pid,
      blocking_user,
      blocking_process_age,
      blocking_transaction_age,
      blocking_query_age,
      blocking_query,
      blocking_application_name,
      blocking_client_addr,
      blocking_client_port
    FROM pg_catalog.pg_locks l_bed
    JOIN pg_catalog.pg_stat_activity psa_bed ON l_bed.pid = psa_bed.pid
    JOIN pg_catalog.pg_locks l_bing ON l_bed.locktype = l_bing.locktype AND
                                       l_bed.database IS NOT DISTINCT FROM l_bing.database AND 
                                       l_bed.relation IS NOT DISTINCT FROM l_bing.relation AND 
                                       l_bed.page IS NOT DISTINCT FROM l_bing.page AND 
                                       l_bed.tuple IS NOT DISTINCT FROM l_bing.tuple AND 
                                       l_bed.virtualxid IS NOT DISTINCT FROM l_bing.virtualxid AND 
                                       l_bed.transactionid IS NOT DISTINCT FROM l_bing.transactionid AND 
                                       l_bed.classid IS NOT DISTINCT FROM l_bing.classid AND 
                                       l_bed.objid IS NOT DISTINCT FROM l_bing.objid AND 
                                       l_bed.objsubid IS NOT DISTINCT FROM l_bing.objsubid AND 
                                       l_bed.pid <> l_bing.pid
    JOIN pg_catalog.pg_stat_activity psa_bing ON l_bing.pid = psa_bing.pid
    WHERE 
      l_bed.pid = g_blocked_pid AND
      l_bing.granted IS TRUE AND
      l_bed.granted IS FALSE;

    IF FOUND THEN
      RETURN NEXT;
      RETURN QUERY SELECT * FROM dba.sp_blocked_query(blocking_pid);
    END IF;
    
END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
RETURNS NULL ON NULL INPUT
SECURITY INVOKER
COST 10 ROWS 20;