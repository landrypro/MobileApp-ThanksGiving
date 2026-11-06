begin;

do $verification$
declare
  row_security_enabled boolean;
  row_security_forced boolean;
  invalid_value_rejected boolean := false;
  duplicate_revision_rejected boolean := false;
begin
  if to_regclass('public.daily_verse_contents') is null then
    raise exception 'La table public.daily_verse_contents est absente.';
  end if;

  select relrowsecurity, relforcerowsecurity
    into row_security_enabled, row_security_forced
    from pg_class
   where oid = 'public.daily_verse_contents'::regclass;

  if not row_security_enabled or not row_security_forced then
    raise exception 'RLS doit être activé et forcé sur daily_verse_contents.';
  end if;

  if has_table_privilege('anon', 'public.daily_verse_contents', 'select')
     or has_table_privilege('authenticated', 'public.daily_verse_contents', 'select') then
    raise exception 'anon/authenticated ne doivent pas lire directement daily_verse_contents.';
  end if;

  if not has_table_privilege('service_role', 'public.daily_verse_contents', 'select,insert,update,delete') then
    raise exception 'service_role doit pouvoir administrer daily_verse_contents.';
  end if;

  insert into public.daily_verse_contents (
    content_date,
    slot,
    language_code,
    translation_code,
    translation_name,
    reference,
    verse_text,
    reflection,
    action,
    attribution,
    editorial_status,
    version
  ) values (
    date '2026-11-04',
    'midday',
    'fr',
    'jnd',
    'Bible J.N. Darby',
    'Psaume 100:4',
    'Texte de vérification non éditorial.',
    'Réflexion de vérification.',
    'Action de vérification.',
    'Donnée technique temporaire.',
    'approved',
    1
  );

  begin
    insert into public.daily_verse_contents (
      content_date,
      slot,
      language_code,
      translation_code,
      translation_name,
      reference,
      verse_text,
      reflection,
      action,
      attribution,
      editorial_status,
      version
    ) values (
      date '2026-11-04',
      'invalid_slot',
      'fr',
      'jnd',
      'Bible J.N. Darby',
      'Test 1:1',
      'Valeur invalide.',
      'Réflexion.',
      'Action.',
      'Attribution.',
      'approved',
      2
    );
  exception
    when check_violation then
      invalid_value_rejected := true;
  end;

  if not invalid_value_rejected then
    raise exception 'La contrainte de créneau n’a pas rejeté une valeur invalide.';
  end if;

  begin
    insert into public.daily_verse_contents (
      content_date,
      slot,
      language_code,
      translation_code,
      translation_name,
      reference,
      verse_text,
      reflection,
      action,
      attribution,
      editorial_status,
      version
    ) values (
      date '2026-11-04',
      'midday',
      'fr',
      'jnd',
      'Bible J.N. Darby',
      'Psaume 100:4',
      'Révision dupliquée.',
      'Réflexion.',
      'Action.',
      'Attribution.',
      'approved',
      1
    );
  exception
    when unique_violation then
      duplicate_revision_rejected := true;
  end;

  if not duplicate_revision_rejected then
    raise exception 'La contrainte d’unicité de révision n’a pas rejeté un doublon.';
  end if;
end
$verification$;

select
  'daily_verse_contents: contraintes et RLS validées' as verification_result;

rollback;

