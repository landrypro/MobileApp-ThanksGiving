create table public.daily_verse_contents (
  id uuid primary key default gen_random_uuid(),
  content_date date not null,
  slot text not null
    constraint daily_verse_contents_slot_check
    check (slot in ('morning', 'midday', 'evening')),
  language_code text not null
    constraint daily_verse_contents_language_code_check
    check (language_code ~ '^[a-z]{2,3}(-[A-Z]{2})?$'),
  translation_code text not null
    constraint daily_verse_contents_translation_code_check
    check (translation_code ~ '^[a-z0-9][a-z0-9_-]{1,49}$'),
  translation_name text not null
    constraint daily_verse_contents_translation_name_check
    check (btrim(translation_name) <> ''),
  reference text not null
    constraint daily_verse_contents_reference_check
    check (btrim(reference) <> ''),
  verse_text text not null
    constraint daily_verse_contents_verse_text_check
    check (btrim(verse_text) <> ''),
  reflection text not null
    constraint daily_verse_contents_reflection_check
    check (btrim(reflection) <> ''),
  action text not null
    constraint daily_verse_contents_action_check
    check (btrim(action) <> ''),
  prayer text
    constraint daily_verse_contents_prayer_check
    check (prayer is null or btrim(prayer) <> ''),
  attribution text not null
    constraint daily_verse_contents_attribution_check
    check (btrim(attribution) <> ''),
  editorial_status text not null default 'draft'
    constraint daily_verse_contents_editorial_status_check
    check (
      editorial_status in (
        'draft',
        'biblical_review',
        'linguistic_review',
        'approved',
        'scheduled',
        'published',
        'withdrawn'
      )
    ),
  version integer not null default 1
    constraint daily_verse_contents_version_check
    check (version > 0),
  source_provider text not null default 'api.bible'
    constraint daily_verse_contents_source_provider_check
    check (btrim(source_provider) <> ''),
  source_bible_id text,
  source_passage_id text,
  published_at timestamptz,
  withdrawn_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint daily_verse_contents_revision_unique unique (
    content_date,
    slot,
    language_code,
    translation_code,
    version
  ),
  constraint daily_verse_contents_publication_dates_check check (
    (editorial_status <> 'published' or published_at is not null)
    and (editorial_status <> 'withdrawn' or withdrawn_at is not null)
  ),
  constraint daily_verse_contents_updated_after_created_check check (
    updated_at >= created_at
  )
);

comment on table public.daily_verse_contents is
  'Révisions éditoriales des trois rendez-vous bibliques quotidiens.';
comment on column public.daily_verse_contents.version is
  'Version positive au sein de la clé date + créneau + langue + traduction.';
comment on column public.daily_verse_contents.source_bible_id is
  'Identifiant de traduction fourni par la source biblique, jamais une clé API.';

create index daily_verse_contents_delivery_lookup_idx
  on public.daily_verse_contents (
    content_date,
    language_code,
    translation_code,
    editorial_status,
    slot
  );

create unique index daily_verse_contents_one_live_revision_idx
  on public.daily_verse_contents (
    content_date,
    slot,
    language_code,
    translation_code
  )
  where editorial_status in ('scheduled', 'published');

alter table public.daily_verse_contents enable row level security;
alter table public.daily_verse_contents force row level security;

revoke all on table public.daily_verse_contents from anon, authenticated;
grant select, insert, update, delete on table public.daily_verse_contents to service_role;

