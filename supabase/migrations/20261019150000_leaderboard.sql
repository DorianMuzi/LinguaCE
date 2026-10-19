-- ============================================================================
-- LinguaCE — classement : index + fonction en un seul aller-retour (tâche #9)
-- Appliquer avec :  supabase db push
--
-- Avant : fetchLeaderboard faisait un SELECT trié sur profiles.xp (top 20) puis,
-- si l'utilisateur n'y figurait pas, une SECONDE requête COUNT(*) WHERE xp > moi
-- pour son rang — sans aucun index sur xp (tri et comptage scannaient la table),
-- et sans règle de départage des ex æquo (deux joueurs à égalité pouvaient
-- changer de rang d'un appel à l'autre).
-- ============================================================================

-- Index qui sert à la fois au tri du top N et au comptage du rang.
-- Le départage des ex æquo est (xp décroissant, id croissant) : déterministe,
-- sans NULL possible (contrairement à created_at, nullable).
create index if not exists profiles_xp_id_idx
  on public.profiles (xp desc, id asc);

-- Top N + ligne de l'appelant (avec son VRAI rang) s'il n'est pas dans le top,
-- en un seul appel. SECURITY INVOKER (défaut) : la visibilité reste régie par la
-- RLS de profiles (profiles_select_all : tout utilisateur authentifié lit le
-- classement ; anon ne voit rien).
create or replace function public.get_leaderboard(p_limit integer default 20)
returns table (
  rank     bigint,
  user_id  uuid,
  username text,
  xp       integer,
  is_me    boolean
)
language sql
stable
set search_path = public
as $$
  with top as (
    select p.id, p.username, p.xp,
           row_number() over (order by p.xp desc, p.id asc) as rnk
    from public.profiles p
    order by p.xp desc, p.id asc
    -- Borne serveur : jamais plus de 100 lignes, quoi que demande le client.
    limit least(greatest(coalesce(p_limit, 20), 1), 100)
  ),
  me as (
    select p.id, p.username, p.xp,
           -- Rang = nombre de profils classés avant moi + 1 (même règle de
           -- départage que ci-dessus), calculé via l'index (xp desc, id asc).
           (select count(*)
              from public.profiles o
             where o.xp > p.xp
                or (o.xp = p.xp and o.id < p.id)) + 1 as rnk
    from public.profiles p
    where p.id = auth.uid()
      and not exists (select 1 from top t where t.id = p.id)
  )
  select t.rnk, t.id, t.username, t.xp, (t.id = auth.uid())
  from top t
  union all
  select m.rnk, m.id, m.username, m.xp, true
  from me m
  order by 1;
$$;

revoke all on function public.get_leaderboard(integer) from public, anon;
grant execute on function public.get_leaderboard(integer) to authenticated;
