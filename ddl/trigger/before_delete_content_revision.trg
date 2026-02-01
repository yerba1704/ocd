create or replace trigger before_delete_content_revision before
  delete on content_revision
  for each row
begin
  insert into content_revision_gtt values (
    :old.package_id,
    :old.component_id,
    :old.modified_comment_or_code,
    :old.modified_deprecated_fl,
    :old.modified_deprecation_text,
    :old.priority_fl,
    :old.modified_by,
    :old.modified_at
  );
end;
