-- ============================================================================
-- LinguaCE — nouvelles leçons (Couleurs & Nourriture)
-- Appliquer avec :  supabase db push
-- Idempotent : « on conflict do nothing ».
-- ============================================================================

insert into public.lessons (id, title, subtitle, icon, xp_reward, total_exercises, sort_order) values
  ('5', 'Les Couleurs',  'Rouge, bleu, vert…',  '🎨', 300, 6, 5),
  ('6', 'La Nourriture', 'Pain, eau, viande…',  '🍽️', 350, 6, 6)
on conflict (id) do nothing;
