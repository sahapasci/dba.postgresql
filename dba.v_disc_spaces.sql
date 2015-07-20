CREATE OR REPLACE VIEW dba.v_disc_spaces AS
SELECT
    t.schemaname,
    t.tablename,
    pg_relation_size('"' || t.schemaname || '"."' || t.tablename || '"') AS tablo_disk_boyutu,
    NULL as index,
    0 as index_disc_boyutu,
    t.tablespace
  FROM pg_tables t

UNION ALL 

SELECT
    i.schemaname,
    i.tablename,
    0,
    i.indexname,
    pg_relation_size('"' || i.schemaname || '"."' || i.indexname || '"'),
    i.tablespace
  FROM pg_indexes i;
  
COMMENT ON VIEW dba.v_disc_spaces
IS 'CREATE OR REPLACE VIEW dba.v_disc_spaces AS
SELECT
    t.schemaname,
    t.tablename,
    pg_relation_size(''"'' || t.schemaname || ''"."'' || t.tablename || ''"'') AS tablo_disk_boyutu,
    NULL as index,
    0 as index_disc_boyutu,
    t.tablespace
  FROM pg_tables t

UNION ALL 

SELECT
    i.schemaname,
    i.tablename,
    0,
    i.indexname,
    pg_relation_size(''"'' || i.schemaname || ''"."'' || i.indexname || ''"''),
    i.tablespace
  FROM pg_indexes i;';  