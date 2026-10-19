-- ============================================================================
-- LinguaCE — quota gratuit quotidien pour l'Edge Function `chat` (tâche #7)
-- Appliquer avec :  supabase db push
--
-- La clé anon Supabase est publique → le proxy `chat` était un proxy ouvert :
-- n'importe qui pouvait consommer le crédit API Anthropic. On borne l'usage
-- par un quota quotidien par utilisateur, compté de façon serveur-autoritative.
-- ============================================================================

-- ── Table de comptage (une ligne par utilisateur et par jour UTC) ───────────
create table if not exists public.chat_usage (
  user_id uuid not null references auth.users(id) on delete cascade,
  day     date not null default (now() at time zone 'utc')::date,
  count   integer not null default 0,
  primary key (user_id, day)
);
alter table public.chat_usage enable row level security;

-- Lecture de sa propre conso (pour afficher le reste côté app, optionnel).
drop policy if exists "chat_usage_select_own" on public.chat_usage;
create policy "chat_usage_select_own"
  on public.chat_usage for select using (auth.uid() = user_id);

-- Le client ne peut jamais écrire la table en direct : seule la fonction
-- SECURITY DEFINER ci-dessous l'incrémente.
revoke insert, update, delete on public.chat_usage from anon, authenticated;

-- ── Incrément atomique sous quota ───────────────────────────────────────────
-- Incrémente la conso du jour UNIQUEMENT si elle est encore sous le quota
-- (le `where count < daily_limit` rend le check-and-increment atomique sous
-- le verrou de ligne). Ainsi on ne compte que les requêtes acceptées, pas
-- celles rejetées en 429. « Par jour » = jour calendaire UTC.
create or replace function public.consume_chat_quota(daily_limit integer)
returns table(allowed boolean, used integer, day_limit integer, reset_at timestamptz)
language plpgsql
security definer
set search_path = public
as $$
declare
  uid       uuid := auth.uid();
  today     date := (now() at time zone 'utc')::date;
  new_count integer;
begin
  if uid is null then
    raise exception 'consume_chat_quota: not authenticated';
  end if;

  -- Garantit l'existence de la ligne du jour sans l'incrémenter.
  insert into public.chat_usage (user_id, day, count)
  values (uid, today, 0)
  on conflict (user_id, day) do nothing;

  -- Incrément conditionnel atomique : n'avance que si on est sous le quota.
  update public.chat_usage
  set count = count + 1
  where user_id = uid and day = today and count < daily_limit
  returning count into new_count;

  if new_count is null then
    -- Déjà au plafond : on renvoie la conso courante sans l'incrémenter.
    select count into new_count
    from public.chat_usage where user_id = uid and day = today;
    return query select false, new_count, daily_limit,
      ((today + 1)::timestamp at time zone 'utc');
  else
    return query select true, new_count, daily_limit,
      ((today + 1)::timestamp at time zone 'utc');
  end if;
end;
$$;

revoke all on function public.consume_chat_quota(integer) from public;
grant execute on function public.consume_chat_quota(integer) to authenticated;
