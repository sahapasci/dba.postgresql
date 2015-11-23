CREATE OR REPLACE VIEW dba.v_disc_spaces AS
WITH tbl_spc AS (
  SELECT ts.spcname AS spcname
    FROM pg_tablespace ts 
    JOIN pg_database db ON db.dattablespace = ts.oid
    WHERE db.datname = current_database()
)
(
SELECT
    t.schemaname,
    t.tablename,
    pg_table_size('"' || t.schemaname || '"."' || t.tablename || '"') AS table_disc_size,
    NULL as index,
    0 as index_disc_size,
    COALESCE(t.tablespace, ts.spcname) AS tablespace
  FROM pg_tables t, tbl_spc ts

UNION ALL 

SELECT
    i.schemaname,
    i.tablename,
    0,
    i.indexname,
    pg_relation_size('"' || i.schemaname || '"."' || i.indexname || '"'),
    COALESCE(i.tablespace, ts.spcname)
  FROM pg_indexes i, tbl_spc ts
) 