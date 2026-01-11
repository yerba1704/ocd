comment on table schema_package is
'Stores all ora* CODECOP analyzed packages, including their names and extracted comment text.';
comment on column schema_package.schema_name                  is 'Name of the schema that owns the package.';
comment on column schema_package.package_id                   is 'Unique identifier of the package.';
comment on column schema_package.package_name                 is 'Name of the package.';
comment on column schema_package.package_comment              is 'Textual description of the package purpose and behavior.';
comment on column schema_package.created_at                   is 'Timestamp indicating when the package was analyzed by ora* CODEDOC';
comment on column schema_package.deprecated_fl                is 'Flag indicating whether the package is deprecated.';
comment on column schema_package.deprecation_text             is 'Text explaining the reason for package deprecation and recommended alternatives.';
----------------------------------------------------------------------------------------------------------------------------------------------------------------
comment on table package_constant is
'Stores constants declared within a package specification, including their names and extracted comment text. Also the constant data type, value, and constraint information.';
comment on column package_constant.package_id                 is 'Identifier of the package in which the constant is declared.';
comment on column package_constant.constant_id                is 'Unique identifier of the constant.';
comment on column package_constant.constant_name              is 'Declared name of the constant.';
comment on column package_constant.constant_comment           is 'Textual description of the constant purpose and usage.';
comment on column package_constant.constant_datatype          is 'Declared datatype of the constant.';
comment on column package_constant.constant_null_fl           is 'Flag indicating whether the constant allows NULL values.';
comment on column package_constant.constant_value             is 'Declared value assigned to the constant.';
comment on column package_constant.deprecated_fl              is 'Flag indicating whether the constant is deprecated.';
comment on column package_constant.deprecation_text           is 'Text explaining the reason for constant deprecation and recommended alternatives.';
comment on column package_constant.order_sequence             is 'Sequence number defining the constant ordering within the package.';
----------------------------------------------------------------------------------------------------------------------------------------------------------------
comment on table package_exception is
'Stores exceptions declared within a package specification, including their names and extracted comment text.';
comment on column package_exception.package_id                is 'Identifier of the package in which the exception is declared.';
comment on column package_exception.exception_id              is 'Unique identifier of the exception.';
comment on column package_exception.exception_name            is 'Declared name of the exception.';
comment on column package_exception.exception_comment         is 'Textual description of the exception condition and usage.';
comment on column package_exception.deprecated_fl             is 'Flag indicating whether the exception is deprecated.';
comment on column package_exception.deprecation_text          is 'Text explaining the reason for exception deprecation and recommended alternatives.';
comment on column package_exception.order_sequence            is 'Sequence number defining the exception ordering within the package.';
----------------------------------------------------------------------------------------------------------------------------------------------------------------
comment on table package_subprogram is
'Stores procedures and functions declared within a package specification, including their names and extracted comment text.';
comment on column package_subprogram.package_id               is 'Identifier of the package in which the subprogram is declared.';
comment on column package_subprogram.subprogram_id            is 'Unique identifier of the subprogram.';
comment on column package_subprogram.subprogram_name          is 'Declared name of the subprogram (procedure or function).';
comment on column package_subprogram.subprogram_comment       is 'Textual description of the subprogram behavior and usage.';
comment on column package_subprogram.deprecated_fl            is 'Flag indicating whether the subprogram is deprecated.';
comment on column package_subprogram.deprecation_text         is 'Text explaining the reason for subprogram deprecation and recommended alternatives.';
comment on column package_subprogram.order_sequence           is 'Sequence number defining the subprogram ordering within the package.';
----------------------------------------------------------------------------------------------------------------------------------------------------------------
comment on table subprogram_argument is
'Stores arguments for package subprograms, including their names and extracted comment text.';
comment on column subprogram_argument.subprogram_id           is 'Identifier of the subprogram to which the argument belongs.';
comment on column subprogram_argument.argument_id             is 'Unique identifier of the subprogram argument.';
comment on column subprogram_argument.argument_name           is 'Declared name of the argument.';
comment on column subprogram_argument.argument_comment        is 'Textual description of the argument purpose and usage.';
comment on column subprogram_argument.argument_default        is 'Default value assigned to the argument, if specified.';
comment on column subprogram_argument.order_sequence          is 'Position of the argument within the subprogram definition.';
----------------------------------------------------------------------------------------------------------------------------------------------------------------
comment on table subprogram_example is
'Stores usage examples or sample calls for package subprograms to illustrate correct usage.';
comment on column subprogram_example.subprogram_id            is 'Identifier of the subprogram demonstrated by the example.';
comment on column subprogram_example.example_id               is 'Unique identifier of the example.';
comment on column subprogram_example.example_name             is 'Generic name of the example.';
comment on column subprogram_example.example_code             is 'Code sample demonstrating usage of the subprogram.';
comment on column subprogram_example.order_sequence           is 'Sequence number defining the example ordering within the package.';
----------------------------------------------------------------------------------------------------------------------------------------------------------------
comment on table package_type is
'Stores collections and records declared within a package specification, including their names and extracted comment text.';
comment on column package_type.type_id                        is 'Unique identifier of the type.';
comment on column package_type.type_name                      is 'Declared name of the type.';
comment on column package_type.type_comment                   is 'Textual description of the type structure and purpose.';
comment on column package_type.deprecated_fl                  is 'Flag indicating whether the type is deprecated.';
comment on column package_type.deprecation_text               is 'Text explaining the reason for type deprecation and recommended alternatives.';
comment on column package_type.order_sequence                 is 'Sequence number defining the type ordering within the package.';
comment on column package_type.package_id                     is 'Identifier of the package in which the type is declared.';
----------------------------------------------------------------------------------------------------------------------------------------------------------------
comment on table type_field is
'Stores fields of a record type, including their names and extracted comment text.';
comment on column type_field.type_id                          is 'Identifier of the type to which the field belongs.';
comment on column type_field.field_id                         is 'Unique identifier of the type field.';
comment on column type_field.field_name                       is 'Declared name of the field.';
comment on column type_field.field_comment                    is 'Textual description of the field purpose and usage.';
comment on column type_field.order_sequence                   is 'Position of the field within the type definition.';
----------------------------------------------------------------------------------------------------------------------------------------------------------------
comment on table content_revision is
'Stores all package component information analyzed by ora* CODECOP in the order of occurrence within the package specification. It is automatically synchronized and can be used to modify the extracted text.';
comment on column content_revision.schema_name                is 'Name of the schema that owns the package.';
comment on column content_revision.package_id                 is 'Identifier of the related package.';
comment on column content_revision.package_name               is 'Name of the package.';
comment on column content_revision.component_name             is 'Name of the package component.';
comment on column content_revision.component_sequence         is 'The sequence number that identifies the position of the component within the package..';
comment on column content_revision.component_type             is 'The type of the package component.';
comment on column content_revision.hierarchical_level         is 'Hierarchy level of the component within the package structure.';
comment on column content_revision.created_at                 is 'Timestamp indicating when the package was analyzed by ora* CODEDOC';
comment on column content_revision.original_comment_or_code   is 'Original comment text or example code prior to modification.';
comment on column content_revision.original_deprecated_fl     is 'Original deprecation flag value prior to modification.';
comment on column content_revision.original_deprecation_text  is 'Original deprecation text prior to modification.';
comment on column content_revision.modified_comment_or_code   is 'Updated comment text or example code after modification.';
comment on column content_revision.modified_deprecated_fl     is 'Updated deprecation flag value after modification.';
comment on column content_revision.modified_deprecation_text  is 'Updated deprecation text after modification.';
comment on column content_revision.priority_fl                is 'Flag to set the priority of the chosen comment (0 for the original from the source code or 1 for the modified one).';
comment on column content_revision.modified_by                is 'Name of the user that makes the modification.';
comment on column content_revision.modified_at                is 'Timestamp indicating when the row was changed.';
----------------------------------------------------------------------------------------------------------------------------------------------------------------
comment on table logs is 'Stores log entries.';
comment on column logs.log_id is 'Unique identifier of the log entry.';
comment on column logs.message is 'Message text describing the logged event.';
comment on column logs.created_at is 'Timestamp indicating when the log entry was created.';
----------------------------------------------------------------------------------------------------------------------------------------------------------------
comment on table package_component is
'View to list all components of a package specification row by row.';
comment on column package_component.package_id          is 'Identifier of the package to which the component belongs.';
comment on column package_component.package_name        is 'Name of the package to which the component belongs.';
comment on column package_component.created_at          is 'Timestamp indicating when the package was analyzed by ora* CODEDOC.';
comment on column package_component.hierarchical_level  is 'Hierarchy level of the component within the package structure.';
comment on column package_component.component_type      is 'The type of the package component.';
comment on column package_component.component_name      is 'Name of the package component.';
comment on column package_component.comment_or_code     is 'Comment text or example code.';
comment on column package_component.component_id        is 'Identifier of the referenced component entity.';
comment on column package_component.table_name          is 'Name of the table storing the component definition.';
comment on column package_component.deprecated_fl       is 'Flag indicating whether the component is deprecated.';
comment on column package_component.deprecation_text    is 'Text explaining the reason for component deprecation and recommended alternatives.';
comment on column package_component.schema_name         is 'Name of the schema that owns the package.';
