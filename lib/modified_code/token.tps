--------------------------------------------------------------------------------
-- Used by PLSQL_LEXER
--------------------------------------------------------------------------------
create or replace type token is object
(
	type                varchar2(4000), --String to represent token type.  See the constants in PLSQL_LEXER.
	value               clob,           --The text of the token.
	line_number         number,         --The line number the token starts at - useful for printing warning and error information.
	column_number       number,         --The column number the token starts at - useful for printing warning and error information.
	first_char_position number,         --First character position of token in the whole string - useful for inserting before a token.
	last_char_position  number,         --Last character position of token in the whole string  - useful for inserting after a token.
	sqlcode             number,         --Error code of serious parsing problem.
	sqlerrm             varchar2(4000)  --Error message of serious parsing problem.
);
/