-- ============================================================================
-- LinguaCE — exercices traduits (EN / RU)
-- Appliquer avec :  supabase db push
--
-- `french`, `prompt` et `choices` restent la version française de référence.
-- La colonne `i18n` porte, par langue d'interface :
--   {"EN": {"meaning": "...", "prompt": "...", "choices": [...]}, "RU": {...}}
-- Tout champ absent retombe sur le français côté app. Les propositions de QCM
-- qui sont des mots tchétchènes ne sont PAS traduites (champ `choices` omis) ;
-- une liste traduite doit garder le même ordre et la même longueur, sinon
-- l'app l'ignore (l'index de la bonne réponse ne correspondrait plus).
--
-- Le tchétchène lui-même n'est pas touché. Pas de version CE : en interface
-- tchétchène, le sens des mots reste affiché en français (langue source).
-- Idempotent : `add column if not exists` + mises à jour par clé.
-- ============================================================================

alter table public.exercises
  add column if not exists i18n jsonb not null default '{}'::jsonb;

update public.exercises as e set i18n = v.i18n
from (values
  -- Leçon 1 — Premiers Mots
  ('1', 1, '{"EN": {"meaning": "Hi (informal)"},
             "RU": {"meaning": "Привет (неформально)"}}'::jsonb),
  ('1', 2, '{"EN": {"meaning": "Thank you"},
             "RU": {"meaning": "Спасибо"}}'::jsonb),
  ('1', 3, '{"EN": {"meaning": "Thank you", "prompt": "How do you say \"Thank you\" in Chechen?"},
             "RU": {"meaning": "Спасибо", "prompt": "Как сказать «Спасибо» по-чеченски?"}}'::jsonb),
  ('1', 4, '{"EN": {"meaning": "Good", "prompt": "What does \"Dika\" mean?",
                    "choices": ["Bad", "A lot", "Good", "A little"]},
             "RU": {"meaning": "Хорошо", "prompt": "Что значит «Dika»?",
                    "choices": ["Плохо", "Много", "Хорошо", "Мало"]}}'::jsonb),
  ('1', 5, '{"EN": {"meaning": "A lot", "prompt": "Which word means \"A lot\"?"},
             "RU": {"meaning": "Много", "prompt": "Какое слово значит «Много»?"}}'::jsonb),
  ('1', 6, '{"EN": {"meaning": "Thank you very much", "prompt": "Translate into Chechen:\n\"Thank you very much\""},
             "RU": {"meaning": "Большое спасибо", "prompt": "Переведи на чеченский:\n«Большое спасибо»"}}'::jsonb),

  -- Leçon 2 — Salutations
  ('2', 1, '{"EN": {"meaning": "Hello (formal)"},
             "RU": {"meaning": "Здравствуйте (официально)"}}'::jsonb),
  ('2', 2, '{"EN": {"meaning": "May God be pleased"},
             "RU": {"meaning": "Да будет доволен Бог"}}'::jsonb),
  ('2', 3, '{"EN": {"meaning": "Hello (formal)", "prompt": "What is the formal hello in Chechen?"},
             "RU": {"meaning": "Здравствуйте (официально)", "prompt": "Как официально поздороваться по-чеченски?"}}'::jsonb),
  ('2', 4, '{"EN": {"meaning": "Evening", "prompt": "How do you say \"Evening\" in Chechen?"},
             "RU": {"meaning": "Вечер", "prompt": "Как сказать «Вечер» по-чеченски?"}}'::jsonb),
  ('2', 5, '{"EN": {"meaning": "Come in freely (lit.)", "prompt": "What does \"Marşa oġiyla\" literally mean?",
                    "choices": ["Have a good day", "Come in freely", "Good night", "See you soon"]},
             "RU": {"meaning": "Входи свободным (букв.)", "prompt": "Что буквально значит «Marşa oġiyla»?",
                    "choices": ["Хорошего дня", "Входи свободным", "Спокойной ночи", "До скорого"]}}'::jsonb),
  ('2', 6, '{"EN": {"meaning": "Hello (formal)", "prompt": "Translate into Chechen:\n\"Hello\" (formal)"},
             "RU": {"meaning": "Здравствуйте (официально)", "prompt": "Переведи на чеченский:\n«Здравствуйте» (официально)"}}'::jsonb),

  -- Leçon 3 — Chiffres & Nombres
  ('3', 1, '{"EN": {"meaning": "One (1)"},   "RU": {"meaning": "Один (1)"}}'::jsonb),
  ('3', 2, '{"EN": {"meaning": "Two (2)"},   "RU": {"meaning": "Два (2)"}}'::jsonb),
  ('3', 3, '{"EN": {"meaning": "Three (3)", "prompt": "\"Qo\" means?",
                    "choices": ["One", "Two", "Three", "Four"]},
             "RU": {"meaning": "Три (3)", "prompt": "«Qo» значит?",
                    "choices": ["Один", "Два", "Три", "Четыре"]}}'::jsonb),
  ('3', 4, '{"EN": {"meaning": "Five (5)", "prompt": "How do you say \"5\" in Chechen?"},
             "RU": {"meaning": "Пять (5)", "prompt": "Как сказать «5» по-чеченски?"}}'::jsonb),
  ('3', 5, '{"EN": {"meaning": "One (1)", "prompt": "How do you say \"1\" in Chechen?"},
             "RU": {"meaning": "Один (1)", "prompt": "Как сказать «1» по-чеченски?"}}'::jsonb),
  ('3', 6, '{"EN": {"meaning": "Three", "prompt": "Write the number 3 in Chechen:"},
             "RU": {"meaning": "Три", "prompt": "Напиши число 3 по-чеченски:"}}'::jsonb),

  -- Leçon 4 — La Famille
  ('4', 1, '{"EN": {"meaning": "Father"}, "RU": {"meaning": "Отец"}}'::jsonb),
  ('4', 2, '{"EN": {"meaning": "Mother"}, "RU": {"meaning": "Мать"}}'::jsonb),
  ('4', 3, '{"EN": {"meaning": "Brother", "prompt": "How do you say \"Brother\" in Chechen?"},
             "RU": {"meaning": "Брат", "prompt": "Как сказать «Брат» по-чеченски?"}}'::jsonb),
  ('4', 4, '{"EN": {"meaning": "Sister", "prompt": "\"Yişa\" means?",
                    "choices": ["Mother", "Father", "Brother", "Sister"]},
             "RU": {"meaning": "Сестра", "prompt": "«Yişa» значит?",
                    "choices": ["Мать", "Отец", "Брат", "Сестра"]}}'::jsonb),
  ('4', 5, '{"EN": {"meaning": "Father", "prompt": "How do you say \"Father\" in Chechen?"},
             "RU": {"meaning": "Отец", "prompt": "Как сказать «Отец» по-чеченски?"}}'::jsonb),
  ('4', 6, '{"EN": {"meaning": "Mother", "prompt": "Translate into Chechen:\n\"Mother\""},
             "RU": {"meaning": "Мать", "prompt": "Переведи на чеченский:\n«Мать»"}}'::jsonb),

  -- Leçon 5 — Les Couleurs
  ('5', 1, '{"EN": {"meaning": "Red"},  "RU": {"meaning": "Красный"}}'::jsonb),
  ('5', 2, '{"EN": {"meaning": "Blue"}, "RU": {"meaning": "Синий"}}'::jsonb),
  ('5', 3, '{"EN": {"meaning": "Red", "prompt": "How do you say \"Red\" in Chechen?"},
             "RU": {"meaning": "Красный", "prompt": "Как сказать «Красный» по-чеченски?"}}'::jsonb),
  ('5', 4, '{"EN": {"meaning": "Green", "prompt": "What does \"Bäccara\" mean?",
                    "choices": ["Red", "Blue", "Green", "Black"]},
             "RU": {"meaning": "Зелёный", "prompt": "Что значит «Bäccara»?",
                    "choices": ["Красный", "Синий", "Зелёный", "Чёрный"]}}'::jsonb),
  ('5', 5, '{"EN": {"meaning": "Black", "prompt": "How do you say \"Black\" in Chechen?"},
             "RU": {"meaning": "Чёрный", "prompt": "Как сказать «Чёрный» по-чеченски?"}}'::jsonb),
  ('5', 6, '{"EN": {"meaning": "White", "prompt": "Translate into Chechen:\n\"White\""},
             "RU": {"meaning": "Белый", "prompt": "Переведи на чеченский:\n«Белый»"}}'::jsonb),

  -- Leçon 6 — La Nourriture
  ('6', 1, '{"EN": {"meaning": "Bread"}, "RU": {"meaning": "Хлеб"}}'::jsonb),
  ('6', 2, '{"EN": {"meaning": "Water"}, "RU": {"meaning": "Вода"}}'::jsonb),
  ('6', 3, '{"EN": {"meaning": "Water", "prompt": "How do you say \"Water\" in Chechen?"},
             "RU": {"meaning": "Вода", "prompt": "Как сказать «Вода» по-чеченски?"}}'::jsonb),
  ('6', 4, '{"EN": {"meaning": "Meat", "prompt": "What does \"Ƶiƶig\" mean?",
                    "choices": ["Bread", "Milk", "Meat", "Salt"]},
             "RU": {"meaning": "Мясо", "prompt": "Что значит «Ƶiƶig»?",
                    "choices": ["Хлеб", "Молоко", "Мясо", "Соль"]}}'::jsonb),
  ('6', 5, '{"EN": {"meaning": "Milk", "prompt": "How do you say \"Milk\" in Chechen?"},
             "RU": {"meaning": "Молоко", "prompt": "Как сказать «Молоко» по-чеченски?"}}'::jsonb),
  ('6', 6, '{"EN": {"meaning": "Bread", "prompt": "Translate into Chechen:\n\"Bread\""},
             "RU": {"meaning": "Хлеб", "prompt": "Переведи на чеченский:\n«Хлеб»"}}'::jsonb)
) as v(lesson_id, sort_order, i18n)
where e.lesson_id = v.lesson_id and e.sort_order = v.sort_order;
