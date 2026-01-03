create procedure l(i_log_message in varchar2) authid definer is pragma autonomous_transaction;
  begin insert into logs(message) values (i_log_message); commit; end;
/