CREATE OR REPLACE VIEW dba.v_disc_spaces AS
SELECT
    t.schemaname,
    t.tablename,
    pg_table_size('"' || t.schemaname || '"."' || t.tablename || '"') AS table_disc_size,
    NULL as index,
    0 as index_disc_size,
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