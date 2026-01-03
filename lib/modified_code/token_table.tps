--------------------------------------------------------------------------------
-- Used by PLSQL_LEXER
--------------------------------------------------------------------------------
--Use VARRAY because it is guaranteed to maintain order.
create or replace type token_table is varray(2147483647) of token;
/