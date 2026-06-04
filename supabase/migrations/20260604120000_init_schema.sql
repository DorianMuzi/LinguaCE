-- ============================================================================
-- LinguaCE — schéma de base de données complet
-- Appliquer avec :  supabase db push
-- Idempotent : peut être ré-exécuté sans danger.
-- ============================================================================

-- ── Profils ─────────────────────────────────────────────────────────────────
create table if not exists public.profiles (
  id                 uuid primary key references auth.users(id) on delete cascade,
  username           text not null,
  xp                 integer not null default 0,
  level              integer not null default 1,
  streak             integer not null default 0,
  lessons_completed  integer not null default 0,
  league             text not null default 'Aigle',
  interface_language text not null default 'FR',
  last_activity      timestamptz,
  created_at         timestamptz default now()
);
alter table public.profiles enable row level security;

drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own"
  on public.profiles for select using (auth.uid() = id);

-- Classement : profils lisibles par tout utilisateur authentifié.
drop policy if exists "profiles_select_all" on public.profiles;
create policy "profiles_select_all"
  on public.profiles for select to authenticated using (true);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own"
  on public.profiles for update using (auth.uid() = id);

drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own"
  on public.profiles for insert with check (auth.uid() = id);

-- ── Messages de chat ────────────────────────────────────────────────────────
create table if not exists public.chat_messages (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references auth.users(id) on delete cascade,
  role       text not null check (role in ('user', 'assistant')),
  content    text not null,
  created_at timestamptz default now()
);
alter table public.chat_messages enable row level security;

drop policy if exists "chat_select_own" on public.chat_messages;
create policy "chat_select_own"
  on public.chat_messages for select using (auth.uid() = user_id);

drop policy if exists "chat_insert_own" on public.chat_messages;
create policy "chat_insert_own"
  on public.chat_messages for insert with check (auth.uid() = user_id);

drop policy if exists "chat_delete_own" on public.chat_messages;
create policy "chat_delete_own"
  on public.chat_messages for delete using (auth.uid() = user_id);

-- ── Leçons (catalogue) ──────────────────────────────────────────────────────
create table if not exists public.lessons (
  id              text primary key,
  title           text not null,
  subtitle        text not null,
  icon            text not null,
  xp_reward       integer not null default 50,
  total_exercises integer not null default 6,
  sort_order      integer not null default 0
);
alter table public.lessons enable row level security;

drop policy if exists "lessons_select_auth" on public.lessons;
create policy "lessons_select_auth"
  on public.lessons for select to authenticated using (true);

-- ── Progression par utilisateur ─────────────────────────────────────────────
create table if not exists public.lesson_progress (
  user_id             uuid not null references auth.users(id) on delete cascade,
  lesson_id           text not null references public.lessons(id) on delete cascade,
  completed_exercises integer not null default 0,
  completed           boolean not null default false,
  updated_at          timestamptz default now(),
  primary key (user_id, lesson_id)
);
alter table public.lesson_progress enable row level security;

drop policy if exists "lesson_progress_select_own" on public.lesson_progress;
create policy "lesson_progress_select_own"
  on public.lesson_progress for select using (auth.uid() = user_id);

drop policy if exists "lesson_progress_all_own" on public.lesson_progress;
create policy "lesson_progress_all_own"
  on public.lesson_progress for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- ── Gamification : journal d'XP (graphique hebdomadaire) ────────────────────
create table if not exists public.xp_events (
  id         bigint generated always as identity primary key,
  user_id    uuid not null references auth.users(id) on delete cascade,
  amount     integer not null,
  created_at timestamptz default now()
);
alter table public.xp_events enable row level security;

drop policy if exists "xp_events_select_own" on public.xp_events;
create policy "xp_events_select_own"
  on public.xp_events for select using (auth.uid() = user_id);

drop policy if exists "xp_events_insert_own" on public.xp_events;
create policy "xp_events_insert_own"
  on public.xp_events for insert with check (auth.uid() = user_id);

create index if not exists xp_events_user_date
  on public.xp_events (user_id, created_at);

-- ── Privilèges de table (les politiques RLS filtrent les lignes) ────────────
grant usage on schema public to anon, authenticated;
grant all on all tables in schema public to anon, authenticated;
grant all on all sequences in schema public to anon, authenticated;
alter default privileges in schema public
  grant all on tables to anon, authenticated;
alter default privileges in schema public
  grant all on sequences to anon, authenticated;

-- ── Données initiales : catalogue de leçons ─────────────────────────────────
insert into public.lessons (id, title, subtitle, icon, xp_reward, total_exercises, sort_order) values
  ('1', 'Premiers Mots',      'Vocabulaire de base',   '🌱',       100, 6, 1),
  ('2', 'Salutations',        'Bonjour, au revoir...', '👋',       150, 6, 2),
  ('3', 'Chiffres & Nombres', 'De 1 à 100',            '🔢',       200, 6, 3),
  ('4', 'La Famille',         'Mère, père, frère...',  '👨‍👩‍👧', 250, 6, 4)
on conflict (id) do nothing;
