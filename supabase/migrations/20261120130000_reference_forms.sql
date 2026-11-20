-- ============================================================================
-- LinguaCE — leçons alignées sur les formes de référence (décision auteur,
-- 2026-11-20 ; points de l'audit linguistique du 2026-06-11)
-- Appliquer avec :  supabase db push
--
--   • марша огӀийла  → марша вогӀийла  (préfixe de classe в-)
--   • кхо / пхи      → кхоъ / пхиъ      (formes absolues, citées seules)
--   • баркалла дукха → дукха баркалла  (modificateur avant)
--   • QCM leçon 3 : « Vorx » → « Vorh » (ворхӀ : хӀ → h, erreur de translit.)
--
-- Latin issu de Dico3. Idempotent : mises à jour par clé (leçon, ordre).
-- ============================================================================

-- Leçon 1 — exercice de traduction « Merci beaucoup »
update public.exercises
   set cyrillic = 'Дукха баркалла', translit = 'Duqa barkalla'
 where lesson_id = '1' and sort_order = 6;

-- Leçon 2 — « Bonjour (formel) »
update public.exercises
   set cyrillic = 'Марша вогӀийла', translit = 'Marşa voġiyla'
 where lesson_id = '2' and sort_order in (1, 3, 5, 6);

update public.exercises
   set choices = '["Salam", "Barkalla", "Marşa voġiyla", "Dika de"]'::jsonb
 where lesson_id = '2' and sort_order = 3;

update public.exercises
   set prompt = 'Que signifie littéralement "Marşa voġiyla" ?',
       i18n = jsonb_set(
                jsonb_set(i18n, '{EN,prompt}',
                          '"What does \"Marşa voġiyla\" literally mean?"'),
                '{RU,prompt}', '"Что буквально значит «Marşa voġiyla»?"')
 where lesson_id = '2' and sort_order = 5;

-- Leçon 3 — nombres
update public.exercises
   set cyrillic = 'кхоъ', translit = 'qoə',
       prompt = '"Qoə" signifie ?',
       i18n = jsonb_set(
                jsonb_set(i18n, '{EN,prompt}', '"\"Qoə\" means?"'),
                '{RU,prompt}', '"«Qoə» значит?"')
 where lesson_id = '3' and sort_order = 3;

update public.exercises
   set cyrillic = 'пхиъ', translit = 'pxiə',
       choices = '["Diə", "Pxiə", "Yalx", "Vorh"]'::jsonb
 where lesson_id = '3' and sort_order = 4;

update public.exercises
   set choices = '["Şiə", "Qoə", "Cẋa", "Diə"]'::jsonb
 where lesson_id = '3' and sort_order = 5;

update public.exercises
   set cyrillic = 'кхоъ', translit = 'qoə'
 where lesson_id = '3' and sort_order = 6;
