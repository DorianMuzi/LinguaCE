-- ============================================================================
-- LinguaCE — contenu pédagogique : table `exercises`
-- Appliquer avec :  supabase db push
-- Idempotent : « create table if not exists » + « on conflict do nothing ».
--
-- Jusqu'ici les exercices vivaient en dur dans `lib/screens/exercise_screen.dart`
-- (leçons 1 à 6 uniquement) : toute leçon ajoutée en base au-delà ouvrait un
-- écran qui se refermait aussitôt. Ce fichier les déplace en base, pour que le
-- contenu s'enrichisse sans recompiler l'app.
--
-- ⚠️ Le contenu tchétchène ci-dessous est repris À L'IDENTIQUE de l'existant.
--    Aucune forme n'a été créée ni corrigée ici — voir la note de fin.
-- ============================================================================

create table if not exists public.exercises (
  id            bigint generated always as identity primary key,
  lesson_id     text    not null references public.lessons(id) on delete cascade,
  sort_order    integer not null,
  type          text    not null check (type in ('flashcard', 'qcm', 'translation')),

  -- Le mot ou la phrase travaillés.
  cyrillic      text    not null,
  translit      text    not null,
  french        text    not null,

  -- Consigne affichée (null pour une flashcard, qui n'en a pas besoin).
  prompt        text,

  -- QCM uniquement : propositions et index (0-based) de la bonne réponse.
  choices       jsonb,
  correct_index integer,

  created_at    timestamptz default now(),

  unique (lesson_id, sort_order),

  -- Un QCM doit porter ses propositions ET un index valide ; les autres types
  -- ne doivent pas en porter. Garde-fou contre un seed incomplet.
  constraint exercises_qcm_shape check (
    (type = 'qcm'     and choices is not null and correct_index is not null
                      and jsonb_typeof(choices) = 'array'
                      and correct_index >= 0
                      and correct_index < jsonb_array_length(choices))
    or
    (type <> 'qcm'    and choices is null and correct_index is null)
  )
);

-- Lecture du catalogue : même politique que `lessons`.
alter table public.exercises enable row level security;

drop policy if exists "exercises_select_auth" on public.exercises;
create policy "exercises_select_auth"
  on public.exercises for select to authenticated using (true);

-- L'écran charge une leçon entière, dans l'ordre.
create index if not exists exercises_lesson_order
  on public.exercises (lesson_id, sort_order);

-- ── Contenu : les 6 leçons existantes ───────────────────────────────────────

insert into public.exercises
  (lesson_id, sort_order, type, cyrillic, translit, french, prompt, choices, correct_index)
values
  -- Leçon 1 — Premiers Mots
  ('1', 1, 'flashcard',   'Салам',          'Salam',         'Salut (informel)', null, null, null),
  ('1', 2, 'flashcard',   'Баркалла',       'Barkalla',      'Merci',            null, null, null),
  ('1', 3, 'qcm',         'Баркалла',       'Barkalla',      'Merci',
      'Comment dit-on "Merci" en tchétchène ?',
      '["Salam","Barkalla","Dika","Voŋ"]'::jsonb, 1),
  ('1', 4, 'qcm',         'Дика',           'Dika',          'Bien / Bon',
      'Que signifie "Dika" ?',
      '["Mauvais","Beaucoup","Bien / Bon","Peu"]'::jsonb, 2),
  ('1', 5, 'qcm',         'Дукха',          'Duqa',          'Beaucoup',
      'Quel mot signifie "Beaucoup" ?',
      '["K̇ezig","Voŋ","Dika","Duqa"]'::jsonb, 3),
  ('1', 6, 'translation', 'Баркалла дукха', 'Barkalla duqa', 'Merci beaucoup',
      E'Traduis en tchétchène :\n"Merci beaucoup"', null, null),

  -- Leçon 2 — Salutations
  ('2', 1, 'flashcard',   'Марша огӀийла',    'Marşa oġiyla', 'Bonjour (formel)',        null, null, null),
  ('2', 2, 'flashcard',   'Дела реза хуьлда', 'Dela reza xülda', 'Que Dieu soit satisfait', null, null, null),
  ('2', 3, 'qcm',         'Марша огӀийла',    'Marşa oġiyla', 'Bonjour (formel)',
      'Quel est le bonjour formel en tchétchène ?',
      '["Salam","Barkalla","Marşa oġiyla","Dika de"]'::jsonb, 2),
  ('2', 4, 'qcm',         'Суьйре',           'Süyre',        'Soir',
      'Comment dit-on "Soir" en tchétchène ?',
      '["De","Büysa","Jüyre","Süyre"]'::jsonb, 3),
  ('2', 5, 'qcm',         'Марша огӀийла',    'Marşa oġiyla', 'Entre libre (litt.)',
      'Que signifie littéralement "Marşa oġiyla" ?',
      '["Bonne journée","Entre libre","Bonne nuit","À bientôt"]'::jsonb, 1),
  ('2', 6, 'translation', 'Марша огӀийла',    'Marşa oġiyla', 'Bonjour (formel)',
      E'Traduis en tchétchène :\n"Bonjour" (formel)', null, null),

  -- Leçon 3 — Chiffres & Nombres
  ('3', 1, 'flashcard',   'цхьа',  'cẋa', 'Un (1)',   null, null, null),
  ('3', 2, 'flashcard',   'шиъ',   'şiə', 'Deux (2)', null, null, null),
  ('3', 3, 'qcm',         'кхо',   'qo',  'Trois (3)',
      '"Qo" signifie ?',
      '["Un","Deux","Trois","Quatre"]'::jsonb, 2),
  ('3', 4, 'qcm',         'пхи',   'pxi', 'Cinq (5)',
      'Comment dit-on "5" en tchétchène ?',
      '["Diə","Pxi","Yalx","Vorx"]'::jsonb, 1),
  ('3', 5, 'qcm',         'цхьа',  'cẋa', 'Un (1)',
      'Comment dit-on "1" en tchétchène ?',
      '["Şiə","Qo","Cẋa","Diə"]'::jsonb, 2),
  ('3', 6, 'translation', 'кхо',   'qo',  'Trois',
      'Écris le chiffre 3 en tchétchène :', null, null),

  -- Leçon 4 — La Famille
  ('4', 1, 'flashcard',   'Да',    'Da',   'Père',  null, null, null),
  ('4', 2, 'flashcard',   'Нана',  'Nana', 'Mère',  null, null, null),
  ('4', 3, 'qcm',         'Ваша',  'Vaşa', 'Frère',
      'Comment dit-on "Frère" en tchétchène ?',
      '["Yişa","Nana","Vaşa","Da"]'::jsonb, 2),
  ('4', 4, 'qcm',         'Йиша',  'Yişa', 'Sœur',
      '"Yişa" signifie ?',
      '["Mère","Père","Frère","Sœur"]'::jsonb, 3),
  ('4', 5, 'qcm',         'Да',    'Da',   'Père',
      'Comment dit-on "Père" en tchétchène ?',
      '["Nana","Da","Vaşa","Yişa"]'::jsonb, 1),
  ('4', 6, 'translation', 'Нана',  'Nana', 'Mère',
      E'Traduis en tchétchène :\n"Mère"', null, null),

  -- Leçon 5 — Les Couleurs
  ('5', 1, 'flashcard',   'цӀен',      'ċeŋ',     'Rouge', null, null, null),
  ('5', 2, 'flashcard',   'сийна',     'siyna',   'Bleu',  null, null, null),
  ('5', 3, 'qcm',         'цӀен',      'ċeŋ',     'Rouge',
      'Comment dit-on "Rouge" en tchétchène ?',
      '["Siyna","Ċeŋ","K̇ayŋ","Bäccara"]'::jsonb, 1),
  ('5', 4, 'qcm',         'баьццара',  'bäccara', 'Vert',
      'Que signifie "Bäccara" ?',
      '["Rouge","Bleu","Vert","Noir"]'::jsonb, 2),
  ('5', 5, 'qcm',         'Ӏаьржа',    'Järƶa',   'Noir',
      'Comment dit-on "Noir" en tchétchène ?',
      '["Järƶa","Moƶa","K̇ayŋ","Siyna"]'::jsonb, 0),
  ('5', 6, 'translation', 'кӀайн',     'k̇ayŋ',   'Blanc',
      E'Traduis en tchétchène :\n"Blanc"', null, null),

  -- Leçon 6 — La Nourriture
  ('6', 1, 'flashcard',   'бепиг',  'bepig', 'Pain',   null, null, null),
  ('6', 2, 'flashcard',   'хи',     'xi',    'Eau',    null, null, null),
  ('6', 3, 'qcm',         'хи',     'xi',    'Eau',
      'Comment dit-on "Eau" en tchétchène ?',
      '["Bepig","Xi","Şura","Tüxa"]'::jsonb, 1),
  ('6', 4, 'qcm',         'жижиг',  'ƶiƶig', 'Viande',
      'Que signifie "Ƶiƶig" ?',
      '["Pain","Lait","Viande","Sel"]'::jsonb, 2),
  ('6', 5, 'qcm',         'шура',   'şura',  'Lait',
      'Comment dit-on "Lait" en tchétchène ?',
      '["Tüxa","Xi","Şura","Bepig"]'::jsonb, 2),
  ('6', 6, 'translation', 'бепиг',  'bepig', 'Pain',
      E'Traduis en tchétchène :\n"Pain"', null, null)
on conflict (lesson_id, sort_order) do nothing;

-- ── Note de relecture ───────────────────────────────────────────────────────
-- REVIEW NATIF REQUIS : aucune forme nouvelle n'est introduite par cette
-- migration (contenu déplacé tel quel depuis le code). En revanche, l'audit
-- docs/audit-linguistique-2026-06-11.md a déjà signalé trois points ici
-- présents, en attente de validation sur #chechen-linguistics :
--   • leçon 2 — « Марша огӀийла » sans préfixe de classe (le system prompt
--     enseigne « Марша вогӀийла »). Forme de citation à trancher.
--   • leçon 3 — « кхо » / « пхи » (formes courtes) vs « кхоъ » / « пхиъ »
--     (formes absolues du system prompt). Choix pédagogique à trancher.
--   • leçon 1 — « Баркалла дукха » : ordre des mots à confirmer
--     (le tchétchène place normalement le modificateur avant).
-- Corriger ici APRÈS validation native, pas avant.
