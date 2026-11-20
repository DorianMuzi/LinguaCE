-- ============================================================================
-- LinguaCE Core v0 — exercices reliés au lexique
-- Appliquer avec :  supabase db push
--
-- Chaque exercice pointe vers le mot du lexique qu'il fait travailler.
-- Une correction faite UNE fois dans `lexemes` (cyrillique ou latin) se
-- propage aux exercices liés, en gardant leur majuscule initiale
-- (« barkalla » dans le lexique, « Barkalla » dans une flashcard).
--
-- Limite volontaire : les consignes et les choix de QCM qui CITENT le mot ne
-- sont pas réécrits automatiquement (un remplacement de sous-chaîne
-- abîmerait d'autres mots : « xi » est dans « pxiə »). Le trigger les
-- signale par un NOTICE pour relecture.
--
-- Aucun contenu du lexique ici : le rattachement se fait par comparaison
-- avec les données déjà en base. Idempotent.
-- ============================================================================

alter table public.exercises
  add column if not exists lexeme_id bigint
    references public.lexemes (id) on delete set null;

create index if not exists exercises_lexeme on public.exercises (lexeme_id);

-- Rattachement initial : même forme cyrillique, sans tenir compte de la casse.
update public.exercises as e
   set lexeme_id = l.id
  from public.lexemes as l
 where e.lexeme_id is null
   and lower(e.cyrillic) = lower(l.cyrillic);

-- Reprend la majuscule initiale de [template] pour [value].
create or replace function public.match_initial_case(template text, value text)
returns text language sql immutable as $$
  select case
           when left(template, 1) <> lower(left(template, 1))
             then upper(left(value, 1)) || substr(value, 2)
           else value
         end
$$;

create or replace function public.lexemes_propagate()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  cited text;
begin
  if new.cyrillic is distinct from old.cyrillic
     or new.latin is distinct from old.latin then
    update public.exercises as e
       set cyrillic = public.match_initial_case(e.cyrillic, new.cyrillic),
           translit = public.match_initial_case(e.translit, new.latin)
     where e.lexeme_id = new.id;
  end if;

  if new.latin is distinct from old.latin then
    select string_agg(lesson_id || '.' || sort_order, ', '
                      order by lesson_id, sort_order)
      into cited
      from public.exercises
     where position(lower(old.latin) in lower(
             coalesce(prompt, '') || ' ' || coalesce(choices::text, '')
             || ' ' || i18n::text)) > 0;
    if cited is not null then
      raise notice 'Lexème % : « % » → « % ». Ancienne forme peut-être '
                   'encore citée dans les consignes ou choix des exercices %',
                   new.id, old.latin, new.latin, cited;
    end if;
  end if;

  return new;
end
$$;

drop trigger if exists lexemes_propagate on public.lexemes;
create trigger lexemes_propagate after update on public.lexemes
  for each row execute function public.lexemes_propagate();

-- Fonctions internes : rien à appeler depuis les apps.
revoke all on function public.match_initial_case(text, text)
  from public, anon, authenticated;
revoke all on function public.lexemes_propagate()
  from public, anon, authenticated;
