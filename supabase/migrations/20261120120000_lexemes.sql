-- ============================================================================
-- LinguaCE Core v0 — lexique commun (`public.lexemes`)
-- Appliquer avec :  supabase db push
--
-- Source de vérité linguistique de tout l'écosystème (App, Dictionary,
-- Keyboard…) : un mot n'est saisi qu'une fois, ici, puis réutilisé.
--
-- ⚠️ Ce fichier ne contient QUE la structure. Le lexique est fermé (tous
-- droits réservés) : son contenu vit dans le dépôt privé `linguace-core` et
-- n'est jamais versionné dans ce dépôt public.
--
-- Lecture : seuls les mots VALIDÉS par un natif sont visibles des apps, et
-- seulement les colonnes publiques (pas les notes de validation).
-- Écriture : aucune depuis les apps ; ajouts par l'outillage du Core.
-- ============================================================================

create table if not exists public.lexemes (
  id            bigint generated always as identity primary key,

  -- Forme de référence en cyrillique (vrai palochka Ӏ, U+04C0).
  cyrillic      text not null check (btrim(cyrillic) <> ''),

  -- Translittération Muziŋ Dar, calculée par le moteur du Core puis
  -- corrigeable à la validation. Garde-fou : aucune lettre cyrillique
  -- résiduelle (défaut connu de l'algorithme : « е », « й » oubliés).
  latin         text not null check (btrim(latin) <> ''
                                     and latin !~ '[А-Яа-яЁёӀӏ]'),

  -- Homonymes : même forme, même nature, sens différents.
  sense         smallint not null default 1 check (sense >= 1),

  pos           text not null check (pos in (
                  'noun', 'verb', 'adjective', 'adverb', 'pronoun',
                  'numeral', 'postposition', 'conjunction', 'particle',
                  'interjection', 'phrase')),

  -- Classe nominale (noms uniquement) : в, й, й-II, д, б, б-II.
  noun_class    text check (noun_class in ('v', 'y', 'y2', 'd', 'b', 'b2')),

  -- Traductions par langue : {"FR": ["Merci"], "EN": ["Thank you"], ...}
  translations  jsonb not null default '{}'::jsonb
                check (jsonb_typeof(translations) = 'object'),

  audio_url     text,

  -- Cycle de validation par un locuteur natif.
  status        text not null default 'draft'
                check (status in ('draft', 'validated', 'rejected')),
  validated_at  timestamptz,
  notes         text,      -- interne : jamais exposé aux apps
  source        text,      -- d'où vient l'entrée (leçon, corpus, auteur…)

  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),

  unique (cyrillic, pos, sense),
  constraint lexemes_class_only_for_nouns
    check (noun_class is null or pos = 'noun'),
  constraint lexemes_validated_has_date
    check (status <> 'validated' or validated_at is not null)
);

-- Recherche du futur Dictionary : par préfixe, en latin comme en cyrillique.
create index if not exists lexemes_latin_prefix
  on public.lexemes (lower(latin) text_pattern_ops);
create index if not exists lexemes_cyrillic_prefix
  on public.lexemes (lower(cyrillic) text_pattern_ops);

-- updated_at tenu à jour automatiquement.
create or replace function public.lexemes_touch()
returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end $$;

drop trigger if exists lexemes_touch on public.lexemes;
create trigger lexemes_touch before update on public.lexemes
  for each row execute function public.lexemes_touch();

-- ── Accès ───────────────────────────────────────────────────────────────────
alter table public.lexemes enable row level security;

drop policy if exists "lexemes_select_validated" on public.lexemes;
create policy "lexemes_select_validated"
  on public.lexemes for select to authenticated
  using (status = 'validated');

-- Les privilèges par défaut du schéma donnent tout à anon/authenticated :
-- on les retire, puis on n'ouvre que la lecture des colonnes publiques.
revoke all on public.lexemes from anon, authenticated;
grant select (id, cyrillic, latin, sense, pos, noun_class, translations,
              audio_url)
  on public.lexemes to authenticated;
