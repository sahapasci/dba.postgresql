create or replace function update_user_privileges() returns text as
$$
declare

       info record;
       str text;

begin
       /*Grant privileges to user B the same as with user A for a given table schema*/
      str:=''; 
      FOR info IN 
          select * from information_schema.table_privileges where table_schema='public' and grantee = 'A'   
      LOOP 
          /*append the tables' name, for which we are assigning privileges from user A to B*/
          str:= str  ||info.table_name || ',';

         /*this is the main statement to grant any privilege*/
         execute 'GRANT '|| info.privilege_type ||' on table public.'|| info.table_name || ' to B';

      END LOOP;

  return str;
end

$$ language 'plpgsql';