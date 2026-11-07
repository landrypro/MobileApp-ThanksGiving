-- M1-08 : circuit editorial transactionnel. Le texte JND ne peut pas etre publie
-- tant que sa licence n'est pas confirmee et encodee dans une migration future.
alter table public.daily_verse_contents
  drop constraint daily_verse_contents_editorial_status_check;

alter table public.daily_verse_contents
  add constraint daily_verse_contents_editorial_status_check check (
    editorial_status in (
      'draft', 'biblical_review', 'linguistic_review', 'approval_review',
      'approved', 'scheduled', 'published', 'withdrawn'
    )
  ),
  add column created_by uuid,
  add column biblical_reviewed_by uuid,
  add column linguistic_reviewed_by uuid,
  add column approved_by uuid,
  add column scheduled_at timestamptz;

create table public.editorial_events (
  id uuid primary key default gen_random_uuid(),
  content_id uuid not null references public.daily_verse_contents(id) on delete restrict,
  actor_id uuid not null,
  action text not null,
  from_status text,
  to_status text not null,
  reason text,
  occurred_at timestamptz not null default now()
);

create index editorial_events_content_time_idx
  on public.editorial_events (content_id, occurred_at desc);

alter table public.editorial_events enable row level security;
alter table public.editorial_events force row level security;
revoke all on table public.editorial_events from anon, authenticated;
grant select, insert on table public.editorial_events to service_role;

-- Seul le role serveur peut invoquer cette fonction. L'Edge Function authentifie
-- l'utilisateur et transmet ses roles depuis app_metadata, jamais user_metadata.
create function public.editorial_apply(
  p_action text,
  p_content_id uuid,
  p_payload jsonb,
  p_actor_id uuid,
  p_actor_roles text[]
) returns jsonb
language plpgsql
security invoker
set search_path = public, pg_temp
as $function$
declare
  v_row public.daily_verse_contents%rowtype;
  v_before text;
  v_reason text;
  v_is_manager boolean;
begin
  if p_actor_id is null or p_actor_roles is null then
    raise exception 'editorial_actor_required' using errcode = '22023';
  end if;
  if p_payload is null or jsonb_typeof(p_payload) <> 'object' then
    raise exception 'editorial_payload_invalid' using errcode = '22023';
  end if;
  v_is_manager := p_actor_roles && array['admin', 'editorial_admin'];
  v_reason := nullif(btrim(p_payload->>'reason'), '');

  if p_action = 'create' then
    if not (v_is_manager or 'editor' = any(p_actor_roles)) then
      raise exception 'editorial_role_required' using errcode = '42501';
    end if;
    if p_content_id is not null then
      raise exception 'new_content_id_must_be_null' using errcode = '22023';
    end if;
    insert into public.daily_verse_contents (
      content_date, slot, language_code, translation_code, translation_name,
      reference, verse_text, reflection, action, prayer, attribution,
      source_provider, source_bible_id, source_passage_id, created_by
    ) values (
      (p_payload->>'content_date')::date,
      p_payload->>'slot',
      p_payload->>'language_code',
      p_payload->>'translation_code',
      p_payload->>'translation_name',
      p_payload->>'reference',
      p_payload->>'verse_text',
      p_payload->>'reflection',
      p_payload->>'action',
      nullif(btrim(p_payload->>'prayer'), ''),
      p_payload->>'attribution',
      coalesce(nullif(btrim(p_payload->>'source_provider'), ''), 'demo'),
      nullif(btrim(p_payload->>'source_bible_id'), ''),
      nullif(btrim(p_payload->>'source_passage_id'), ''),
      p_actor_id
    ) returning * into v_row;
  else
    if p_content_id is null then
      raise exception 'content_id_required' using errcode = '22023';
    end if;
    select * into v_row
      from public.daily_verse_contents
      where id = p_content_id
      for update;
    if not found then
      raise exception 'content_not_found' using errcode = 'P0002';
    end if;
    v_before := v_row.editorial_status;

    if p_action = 'edit' then
      if v_before <> 'draft' or not (
        v_is_manager or
        ('editor' = any(p_actor_roles) and v_row.created_by = p_actor_id)
      ) then
        raise exception 'draft_owner_required' using errcode = '42501';
      end if;
      update public.daily_verse_contents set
        content_date = coalesce((p_payload->>'content_date')::date, content_date),
        slot = coalesce(p_payload->>'slot', slot),
        language_code = coalesce(p_payload->>'language_code', language_code),
        translation_code = coalesce(p_payload->>'translation_code', translation_code),
        translation_name = coalesce(p_payload->>'translation_name', translation_name),
        reference = coalesce(p_payload->>'reference', reference),
        verse_text = coalesce(p_payload->>'verse_text', verse_text),
        reflection = coalesce(p_payload->>'reflection', reflection),
        action = coalesce(p_payload->>'action', action),
        prayer = case when p_payload ? 'prayer'
          then nullif(btrim(p_payload->>'prayer'), '') else prayer end,
        attribution = coalesce(p_payload->>'attribution', attribution),
        source_provider = coalesce(p_payload->>'source_provider', source_provider),
        source_bible_id = case when p_payload ? 'source_bible_id'
          then nullif(btrim(p_payload->>'source_bible_id'), '') else source_bible_id end,
        source_passage_id = case when p_payload ? 'source_passage_id'
          then nullif(btrim(p_payload->>'source_passage_id'), '') else source_passage_id end,
        biblical_reviewed_by = null,
        linguistic_reviewed_by = null,
        approved_by = null,
        updated_at = now()
      where id = p_content_id returning * into v_row;
    elsif p_action = 'submit' then
      if v_before <> 'draft' or not (
        v_is_manager or
        ('editor' = any(p_actor_roles) and v_row.created_by = p_actor_id)
      ) then
        raise exception 'draft_owner_required' using errcode = '42501';
      end if;
      update public.daily_verse_contents
        set editorial_status = 'biblical_review', updated_at = now()
        where id = p_content_id returning * into v_row;
    elsif p_action = 'biblical_approve' then
      if v_before <> 'biblical_review' or
         not (v_is_manager or 'biblical_reviewer' = any(p_actor_roles)) or
         v_row.created_by = p_actor_id then
        raise exception 'biblical_reviewer_required' using errcode = '42501';
      end if;
      update public.daily_verse_contents
        set editorial_status = 'linguistic_review',
            biblical_reviewed_by = p_actor_id, updated_at = now()
        where id = p_content_id returning * into v_row;
    elsif p_action = 'linguistic_approve' then
      if v_before <> 'linguistic_review' or
         not (v_is_manager or 'linguistic_reviewer' = any(p_actor_roles)) or
         p_actor_id in (v_row.created_by, v_row.biblical_reviewed_by) then
        raise exception 'linguistic_reviewer_required' using errcode = '42501';
      end if;
      update public.daily_verse_contents
        set editorial_status = 'approval_review',
            linguistic_reviewed_by = p_actor_id, updated_at = now()
        where id = p_content_id returning * into v_row;
    elsif p_action = 'approve' then
      if v_before <> 'approval_review' or
         not (v_is_manager or 'approver' = any(p_actor_roles)) or
         p_actor_id in (
           v_row.created_by, v_row.biblical_reviewed_by,
           v_row.linguistic_reviewed_by
         ) then
        raise exception 'independent_approver_required' using errcode = '42501';
      end if;
      update public.daily_verse_contents
        set editorial_status = 'approved', approved_by = p_actor_id,
            updated_at = now()
        where id = p_content_id returning * into v_row;
    elsif p_action = 'schedule' then
      if v_before <> 'approved' or not v_is_manager then
        raise exception 'editorial_manager_required' using errcode = '42501';
      end if;
      update public.daily_verse_contents
        set editorial_status = 'scheduled', scheduled_at = now(),
            updated_at = now()
        where id = p_content_id returning * into v_row;
    elsif p_action = 'publish' then
      if v_before <> 'scheduled' or not v_is_manager then
        raise exception 'editorial_manager_required' using errcode = '42501';
      end if;
      -- Verrou volontaire : aucun texte biblique reel, dont JND, ne sort avant
      -- une decision de droits et une migration qui remplacera cette condition.
      if v_row.translation_code <> 'demo' or v_row.source_provider <> 'demo' then
        raise exception 'publication_rights_pending' using errcode = '42501';
      end if;
      update public.daily_verse_contents
        set editorial_status = 'published', published_at = now(),
            updated_at = now()
        where id = p_content_id returning * into v_row;
    elsif p_action = 'withdraw' then
      if v_before not in ('scheduled', 'published') or not v_is_manager or
         v_reason is null then
        raise exception 'withdrawal_reason_and_manager_required' using errcode = '42501';
      end if;
      update public.daily_verse_contents
        set editorial_status = 'withdrawn', withdrawn_at = now(),
            updated_at = now()
        where id = p_content_id returning * into v_row;
    elsif p_action = 'request_changes' then
      if v_reason is null then
        raise exception 'review_reason_required' using errcode = '22023';
      end if;
      if not (
        (v_before = 'biblical_review' and
          (v_is_manager or 'biblical_reviewer' = any(p_actor_roles))) or
        (v_before = 'linguistic_review' and
          (v_is_manager or 'linguistic_reviewer' = any(p_actor_roles))) or
        (v_before = 'approval_review' and
          (v_is_manager or 'approver' = any(p_actor_roles)))
      ) then
        raise exception 'reviewer_required' using errcode = '42501';
      end if;
      update public.daily_verse_contents
        set editorial_status = 'draft', biblical_reviewed_by = null,
            linguistic_reviewed_by = null, approved_by = null,
            updated_at = now()
        where id = p_content_id returning * into v_row;
    else
      raise exception 'unknown_editorial_action' using errcode = '22023';
    end if;
  end if;

  insert into public.editorial_events (
    content_id, actor_id, action, from_status, to_status, reason
  ) values (
    v_row.id, p_actor_id, p_action, v_before, v_row.editorial_status, v_reason
  );
  return to_jsonb(v_row);
end
$function$;

revoke all on function public.editorial_apply(text, uuid, jsonb, uuid, text[])
  from public, anon, authenticated;
grant execute on function public.editorial_apply(text, uuid, jsonb, uuid, text[])
  to service_role;
