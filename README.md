<!-- allgemeines kleinkram buttons wie coverage und co. sowie buy me a beer -->

# ora* CODEDOC

## Introduction

The always free __ora* CODEDOC__ is a framework to create technical documentation for PL/SQL packages.

The description text of each part of a package can be modified by comments in the package specification (syntax details can be found [here](doc/ocds.md)) or directliy inside the APEX application [ocd-apex](https://github.com/yerba1704/ocd-apex).

## Example usage

comming soon...

<!--
To get a basic HTML based single page type:

```plsql
asdasdsddasds
```

You can also use a WYSIWYG Editor in ocd-apex

All existing rules and definitions are available in the `ruleset` view:

`select * from occ.ruleset;`

To check a specific rule (singular) pass the id...

`exec occ.api.check_rule(i_rule_id_or_code => 'OCC-30010');`

...or raise an exception if the check failed:

`exec occ.api.check_rules(i_value => OCC.API.MINOR, i_raise_if_fail => true);`

All existing rules can be checked without passing any  parameter:

`exec occ.api.check_rules;`

Each procedure also exists as a table function and provide exactly the same functionality (parameters and behavior are equal). The only difference is the output of the results. The function provide output as a collection and therefore need to be executed as select statement.

`select * from occ.api.check_rules(i_value => 'MINOR');`

is similar to

`exec occ.api.check_rules(i_value => OCC.API.MINOR);`

Here is an example for a SQL statement which use the table function for several specific rules:

```sql
select * from 
    (select rule_id from occ.ruleset where rule_id like '%-40%') several_rule_ids,
    occ.api.check_rule(i_rule_id_or_code => several_rule_ids.rule_id)
```

The full PL/SQL Package Reference for the public API package can be found [here](doc/api.adoc). -->

## Data Model

All information from comments in the package specification are stored in these tables:

```
SCHEMA_PACKAGE
      ╠PACKAGE_CONSTANT
      ╠PACKAGE_EXCEPTION
      ╠PACKAGE_SUBPROGRAM
      ║       ╠SUBPROGRAM_ARGUMENT
      ║       ╚SUBPROGRAM_EXAMPLE
      ╚PACKAGE_TYPE
              ╚TYPE_FIELD
```

<!--hier tabelle die zeigt wie aufbau und zusammenhang... generieren mit /home/alegria/Development/_git/yerba1704/spielwiese/ocd/doc/adhoc_data_model_from_dictionary.sql -->

## ora* CODEDOC syntax (OCDs)

There are several things to know about the syntax of code documentation. Details can be found [here](doc/ocds.md).

## ora* CODEDOC publisher (OCDp)

OCD support many different publisher. From single standalone HTML file to a complete APEX Application nearly everything is possible. Read [here](doc/ocdp.md) about existing publisher.

## Installation

To install __ora* CODEDOC__ execute the script `admin_install.sql`. This will create a new user `OCD`, grant all required privileges to that user and grant the `API` package to public. You should change the pre-defined environment variables _ocd_password_ and _ocd_tabespace_ according to your environment.

The `OCD` user receive the following privileges:

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
