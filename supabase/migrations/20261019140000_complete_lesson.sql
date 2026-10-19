-- ============================================================================
-- LinguaCE — fin de leçon atomique et XP sans montant client (suite de #8)
-- Appliquer avec :  supabase db push
--
-- Problème de la migration secure_xp : award_xp(amount) acceptait un montant
-- choisi par le client (plafonné à 1000). Un utilisateur connecté pouvait donc
-- l'appeler en boucle et gonfler son XP à volonté. De plus, la fin de leçon
-- était écrite en plusieurs requêtes client : un échec au milieu laissait la
-- leçon « terminée » sans XP, et aucune relance ne rattrapait l'XP.
--
-- Maintenant : complete_lesson(lesson_id) fait tout, côté serveur, en UNE
-- transaction — marque la leçon terminée, crédite lessons.xp_reward UNE seule
-- fois, recalcule niveau/ligue et le compteur de leçons. Le client n'envoie
-- plus aucun montant, et un échec laisse la base inchangée (relance sûre).
-- ============================================================================

-- ── Interne : application de l'XP (jamais appelable par un client) ──────────
create or replace function public.grant_xp(p_user uuid, p_amount integer)
returns public.profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  result public.profiles;
begin
  if p_amount is null or p_amount < 0 then
    raise exception 'grant_xp: invalid amount (%)', p_amount;
  end if;

  insert into public.xp_events (user_id, amount) values (p_user, p_amount);

  update public.profiles p
  set xp            = p.xp + p_amount,
      level         = ((p.xp + p_amount) / 1000) + 1,
      league        = case
                        when (p.xp + p_amount) >= 15000 then 'noxco'
                        when (p.xp + p_amount) >= 7000  then 'eagle'
                        when (p.xp + p_amount) >= 3000  then 'mountain'
                        when (p.xp + p_amount) >= 1000  then 'forest'
                        else 'stone'
                      end,
      last_activity = now()
  where p.id = p_user
  returning p.* into result;

  if result.id is null then
    raise exception 'grant_xp: no profile for user %', p_user;
  end if;

  return result;
end;
$$;

revoke all on function public.grant_xp(uuid, integer) from public, anon, authenticated;

-- ── Fin de leçon : atomique, idempotente, montant fixé par le serveur ───────
create or replace function public.complete_lesson(p_lesson_id text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid     uuid := auth.uid();
  lesson  public.lessons;
  newly   boolean;
  prof    public.profiles;
  awarded integer := 0;
begin
  if uid is null then
    raise exception 'complete_lesson: not authenticated';
  end if;

  select * into lesson from public.lessons where id = p_lesson_id;
  if not found then
    raise exception 'complete_lesson: unknown lesson %', p_lesson_id;
  end if;

  -- Marque la leçon terminée. Le « where completed = false » rend l'opération
  -- atomique : seule la PREMIÈRE complétion renvoie une ligne (donc crédite).
  insert into public.lesson_progress
    (user_id, lesson_id, completed_exercises, completed, updated_at)
  values (uid, p_lesson_id, lesson.total_exercises, true, now())
  on conflict (user_id, lesson_id) do update
    set completed           = true,
        completed_exercises = excluded.completed_exercises,
        updated_at          = now()
    where public.lesson_progress.completed = false
  returning true into newly;

  if newly is true then
    awarded := lesson.xp_reward;
    prof := public.grant_xp(uid, awarded);
  else
    select * into prof from public.profiles where id = uid;
  end if;

  update public.profiles
  set lessons_completed = (
    select count(*)::integer
    from public.lesson_progress
    where user_id = uid and completed
  )
  where id = uid;

  return jsonb_build_object(
    'xp_awarded',        awarded,
    'already_completed', newly is not true,
    'xp',                prof.xp,
    'level',             prof.level,
    'league',            prof.league
  );
end;
$$;

revoke all on function public.complete_lesson(text) from public, anon;
grant execute on function public.complete_lesson(text) to authenticated;

-- ── Nettoyage : l'ancienne RPC à montant libre disparaît ────────────────────
drop function if exists public.award_xp(integer);

-- Le compteur de leçons terminées est désormais écrit par complete_lesson :
-- le client ne peut plus le modifier lui-même.
revoke update (lessons_completed) on public.profiles from anon, authenticated;
