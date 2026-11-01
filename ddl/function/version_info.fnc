create or replace function version_info return varchar2 authid definer is
  c_release constant dbms_id_30:='26.11.1'; -- yy.mm.dd
begin
  return c_release;
end version_info;