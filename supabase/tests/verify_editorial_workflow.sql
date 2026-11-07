begin;

do $test$
declare
  v_author uuid := gen_random_uuid();
  v_biblical uuid := gen_random_uuid();
  v_linguistic uuid := gen_random_uuid();
  v_approver uuid := gen_random_uuid();
  v_manager uuid := gen_random_uuid();
  v_content jsonb;
  v_id uuid;
  v_rejected boolean := false;
begin
  if has_function_privilege('anon', 'public.editorial_apply(text,uuid,jsonb,uuid,text[])', 'execute')
     or has_function_privilege('authenticated', 'public.editorial_apply(text,uuid,jsonb,uuid,text[])', 'execute') then
    raise exception 'La mutation éditoriale ne doit pas être accessible directement aux clients.';
  end if;
  if has_table_privilege('authenticated', 'public.editorial_events', 'select') then
    raise exception 'Le journal éditorial ne doit pas être lisible directement.';
  end if;

  v_content := public.editorial_apply('create', null, jsonb_build_object(
    'content_date', '2099-02-02', 'slot', 'morning', 'language_code', 'fr',
    'translation_code', 'demo', 'translation_name', 'Démonstration',
    'reference', 'DÉMO 1:1', 'verse_text', 'Texte fictif, non biblique.',
    'reflection', 'Réflexion fictive.', 'action', 'Action fictive.',
    'attribution', 'Démonstration uniquement.', 'source_provider', 'demo'
  ), v_author, array['editor']);
  v_id := (v_content->>'id')::uuid;
  if v_content->>'editorial_status' <> 'draft' then
    raise exception 'Le contenu doit être créé en brouillon.';
  end if;
  perform public.editorial_apply('submit', v_id, '{}'::jsonb, v_author, array['editor']);

  begin
    perform public.editorial_apply('biblical_approve', v_id, '{}'::jsonb, v_author, array['biblical_reviewer']);
  exception when insufficient_privilege then
    v_rejected := true;
  end;
  if not v_rejected then raise exception 'L’auteur a pu relire son propre contenu.'; end if;

  perform public.editorial_apply('biblical_approve', v_id, '{}'::jsonb, v_biblical, array['biblical_reviewer']);
  perform public.editorial_apply('linguistic_approve', v_id, '{}'::jsonb, v_linguistic, array['linguistic_reviewer']);
  perform public.editorial_apply('approve', v_id, '{}'::jsonb, v_approver, array['approver']);
  perform public.editorial_apply('schedule', v_id, '{}'::jsonb, v_manager, array['editorial_admin']);
  v_content := public.editorial_apply('publish', v_id, '{}'::jsonb, v_manager, array['editorial_admin']);
  if v_content->>'editorial_status' <> 'published' or v_content->>'published_at' is null then
    raise exception 'Le contenu de démonstration ne s’est pas publié.';
  end if;
  v_content := public.editorial_apply('withdraw', v_id, '{"reason":"Test du retrait"}'::jsonb, v_manager, array['editorial_admin']);
  if v_content->>'editorial_status' <> 'withdrawn' or v_content->>'withdrawn_at' is null then
    raise exception 'Le retrait a échoué.';
  end if;
  if (select count(*) from public.editorial_events where content_id = v_id) <> 8 then
    raise exception 'Historique éditorial incomplet.';
  end if;

  v_content := public.editorial_apply('create', null, jsonb_build_object(
    'content_date', '2099-02-02', 'slot', 'midday', 'language_code', 'fr',
    'translation_code', 'jnd', 'translation_name', 'Bible J.N. Darby',
    'reference', 'DÉMO 2:1', 'verse_text', 'Placeholder technique, aucun verset.',
    'reflection', 'Réflexion fictive.', 'action', 'Action fictive.',
    'attribution', 'Placeholder technique.', 'source_provider', 'api.bible'
  ), v_author, array['editor']);
  v_id := (v_content->>'id')::uuid;
  perform public.editorial_apply('submit', v_id, '{}'::jsonb, v_author, array['editor']);
  perform public.editorial_apply('biblical_approve', v_id, '{}'::jsonb, v_biblical, array['biblical_reviewer']);
  perform public.editorial_apply('linguistic_approve', v_id, '{}'::jsonb, v_linguistic, array['linguistic_reviewer']);
  perform public.editorial_apply('approve', v_id, '{}'::jsonb, v_approver, array['approver']);
  perform public.editorial_apply('schedule', v_id, '{}'::jsonb, v_manager, array['editorial_admin']);
  v_rejected := false;
  begin
    perform public.editorial_apply('publish', v_id, '{}'::jsonb, v_manager, array['editorial_admin']);
  exception when insufficient_privilege then
    v_rejected := true;
  end;
  if not v_rejected then raise exception 'La publication JND aurait dû être bloquée.'; end if;
  if (select editorial_status from public.daily_verse_contents where id = v_id) <> 'scheduled' then
    raise exception 'L’échec de publication JND a modifié le statut.';
  end if;

  v_content := public.editorial_apply('create', null, jsonb_build_object(
    'content_date', '2099-02-02', 'slot', 'evening', 'language_code', 'fr',
    'translation_code', 'demo', 'translation_name', 'Démonstration',
    'reference', 'DÉMO 4:1', 'verse_text', 'Contenu fictif.',
    'reflection', 'Réflexion fictive.', 'action', 'Action fictive.',
    'attribution', 'Démonstration uniquement.', 'source_provider', 'demo'
  ), v_author, array['editor']);
  v_id := (v_content->>'id')::uuid;
  perform public.editorial_apply('submit', v_id, '{}'::jsonb, v_author, array['editor']);
  perform public.editorial_apply('biblical_approve', v_id, '{}'::jsonb, v_biblical, array['biblical_reviewer']);
  v_rejected := false;
  begin
    perform public.editorial_apply('request_changes', v_id, '{}'::jsonb, v_linguistic, array['linguistic_reviewer']);
  exception when invalid_parameter_value then
    v_rejected := true;
  end;
  if not v_rejected then raise exception 'Une correction sans motif a été acceptée.'; end if;
  v_content := public.editorial_apply('request_changes', v_id,
    '{"reason":"Réviser le ton"}'::jsonb, v_linguistic, array['linguistic_reviewer']);
  if v_content->>'editorial_status' <> 'draft' or
     v_content->>'biblical_reviewed_by' is not null then
    raise exception 'La demande de correction n’a pas annulé la relecture.';
  end if;
end
$test$;

select 'M1-08 : rôles, transitions, audit et blocage JND validés' as verification_result;
rollback;
