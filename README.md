<!-- allgemeines kleinkram buttons wie coverage und co. sowie buy me a beer -->

# ora* CODEDOC

## Introduction

The always free __ora* CODEDOC__ is a framework for creating technical documentation for PL/SQL packages.
It can produce output in a format similar to Oracle’s [APEX API](https://docs.oracle.com/en/database/oracle/apex/24.2/aeapi/index.html) and [Database PL/SQL Packages](https://docs.oracle.com/en/database/oracle/oracle-database/26/arpls/) references.

The description text of each part of a package can be modified by comments in the package specification (syntax details can be found [here](doc/ocds.md)) or directly inside the APEX application [ocd-apex](https://github.com/yerba1704/ocd-apex).

## Example usage

The `API` package provides access to all relevant information in JSON format. Simply use the `information`function:

```sql
select ocd.api.information(i_package_name => 'PKG_SAMPLE',
                           i_schema_name  => 'OCD_DEMO')
  from dual;
```

With the JSON output you can build whatever you want. Look before getting started at the existing __ora* CODEDOC publishers__ [here](doc/ocdp.md) to see what has already been implemented by the community.

When you get something like this...

```json
{"name":"YOUR_PACKAGE_NAME","status":"NO_DATA_FOUND"}
```

...simply analyze the package explicitly using:

```plsql
begin
  ocd.api.inspect(
    i_package_code => dbms_metadata.get_ddl('PACKAGE_SPEC', 'API'),
    i_package_name => 'API'
  );
end;
```

You can also recompile the package in your IDE or via command.

```plsql
alter package YOUR_PACKAGE_NAME compile;
```

<!--The full PL/SQL Package Reference for the public API package can be found [here](doc/api.adoc). -->

## ora* CODEDOC syntax (OCDs)

There are several things to know about the syntax of code documentation. Details can be found [here](doc/ocds.md).

## ora* CODEDOC publisher (OCDp)

OCD supports many different publishers. From single standalone HTML files to a complete APEX application, nearly everything is possible. Read [here](doc/ocdp.md) about existing publishers.

## Installation

To install __ora* CODEDOC__ execute the script `admin_install.sql`. This will create a new user `OCD`, grant all required privileges to that user and grant the `API` package to public. You should change the pre-defined environment variables *ocd_password* and *ocd_tablespace* according to your environment.

The `OCD` user receives the following privileges:

- create session
- create table
- create sequence
- create view,
- create procedure
- create type
- create trigger
- administer database trigger

## Requirements

__ora* CODEDOC__ will run on any Oracle Database version 18c or above. 

## Contributing to the project

If you have an interesting feature in mind, that you would like to see in __ora* CODEDOC__ please create a [new issue](https://github.com/yerba1704/ocd/issues).

## License

__ora* CODEDOC__ is released under the [MIT license](LICENSE).
