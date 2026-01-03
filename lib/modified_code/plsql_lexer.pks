create or replace package plsql_lexer authid definer is
--Copyright (C) 2020 Jon Heller.  This program is licensed under the LGPLv3.
C_VERSION constant varchar2(10) := '2.0.1';

--Main functions:
function lex(p_source in clob) return token_table;

--Helper functions useful for some tools:
function is_lexical_whitespace(p_char varchar2) return boolean;
function get_varchar2_table_from_clob(p_clob clob) return varchar2_table;

--Constants for token types.
C_WHITESPACE                 constant varchar2(10) := 'whitespace';
C_COMMENT                    constant varchar2(7)  := 'comment';
C_TEXT                       constant varchar2(4)  := 'text';
C_NUMERIC                    constant varchar2(7)  := 'numeric';
C_WORD                       constant varchar2(4)  := 'word';
C_INQUIRY_DIRECTIVE          constant varchar2(17) := 'inquiry_directive';
C_PREPROCESSOR_CONTROL_TOKEN constant varchar2(26) := 'preprocessor_control_token';

"C_,}?"                      constant varchar2(3)  := '_,}';

"C_~="                       constant varchar2(2)  := '~=';
"C_!="                       constant varchar2(2)  := '!=';
"C_^="                       constant varchar2(2)  := '^=';
"C_<>"                       constant varchar2(2)  := '<>';
"C_:="                       constant varchar2(2)  := ':=';
"C_=>"                       constant varchar2(2)  := '=>';
"C_>="                       constant varchar2(2)  := '>=';
"C_<="                       constant varchar2(2)  := '<=';
"C_**"                       constant varchar2(2)  := '**';
"C_||"                       constant varchar2(2)  := '||';
"C_<<"                       constant varchar2(2)  := '<<';
"C_>>"                       constant varchar2(2)  := '>>';
"C_{-"                       constant varchar2(2)  := '{-';
"C_-}"                       constant varchar2(2)  := '-}';
"C_*?"                       constant varchar2(2)  := '*?';
"C_+?"                       constant varchar2(2)  := '+?';
"C_??"                       constant varchar2(2)  := '??';
"C_,}"                       constant varchar2(2)  := ',}';
"C_}?"                       constant varchar2(2)  := '}?';
"C_{,"                       constant varchar2(2)  := '{,';
"C_.."                       constant varchar2(2)  := '..';

"C_!"                        constant varchar2(1)  := '!';
"C_@"                        constant varchar2(1)  := '@';
"C_$"                        constant varchar2(1)  := '$';
"C_%"                        constant varchar2(1)  := '%';
"C_^"                        constant varchar2(1)  := '^';
"C_*"                        constant varchar2(1)  := '*';
"C_("                        constant varchar2(1)  := '(';
"C_)"                        constant varchar2(1)  := ')';
"C_-"                        constant varchar2(1)  := '-';
"C_+"                        constant varchar2(1)  := '+';
"C_="                        constant varchar2(1)  := '=';
"C_["                        constant varchar2(1)  := '[';
"C_]"                        constant varchar2(1)  := ']';
"C_{"                        constant varchar2(1)  := '{';
"C_}"                        constant varchar2(1)  := '}';
"C_|"                        constant varchar2(1)  := '|';
"C_:"                        constant varchar2(1)  := ':';
"C_;"                        constant varchar2(1)  := ';';
"C_<"                        constant varchar2(1)  := '<';
"C_,"                        constant varchar2(1)  := ',';
"C_>"                        constant varchar2(1)  := '>';
"C_."                        constant varchar2(1)  := '.';
"C_/"                        constant varchar2(1)  := '/';
"C_?"                        constant varchar2(1)  := '?';

C_EOF                        constant varchar2(26) := 'EOF';
C_unexpected                 constant varchar2(10) := 'unexpected';

/*
Note:
	"#" is not included.
	The XMLSchema_spec clause in the manual implies that "#" is valid syntax but
	testing shows that the "#" must still be enclosed in double quotes.

*/

end;
/