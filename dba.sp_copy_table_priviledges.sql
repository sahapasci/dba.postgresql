CREATE OR REPLACE FUNCTION dba.sp_copy_table_priviledges (
  i_from_schema text,
  i_from_table text,
  i_to_schema text,
  i_to_table text,
  i_revoke_previous boolean,
  i_execute boolean = false,
  out sql text
)
RETURNS SETOF text AS
$body$
DECLARE
  l_sql VARCHAR;
BEGIN
  IF i_revoke_previous THEN
    FOR sql IN 
      SELECT 
          'REVOKE ' || string_agg(tg.privilege_type, ', ') || ' ON "' || tg.table_schema || '"."'|| tg.table_name || '" FROM "' || tg.grantee || '";' 
        FROM information_schema.role_table_grants tg
        WHERE 
          tg.table_schema = i_to_schema AND
          tg.table_name = i_to_table
        GROUP BY tg.grantee, tg.table_schema, tg.table_name
      LOOP
        IF i_execute THEN
          EXECUTE sql;
        END IF;
        RETURN NEXT;
      END LOOP;  
  END IF;

  FOR sql IN 
    SELECT 
        'GRANT ' || string_agg(tg.privilege_type, ', ') || ' ON "' || i_to_schema || '"."'|| i_to_table || '" TO "' || tg.grantee || '";' 
      FROM information_schema.role_table_grants tg
      WHERE 
        tg.table_schema = i_from_schema AND
        tg.table_name = i_from_table
      GROUP BY tg.grantee, tg.table_schema, tg.table_name
    LOOP
      IF i_execute THEN
        EXECUTE sql;
      END IF;    
      RETURN NEXT;
    END LOOP;
    
  SELECT 
      'ALTER TABLE "' || i_to_schema || '"."' || i_to_table || '" OWNER TO "'|| t.tableowner || '";'
    INTO
      sql
    FROM pg_tables t
    WHERE t.schemaname = i_from_schema AND
          t.tablename = i_from_table;    
  
  IF i_execute THEN
    EXECUTE sql;
  END IF;
  RETURN NEXT;
    
END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
RETURNS NULL ON NULL INPUT
SECURITY INVOKER
COST 100 ROWS 1000;