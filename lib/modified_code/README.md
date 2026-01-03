# Howto

- copy `original_code/types.sql` to `modified_code/`
- copy `original_code/packages/plsql_lexer.plsql` to `modified_code/`
- rename and split `types.sql` to ...
  - `token.tps`
  - `token_table.tps`
  - `varchar2_table.tps`
- split `plsql_lexer.plsql` to `plsql_lexer.pks` and `plsql_lexer.pkb`
- modify content of `plsql_lexer.pkb`
  - add authid definer to `plsql_lexer.pks`
  - remove functions `concatenate` and `print_tokens`
  - remove block comment
