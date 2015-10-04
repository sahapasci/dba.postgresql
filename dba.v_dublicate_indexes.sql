CREATE VIEW dba.v_dublicate_indexes AS 

SELECT
    rank() OVER (ORDER BY schema_name, table_name) AS grp,
    schema_name, 
    table_name,
    unnest(index_names) AS index_names,
    unnest(index_sizes) AS index_sizes
  FROM (
    SELECT
        s.nspname AS schema_name,
        tc.relname AS table_name,
        array_agg(ic.relname) AS index_names,
        array_agg(pg_relation_size(i.indexrelid)) AS index_sizes
      FROM pg_index i
      JOIN pg_class tc ON tc.oid = i.indrelid
      JOIN pg_class ic ON ic.oid = i.indexrelid
      JOIN pg_namespace s ON s.oid = tc.relnamespace
      GROUP BY
        s.nspname,
        tc.relname,
        i.indrelid,
        i.indclass,
        i.indkey,
        i.indexprs,
        i.indpred,
        i.indisunique
      HAVING 
        count(*) > 1
    ) index_dbls;