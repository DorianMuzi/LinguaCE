-- ============================================================================
-- LinguaCE Core — prononciations natives du lexique (amorce de LinguaCE Voice)
-- Appliquer avec :  supabase db push
--
-- Des locuteurs natifs (« enregistreurs ») enregistrent les mots validés
-- depuis l'écran Studio de l'app. Chaque prise est conservée (corpus de
-- LinguaCE Voice) ; une seule est « active » par mot et alimente
-- `lexemes.audio_url`.
--
-- Fichiers : bucket `lexeme-audio`, WAV mono 16 bits, chemin
-- « <lexeme_id>/<horodatage>.wav ». `lexemes.audio_url` contient ce CHEMIN ;
-- l'app en déduit l'URL publique.
--
-- ⚠️ Structure uniquement : la liste des enregistreurs (et leur
-- consentement) vit dans le dépôt privé `linguace-core`.
-- ============================================================================

-- ── Enregistreurs ───────────────────────────────────────────────────────────
-- Seules ces personnes peuvent déposer une prononciation. Le consentement
-- (version du texte accepté + date) est obligatoire : les voix forment le
-- futur corpus de LinguaCE Voice.
create table if not exists public.recorders (
  user_id          uuid primary key references auth.users (id) on delete cascade,
  display_name     text not null check (btrim(display_name) <> ''),
  consent_version  text not null check (btrim(consent_version) <> ''),
  consent_at       timestamptz not null default now(),
  active           boolean not null default true,
  created_at       timestamptz not null default now()
);

alter table public.recorders enable row level security;
-- Aucune lecture directe : les apps passent par is_recorder().
revoke all on public.recorders from anon, authenticated;

-- ── Prises ──────────────────────────────────────────────────────────────────
create table if not exists public.lexeme_recordings (
  id            bigint generated always as identity primary key,
  lexeme_id     bigint not null references public.lexemes (id) on delete cascade,
  recorder_id   uuid not null references public.recorders (user_id),
  storage_path  text not null unique,
  duration_ms   integer not null check (duration_ms between 1 and 15000),
  status        text not null default 'active'
                check (status in ('active', 'superseded', 'rejected')),
  created_at    timestamptz not null default now()
);

create index if not exists lexeme_recordings_lexeme
  on public.lexeme_recordings (lexeme_id);
-- Une seule prise active par mot.
create unique index if not exists lexeme_recordings_one_active
  on public.lexeme_recordings (lexeme_id) where status = 'active';

alter table public.lexeme_recordings enable row level security;
revoke all on public.lexeme_recordings from anon, authenticated;

-- ── Fonctions ───────────────────────────────────────────────────────────────
create or replace function public.is_recorder()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.recorders
     where user_id = auth.uid() and active
  );
$$;

revoke all on function public.is_recorder() from public, anon;
grant execute on function public.is_recorder() to authenticated;

-- Enregistre une prise déjà déposée dans le bucket, la rend active et met
-- à jour le mot. Vérifie : enregistreur actif, mot validé, chemin attendu,
-- fichier réellement présent.
create or replace function public.add_lexeme_recording(
  p_lexeme_id   bigint,
  p_path        text,
  p_duration_ms integer
)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id bigint;
begin
  if not public.is_recorder() then
    raise exception 'not a recorder' using errcode = '42501';
  end if;

  if not exists (select 1 from public.lexemes
                  where id = p_lexeme_id and status = 'validated') then
    raise exception 'unknown lexeme %', p_lexeme_id using errcode = 'P0002';
  end if;

  if p_path !~ ('^' || p_lexeme_id || '/[A-Za-z0-9_-]+\.wav$') then
    raise exception 'unexpected path %', p_path using errcode = '22023';
  end if;

  if not exists (select 1 from storage.objects
                  where bucket_id = 'lexeme-audio' and name = p_path) then
    raise exception 'file not uploaded: %', p_path using errcode = 'P0002';
  end if;

  update public.lexeme_recordings
     set status = 'superseded'
   where lexeme_id = p_lexeme_id and status = 'active';

  insert into public.lexeme_recordings
    (lexeme_id, recorder_id, storage_path, duration_ms)
  values
    (p_lexeme_id, auth.uid(), p_path, p_duration_ms)
  returning id into v_id;

  update public.lexemes set audio_url = p_path where id = p_lexeme_id;

  return v_id;
end
$$;

revoke all on function public.add_lexeme_recording(bigint, text, integer)
  from public, anon;
grant execute on function public.add_lexeme_recording(bigint, text, integer)
  to authenticated;

-- ── Stockage ────────────────────────────────────────────────────────────────
-- Lecture publique par URL (les apps jouent le son sans jeton) ; pas de
-- politique SELECT, donc pas de listage du bucket. Dépôt : enregistreurs
-- uniquement, WAV ≤ 2 Mo (~11 s en 44,1 kHz mono).
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('lexeme-audio', 'lexeme-audio', true, 2097152,
        array['audio/wav', 'audio/x-wav'])
on conflict (id) do update
  set public             = excluded.public,
      file_size_limit    = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "lexeme_audio_insert_recorders" on storage.objects;
create policy "lexeme_audio_insert_recorders"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'lexeme-audio' and public.is_recorder());
