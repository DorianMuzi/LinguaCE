-- ============================================================================
-- LinguaCE — XP / niveau / ligue autoritatifs côté serveur (tâche #8)
-- Appliquer avec :  supabase db push
--
-- Avant : la policy profiles_update_own laissait le client écrire n'importe
-- quelle colonne de sa ligne, xp/level/league comprises → classement
-- falsifiable (UPDATE profiles SET xp = 999999).
--
-- Après : seule la fonction award_xp() (SECURITY DEFINER) peut toucher
-- xp/level/league ; le client ne garde l'écriture que des colonnes neutres.
-- ============================================================================

-- ── Fonction d'attribution d'XP (serveur-autoritative) ──────────────────────
-- Insère l'événement d'XP, incrémente le total, recalcule niveau + ligue et
-- l'horodatage d'activité, le tout dans une seule transaction. Le barème est
-- identique à l'ancien calcul client (ProfileService.leagueForXp / level).
create or replace function public.award_xp(amount integer)
returns public.profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  uid    uuid := auth.uid();
  result public.profiles;
begin
  if uid is null then
    raise exception 'award_xp: not authenticated';
  end if;
  -- Borne serveur : on ne fait jamais confiance à la valeur du client.
  if amount is null or amount < 0 or amount > 1000 then
    raise exception 'award_xp: invalid amount (%).', amount;
  end if;

  insert into public.xp_events (user_id, amount) values (uid, amount);

  update public.profiles p
  set xp            = p.xp + amount,
      level         = ((p.xp + amount) / 1000) + 1,
      league        = case
                        when (p.xp + amount) >= 15000 then 'noxco'
                        when (p.xp + amount) >= 7000  then 'eagle'
                        when (p.xp + amount) >= 3000  then 'mountain'
                        when (p.xp + amount) >= 1000  then 'forest'
                        else 'stone'
                      end,
      last_activity = now()
  where p.id = uid
  returning p.* into result;

  return result;
end;
$$;

-- Seuls les utilisateurs authentifiés peuvent l'appeler (pas anon).
revoke all on function public.award_xp(integer) from public;
grant execute on function public.award_xp(integer) to authenticated;

-- ── Verrouillage des colonnes de progression ────────────────────────────────
-- On retire l'UPDATE large (hérité de « grant all ») puis on ré-accorde
-- l'écriture uniquement sur les colonnes neutres. xp / level / league ne sont
-- plus modifiables par le client — seule award_xp() (SECURITY DEFINER) le peut.
revoke update on public.profiles from anon, authenticated;
grant update (username, interface_language, streak, lessons_completed, last_activity)
  on public.profiles to anon, authenticated;
