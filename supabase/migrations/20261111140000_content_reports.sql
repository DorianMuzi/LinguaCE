-- ============================================================================
-- LinguaCE — signalements d'erreurs de contenu
-- Appliquer avec :  supabase db push
--
-- Depuis une leçon, l'apprenant signale une translittération ou une traduction
-- fautive. Le mainteneur les lit dans le tableau de bord Supabase (Table
-- editor → content_reports) ; la colonne `status` sert au suivi.
--
-- On enregistre un INSTANTANÉ de l'exercice (leçon, position, cyrillique,
-- latin, français) : le signalement reste lisible même après correction.
-- ============================================================================

create table if not exists public.content_reports (
  id                 bigint generated always as identity primary key,
  user_id            uuid not null default auth.uid()
                       references auth.users(id) on delete cascade,
  lesson_id          text references public.lessons(id) on delete set null,
  exercise_position  integer check (exercise_position between 1 and 1000),
  exercise_type      text check (char_length(exercise_type) <= 20),
  cyrillic           text check (char_length(cyrillic) <= 500),
  translit           text check (char_length(translit) <= 500),
  french             text check (char_length(french) <= 500),
  category           text not null
                       check (category in ('translit', 'translation', 'other')),
  comment            text check (char_length(comment) <= 1000),
  interface_language text check (char_length(interface_language) <= 8),
  status             text not null default 'new'
                       check (status in ('new', 'reviewed', 'fixed', 'rejected')),
  created_at         timestamptz not null default now()
);

create index if not exists content_reports_status_idx
  on public.content_reports (status, created_at desc);
create index if not exists content_reports_user_day_idx
  on public.content_reports (user_id, created_at);

alter table public.content_reports enable row level security;

-- Insertion : pour soi uniquement, au statut « new », et au plus 30 par jour
-- (anti-spam serveur, le client ne peut pas le contourner).
drop policy if exists "content_reports_insert_own" on public.content_reports;
create policy "content_reports_insert_own"
  on public.content_reports for insert to authenticated
  with check (
    user_id = auth.uid()
    and status = 'new'
    and (
      select count(*) from public.content_reports r
      where r.user_id = auth.uid()
        and r.created_at > now() - interval '1 day'
    ) < 30
  );

-- Lecture : ses propres signalements seulement (jamais ceux des autres).
drop policy if exists "content_reports_select_own" on public.content_reports;
create policy "content_reports_select_own"
  on public.content_reports for select to authenticated
  using (user_id = auth.uid());

-- Les privilèges par défaut du schéma donnent tout à anon/authenticated :
-- on les restreint. Aucune modification ni suppression côté client (le
-- traitement se fait depuis le tableau de bord, en rôle de service).
revoke all on public.content_reports from anon, authenticated;
grant select, insert on public.content_reports to authenticated;
