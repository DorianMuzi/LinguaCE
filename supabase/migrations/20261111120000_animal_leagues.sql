-- ============================================================================
-- LinguaCE — ligues du design system : animaux totems
-- Appliquer avec :  supabase db push
--
-- Pierre → Forêt → Montagne → Aigle → Noxço  devient
-- Loup   → Aigle → Mouflon  → Cheval → Faucon  (paliers d'XP inchangés).
-- Le barème DOIT rester identique à ProfileService.leagueForXp côté client.
-- ============================================================================

-- ── grant_xp : même fonction, nouvelles clés de ligue ───────────────────────
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
                        when (p.xp + p_amount) >= 15000 then 'faucon'
                        when (p.xp + p_amount) >= 7000  then 'cheval'
                        when (p.xp + p_amount) >= 3000  then 'mouflon'
                        when (p.xp + p_amount) >= 1000  then 'aigle'
                        else 'loup'
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

-- `create or replace` conserve les privilèges, mais on réaffirme la règle :
-- grant_xp reste interne, jamais appelable par un client.
revoke all on function public.grant_xp(uuid, integer) from public, anon, authenticated;

-- ── Profils existants : ligue recalculée depuis l'XP (source de vérité) ─────
-- Couvre d'un coup les anciennes clés (stone/forest/…) et les noms hérités
-- (Aigle/Argent/Or/Diamant), plutôt que de les traduire un par un.
update public.profiles
set league = case
               when xp >= 15000 then 'faucon'
               when xp >= 7000  then 'cheval'
               when xp >= 3000  then 'mouflon'
               when xp >= 1000  then 'aigle'
               else 'loup'
             end;

-- ── Valeur par défaut d'un nouveau profil ───────────────────────────────────
alter table public.profiles alter column league set default 'loup';
