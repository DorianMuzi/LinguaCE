-- ============================================================================
-- LinguaCE — titres et sous-titres de leçons traduits (EN / RU / CE)
-- Appliquer avec :  supabase db push
--
-- `title` / `subtitle` restent la version française de référence ; les
-- colonnes *_i18n portent les autres langues, avec repli sur le français
-- côté app si une langue manque. Une leçon ajoutée sans traduction s'affiche
-- donc en français, sans rien casser.
--
-- CE : translittération Muziŋ Dar (Dico3), à valider par l'auteur.
-- Idempotent : `add column if not exists` + mises à jour par id.
-- ============================================================================

alter table public.lessons
  add column if not exists title_i18n    jsonb not null default '{}'::jsonb,
  add column if not exists subtitle_i18n jsonb not null default '{}'::jsonb;

update public.lessons as l set
  title_i18n = v.title_i18n,
  subtitle_i18n = v.subtitle_i18n
from (values
  ('1',
   '{"EN": "First Words", "RU": "Первые слова", "CE": "Düxẋarlera deşnaş"}'::jsonb,
   '{"EN": "Basic vocabulary", "RU": "Базовая лексика", "CE": "Körta deşnaş"}'::jsonb),
  ('2',
   '{"EN": "Greetings", "RU": "Приветствия", "CE": "Marşalla xattar"}'::jsonb,
   '{"EN": "Hello, goodbye…", "RU": "Привет, до свидания…", "CE": "Salam, jodika yoyla…"}'::jsonb),
  ('3',
   '{"EN": "Numbers", "RU": "Цифры и числа", "CE": "Teraẋaş"}'::jsonb,
   '{"EN": "From 1 to 100", "RU": "От 1 до 100", "CE": "1-çüra 100-çu qaççalc"}'::jsonb),
  ('4',
   '{"EN": "Family", "RU": "Семья", "CE": "Dözal"}'::jsonb,
   '{"EN": "Mother, father, brother…", "RU": "Мать, отец, брат…", "CE": "Nana, da, vaşa…"}'::jsonb),
  ('5',
   '{"EN": "Colours", "RU": "Цвета", "CE": "Basarş"}'::jsonb,
   '{"EN": "Red, blue, green…", "RU": "Красный, синий, зелёный…", "CE": "Ċeŋ, siyna, bäccara…"}'::jsonb),
  ('6',
   '{"EN": "Food", "RU": "Еда", "CE": "Daar"}'::jsonb,
   '{"EN": "Bread, water, meat…", "RU": "Хлеб, вода, мясо…", "CE": "Bepig, xi, ƶiƶig…"}'::jsonb)
) as v(id, title_i18n, subtitle_i18n)
where l.id = v.id;
