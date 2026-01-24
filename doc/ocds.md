# ora* CODEDOC syntax (OCDs)

To understand how OCD is extracting all the information from source code, a clear and consistent syntax is required, the so-called ___ora* CODEDOC syntax (OCDs)___.

:information_source: Be aware that beside the extraction from source code, you can always edit the relevant information in the GUI.

## Overview

Basically all description text is extracted from `single line comments`. These comments must be in separate lines and right before the declaration.

```plsql
-- This is an example of a constant description.
c_magic_number constant integer := 1704;
```

```plsql
-- This is

-- working too.
c_magic_number constant
integer := 
1704;
```

```plsql
c_magic_number constant integer := 1704; -- But this is ignored.
```

## Package components

None, some or all components of a package can be described in source code.

:information_source: Currently not all components of a package are supported by OCDs. Future releases may also include:

- Subtypes
- Variables
- Cursors

### Package description

Right after the `CREATE OR REPLACE` statement and before the `AS` or `IS` keyword.

```plsql
create or replace package pkg_sample authid current_user
-- This is an example of a package description.
is
```

### Subprogram description

Right before the declaration.

```plsql
-- This is an example of a procedure description.
procedure p_noop;
```

#### Parameter description

To distinguish a _normal comment_ from a _parameter comment_, all comments related to parameters (or record fields) must begin with a leading `@` character.

```plsql
-- Function for square a number.
-- The return value is the result of multiplying the parameter by itself.
-- @A numeric value.
-- The square of any non-zero real number, whether positive or negative, is
-- always a positive number.
function f_square(i_value in number) return number;
```

:exclamation:Because the return value of a function is not a parameter, it is not commented.

:exclamation:The syntax to describe parameters is the same as describe record fields.

#### Example code

Subprograms can have one or more code examples (anonymous block and/or sql statement).

To distinguish a *normal comment* from a *example comment*, all comments related to examples must begin with a leading `^` character.

Leading white-space characters are preserved in example comments and not trimmed. See `Parsing information > White-space characters` for details about white-space character handling.

```plsql
-- Function for square a number.
-- The return value is the result of multiplying the parameter by itself.
-- @A numeric value.
-- The square of any non-zero real number, whether positive or negative, is
-- always a positive number.
-- ^select ocd_demo.f_square from dual;
-- ^
--select ocd_demo.f_square(4)
--  from dual;
-- ^begin
--  dbms_output.put_line( 'square of 2 is '||f_square(2) );
--end;
function f_square(i_value number default 3) return number;
```

### Constant description

Right before the declaration.

```plsql
-- This is an example of a constant description.
c_magic_number constant integer := 1704;
```

### Exception description

Right before the declaration.

```plsql
-- This is an example of an exception description.
e_parsing_failed exception;
```

### Type description

Right before the declaration.

```plsql
-- This is an example of an associative array.
-- It was formerly called PL/SQL table or index-by table.
type t_number_aa is table of number index by varchar2(64 char); 
-- This is an example of a varray (variable-size array).
type t_number_va is varray(5) of number;
-- This is an example of a nested table.
type t_number_nt is table of number;
```

#### Field description

To distinguish a _normal comment_ from a _field comment_, all comments related to record fields (or parameters) must begin with a leading `@` character.

```plsql
-- This is an example of an user-defined record type.
-- @The name of the operating system.
-- @Processor type of the system (in bit).
type t_os_r is record (
    platform     varchar2(64 char),
    architecture integer
);
```

:exclamation:The syntax to describe record fields is the same as describe parameters.

## Format options

To affect the rendering output there exist some basic markup formatting options.

### Paragraphs

Use a blank line with no white-space characters to create a paragraph.

```plsql
create or replace package demo authid current_user
-- Demonstration
-- package.
--
-- Line breaks are ignored but blank lines results in paragraphs.
is
```

### Hyperlinks

For [URIs](https://de.wikipedia.org/wiki/Uniform_Resource_Identifier) exist the possibility to append in square brackets a short name. But this is optionally.

```plsql
-- Check out https://www.google.de/ for more information.
--
-- Try also https://duckduckgo.com/[DuckDuckGo] as search engine.
```

To link to another PL/SQL documentation simply use the object name in double square brackets.

```plsql
-- For more information see package [[DEMO_API]].
```

References to other schema are possible too.

```plsql
-- For more information see package [[USERNAME.DEMO_API.GET_SOMETHING]].
```

## Parsing information

There are some things to know about white-space character handling and the support for the DEPRECATE Pragma in OCDs.

### White-space characters

- all leading and trailing spaces are trimmed

- line comments are concatenated with the following line by a single space character

- Tabs are automatically converted to two spaces

- Windows line breaks (CRLF) are automatically converted to UNIX line breaks (LF)

| Line comment                      | Saved string         | Explanation                           |
| --------------------------------- | -------------------- | ------------------------------------- |
| `--Lorem ipsum.`                  | Lorem ipsum.         | Standard :slightly_smiling_face:      |
| `-- Lorem ipsum. `                | Lorem ipsum.         | leading space is ignored.             |
| `-- Lorem ipsum. `                | Lorem ipsum.         | leading and trailing space is ignored |
| `--Lorem ipsum.  `                | Lorem ipsum.         | trailing spaces are ignored.          |
| `-- I like`<br>`-- ora* CODEDOC!` | I like ora* CODEDOC. | Lines are concatenated by a space.    |

### DEPRECATE Pragma

Since Oracle 12 the [DEPRECATE Pragma](https://docs.oracle.com/en/database/oracle/oracle-database/23/lnpls/DEPRECATE-pragma.html) is supported in PL/SQL packages.

OCDs extract all DEPRECATE Pragmas, including the warning message (if exist).
