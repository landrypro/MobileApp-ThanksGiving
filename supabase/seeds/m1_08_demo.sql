-- Jeu de demonstration local uniquement. A charger manuellement avec psql.
-- Aucune citation biblique, aucun contenu JND et aucune publication.
do $seed$
declare
  v_payload jsonb;
  v_created jsonb;
  v_author uuid := '00000000-0000-4000-8000-000000000101';
  v_biblical uuid := '00000000-0000-4000-8000-000000000102';
  v_linguistic uuid := '00000000-0000-4000-8000-000000000103';
  v_approver uuid := '00000000-0000-4000-8000-000000000104';
begin
  for v_payload in
    select jsonb_build_object(
      'content_date', '2099-01-01', 'slot', slot,
      'language_code', 'fr', 'translation_code', 'demo',
      'translation_name', 'Démonstration', 'reference', 'DÉMO ' || ordinal || ':1',
      'verse_text', 'Texte fictif du créneau ' || slot || ' — aucune citation biblique.',
      'reflection', 'Méditation fictive pour vérifier la relecture.',
      'action', 'Action de démonstration.',
      'attribution', 'Contenu fictif — aucun verset biblique.',
      'source_provider', 'demo'
    )
    from (values ('morning', 1), ('midday', 2), ('evening', 3)) as fixtures(slot, ordinal)
  loop
    if exists (
      select 1 from public.daily_verse_contents
      where content_date = date '2099-01-01'
        and slot = v_payload->>'slot'
        and language_code = 'fr' and translation_code = 'demo'
    ) then
      continue;
    end if;
    v_created := public.editorial_apply('create', null, v_payload, v_author, array['editor']);
    if v_payload->>'slot' in ('midday', 'evening') then
      perform public.editorial_apply('submit', (v_created->>'id')::uuid, '{}'::jsonb, v_author, array['editor']);
    end if;
    if v_payload->>'slot' = 'evening' then
      perform public.editorial_apply('biblical_approve', (v_created->>'id')::uuid, '{}'::jsonb, v_biblical, array['biblical_reviewer']);
      perform public.editorial_apply('linguistic_approve', (v_created->>'id')::uuid, '{}'::jsonb, v_linguistic, array['linguistic_reviewer']);
      perform public.editorial_apply('approve', (v_created->>'id')::uuid, '{}'::jsonb, v_approver, array['approver']);
    end if;
  end loop;
end
$seed$;
