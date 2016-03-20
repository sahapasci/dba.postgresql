CREATE FUNCTION dba.sp_copy_user_priviledges (
  i_from_user TEXT,
  i_to_user TEXT,
  i_revoke_previous BOOLEAN,
  i_execute BOOLEAN = false,
  out sql TEXT
)
RETURNS SETOF text AS
$body$
BEGIN
  IF i_revoke_previous THEN
    FOR sql IN 
      SELECT 
          'REVOKE ' || string_agg(tg.privilege_type, ', ') || ' ON "' || tg.table_schema || '"."'|| tg.table_name || '" FROM "' || tg.grantee || '";' 
        FROM information_schema.role_table_grants tg
        WHERE 
          tg.grantee = i_to_user
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
        'GRANT ' || string_agg(tg.privilege_type, ', ') || ' ON "' || tg.table_schema || '"."'|| tg.table_name || '" TO "' || i_to_user || '";' 
      FROM information_schema.role_table_grants tg
      WHERE 
        tg.grantee = i_from_user
      GROUP BY tg.grantee, tg.table_schema, tg.table_name
    LOOP
      IF i_execute THEN
        EXECUTE sql;
      END IF;    
      RETURN NEXT;
    END LOOP;
END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER;