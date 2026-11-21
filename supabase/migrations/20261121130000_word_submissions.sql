-- ============================================================================
-- LinguaCE Core — mots proposés par les utilisateurs
-- Appliquer avec :  supabase db push
--
-- Depuis LinguaCE App (dictionnaire), un utilisateur propose un mot qu'il
-- connaît : forme cyrillique et/ou latine, sens, remarque. Les propositions
-- arrivent en attente ; l'auteur les relit et, s'il les valide, les ajoute au
-- lexique (brouillon puis validé, comme tout mot). Rien n'est suggéré ni
-- affiché aux autres utilisateurs sans cette validation.
--
-- Même modèle que content_reports : insertion pour soi seulement, 30 par jour
-- au plus, lecture de ses propres propositions, aucune modification côté
-- client (le traitement se fait depuis le Core, en rôle de service).
-- ============================================================================

create table if not exists public.word_submissions (
  id             bigint generated always as identity primary key,
  user_id        uuid not null default auth.uid()
                   references auth.users(id) on delete cascade,
  cyrillic       text check (cyrillic is null or char_length(btrim(cyrillic)) between 1 and 80),
  latin          text check (latin is null or char_length(btrim(latin)) between 1 and 80),
  meaning        text not null check (char_length(btrim(meaning)) between 1 and 200),
  meaning_lang   text not null check (meaning_lang in ('FR', 'EN', 'RU', 'CE')),
  note           text check (char_length(note) <= 500),
  status         text not null default 'pending'
                   check (status in ('pending', 'accepted', 'rejected', 'duplicate')),
  created_at     timestamptz not null default now(),
  constraint word_submissions_has_form check (cyrillic is not null or latin is not null)
);

create index if not exists word_submissions_status_idx
  on public.word_submissions (status, created_at desc);
create index if not exists word_submissions_user_day_idx
  on public.word_submissions (user_id, created_at);

alter table public.word_submissions enable row level security;

drop policy if exists "word_submissions_insert_own" on public.word_submissions;
create policy "word_submissions_insert_own"
  on public.word_submissions for insert to authenticated
  with check (
    user_id = auth.uid()
    and status = 'pending'
    and (
      select count(*) from public.word_submissions s
      where s.user_id = auth.uid()
        and s.created_at > now() - interval '1 day'
    ) < 30
  );

drop policy if exists "word_submissions_select_own" on public.word_submissions;
create policy "word_submissions_select_own"
  on public.word_submissions for select to authenticated
  using (user_id = auth.uid());

revoke all on public.word_submissions from anon, authenticated;
grant select, insert on public.word_submissions to authenticated;
