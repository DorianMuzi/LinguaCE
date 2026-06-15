# Backlog de tâches — contributeurs

> Tâches prêtes à déléguer, dérivées de la revue UX/fonctionnelle de juin 2026.
> Chaque section = une issue GitHub (titre, corps, labels, critères d'acceptation).
> Le script `scripts/create-issues.ps1` les crée toutes via `gh` (voir bas de page).
>
> **Conventions du projet** (valables pour toutes les tâches) :
> - Toute chaîne visible passe par `lib/i18n/app_strings.dart` en **FR/EN/RU/CE**
>   (CE en best-effort, marqué pour relecture native sur #chechen-linguistics).
> - Couleurs/tailles/durées via `lib/design/lingua_tokens.dart` — jamais en dur.
> - Les écrans n'appellent jamais Supabase directement → tout passe par `lib/services/`.
> - `flutter analyze` sans warning + `flutter test` vert avant toute PR.
> - Accessibilité : `Semantics`, support `MediaQuery.disableAnimations`.

---

## 1. Notifications de rappel quotidien
**Labels :** `enhancement`, `priority: high`, `good first issue`

**Contexte.** La série (streak) est un moteur de rétention, mais l'app ne
rappelle jamais à l'utilisateur de revenir. Le réglage « Notifications » existe
déjà dans l'UI (`set.notifications` dans `app_strings.dart`) mais ne fait rien.

**À faire.**
- Ajouter `flutter_local_notifications` à `pubspec.yaml`.
- Planifier une notification locale quotidienne (heure par défaut : 19 h) qui
  invite à continuer sa série. Texte localisé (FR/EN/RU/CE).
- Brancher le toggle `set.notifications` existant : activer/désactiver et
  persister le choix (via `shared_preferences`, déjà au projet).
- Gérer la permission Android 13+ (`POST_NOTIFICATIONS`) avec une demande propre.
- Annuler la notification du jour si l'utilisateur a déjà été actif (réutiliser
  `last_activity` du profil / `ProfileService`).

**Critères d'acceptation.**
- [ ] Le toggle active/désactive réellement les notifications, état persistant.
- [ ] Une notification apparaît à l'heure prévue sur Android 13 et 14.
- [ ] Aucune notification si l'utilisateur a déjà pratiqué dans la journée.
- [ ] Textes présents dans les 4 langues ; `analyze` + `test` verts.

---

## 2. Passe d'accessibilité (contraste + lecteurs d'écran)
**Labels :** `accessibility`, `priority: medium`, `good first issue`

**Contexte.** Deux points relevés en revue : le token `textTertiary` (#919191
sur fond clair ≈ 2,8:1) est sous le seuil WCAG AA, et les emojis utilisés comme
icônes (🔥 série, ✨ mot du jour, ⭐ XP…) sont lus littéralement (« flamme »)
par les lecteurs d'écran.

**À faire.**
- Auditer les usages de `textTertiary` ; soit assombrir le token dans
  `lib/design/lingua_tokens.dart` pour atteindre 4,5:1, soit le réserver au
  décoratif non textuel. Vérifier le rendu clair ET sombre.
- Envelopper les emojis-icônes informatifs dans `Semantics(label: …)` ou
  `ExcludeSemantics` selon le cas, avec libellés localisés.
- Vérifier que les cibles tactiles interactives font ≥ 48×48 dp.

**Critères d'acceptation.**
- [ ] `textTertiary` (ou son remplaçant pour le texte) atteint un contraste
      AA dans les deux thèmes (donner les ratios mesurés dans la PR).
- [ ] Les emojis informatifs ont un label sémantique ou sont exclus.
- [ ] `analyze` + `test` verts.

---

## 3. Animation de gain d'XP dans les exercices
**Labels :** `enhancement`, `priority: low`, `good first issue`

**Contexte.** Le retour haptique sur bonne réponse existe (`exercise_screen.dart`)
mais il n'y a aucune récompense visuelle au moment du gain. La gamification
existe dans les données, pas encore dans la sensation.

**À faire.**
- Afficher une animation brève « +10 XP » / « +20 XP » près du compteur d'XP du
  header d'exercice quand le gain est crédité (`_xpEarned`).
- Respecter `MediaQuery.disableAnimations` (reduced motion) : afficher la valeur
  sans animation dans ce cas.
- Durées et couleurs via les tokens (`LinguaDuration`, `lingua_tokens.dart`).

**Critères d'acceptation.**
- [ ] L'animation se déclenche au bon moment, sans bloquer l'enchaînement.
- [ ] Désactivée proprement quand « animations réduites » est actif.
- [ ] `analyze` + `test` verts.

---

## 4. Deep link de réinitialisation du mot de passe
**Labels :** `bug`, `priority: medium`

**Contexte.** L'écran « Mot de passe oublié » envoie un email de réinitialisation
(`forgot_password_screen.dart`), mais le retour vers l'app via le lien n'a pas
été validé sur device — c'est un piège classique Supabase/Android.

**À faire.**
- Configurer `redirectTo` côté Supabase et l'intent filter Android (deep link /
  app link) pour rouvrir l'app sur l'écran de nouveau mot de passe.
- Gérer la session de récupération à l'ouverture du lien.
- Documenter la config (URL de redirection, `AndroidManifest.xml`) dans la PR.

**Critères d'acceptation.**
- [ ] Sur un device Android réel : cliquer le lien de l'email rouvre l'app sur
      l'écran de définition d'un nouveau mot de passe.
- [ ] Le changement de mot de passe aboutit et reconnecte l'utilisateur.
- [ ] Étapes de config documentées dans la PR.

---

## 5. Refonte des actions rapides de l'accueil
**Labels :** `enhancement`, `priority: low`, `discussion`

**Contexte.** Les 3 « actions rapides » de l'accueil (`home_screen.dart`,
`_buildQuickActions`) dupliquent exactement la barre de navigation (Chat /
Leçons / Progrès), accessible 100 px plus bas. C'est de l'espace gâché.

**À faire.**
- Remplacer par des actions à valeur unique : p. ex. « Reprendre la leçon en
  cours », « Réviser » (renvoie vers une leçon déjà terminée), objectif
  quotidien. Discuter les choix dans l'issue avant d'implémenter.
- Réutiliser les données déjà chargées (profil, leçons) sans requête en plus.
- Chaînes localisées, design tokens.

**Critères d'acceptation.**
- [ ] Plus aucune action rapide ne duplique un onglet de la nav bar.
- [ ] Les nouvelles actions mènent à un état utile en un tap.
- [ ] `analyze` + `test` verts.

---

## 6. [GROS CHANTIER] Contenu des leçons en base Supabase
**Labels :** `enhancement`, `priority: high`, `phase-3`, `help wanted`

**Contexte.** Le contenu pédagogique réel (exercices) est codé en dur côté
client dans `lib/screens/exercise_screen.dart` (`_Data._byLesson`, leçons '1'
à '6' uniquement). Conséquences :
- toute leçon ajoutée en base au-delà de la 6 ouvre un écran qui se referme
  aussitôt (`exercise_screen.dart` ~ligne 300) — **bug visible** ;
- impossible d'enrichir le contenu sans recompiler l'app ;
- c'est le verrou de la Phase 3 du README (« Full lesson content — 8 levels »).

Les métadonnées de leçons vivent déjà en base (`supabase/migrations/`,
`lesson_service.dart`) — il faut faire de même pour les exercices.

**À faire.**
1. Concevoir une table `exercises` (Supabase migration) : `lesson_id` (FK),
   `sort_order`, `type` (flashcard/qcm/translation), `cyrillic`, `translit`,
   `french`, `prompt`, `choices` (jsonb), `correct_index`. RLS lecture publique
   cohérente avec les autres tables.
2. Migrer les 6 leçons existantes de `exercise_screen.dart` vers un seed SQL
   (conserver le contenu exact ; ne PAS réécrire le tchétchène — voir note).
3. Ajouter `ExerciseService` dans `lib/services/` qui charge les exercices
   d'une leçon depuis la base, avec repli sur `MockData` hors-ligne (même
   pattern que `LessonService.fetchLessons`).
4. Adapter `ExerciseScreen` pour consommer le service au lieu de `_Data`,
   en gardant un état de chargement propre (pas d'écran qui clignote/ferme).
5. Gérer le cas « leçon sans exercice » par un message clair, pas une fermeture.

**Note linguistique (importante).** Ne pas créer ni corriger de contenu
tchétchène à l'occasion de cette migration : déplacer le contenu existant tel
quel. Tout nouvel exemple ou toute correction doit être marqué
`-- REVIEW NATIF REQUIS :` et soumis à #chechen-linguistics (voir
`docs/audit-linguistique-2026-06-11.md`).

**Critères d'acceptation.**
- [ ] Migration + seed appliquables via `supabase db push` ; les 6 leçons
      existantes rendent un contenu identique à l'actuel.
- [ ] Une 7ᵉ leçon ajoutée en base s'ouvre et fonctionne sans recompiler l'app.
- [ ] Hors-ligne : repli gracieux, aucun crash ni écran qui se ferme.
- [ ] `ExerciseScreen` ne référence plus `_Data` ; `analyze` + `test` verts.
- [ ] Aucun contenu tchétchène nouveau non marqué pour relecture native.

---

---

# Backend / sécurité (profil systèmes — Postgres, Deno Edge Functions)

> Pas de C/Rust/C++ dans ces tâches (le backend est Supabase), mais elles
> récompensent un raisonnement systèmes : frontières d'autorité, intégrité
> transactionnelle, indexation. Disponibles immédiatement, sans dépendance au
> code propriétaire de translittération.

## 7. Durcir l'Edge Function `chat` (auth + bornes + anti-abus)
**Labels :** `security`, `backend`, `priority: high`

**Contexte.** `supabase/functions/chat/index.ts` ne vérifie que la présence de
la clé `ANTHROPIC_API_KEY`. Elle **ne valide pas l'appelant** : la clé `anon`
Supabase est publique (embarquée dans le client), donc n'importe qui peut
appeler la fonction et consommer le crédit API Anthropic — c'est un proxy ouvert.

**À faire.**
- Vérifier le JWT Supabase de l'appelant (header `Authorization: Bearer`) et
  rejeter les requêtes non authentifiées (401).
- Borner les entrées : taille de payload, nombre de messages, `max_tokens`
  plafonné côté serveur (ne pas faire confiance à la valeur client).
- Rate limiting par utilisateur (p. ex. table Postgres compteur, ou KV) avec
  réponse 429 explicite.
- Conserver le comportement de streaming SSE existant (ne pas le casser).

**Critères d'acceptation.**
- [ ] Une requête sans JWT valide est rejetée (401).
- [ ] `max_tokens`/taille/nombre de messages sont plafonnés côté serveur.
- [ ] Au-delà du quota, l'API renvoie 429 ; le client l'affiche proprement.
- [ ] Le chat (réponse normale + streaming) fonctionne toujours pour un
      utilisateur connecté.

## 8. Rendre XP / niveau / ligue inviolables côté serveur
**Labels :** `security`, `backend`, `priority: high`

**Contexte.** La politique RLS `profiles_update_own` autorise un utilisateur à
mettre à jour **sa propre ligne `profiles`** — colonnes `xp`, `level`, `league`
comprises. L'XP est aujourd'hui calculée côté client (`ProfileService.addXP`).
Conséquence : un utilisateur authentifié peut écrire directement `xp = 999999`
et truster le classement. Les valeurs de progression doivent être
**autoritatives côté serveur**.

**À faire.**
- Déplacer l'attribution d'XP dans une fonction Postgres `SECURITY DEFINER`
  (p. ex. `award_xp(amount int)`) qui : insère dans `xp_events`, incrémente
  `profiles.xp`, recalcule `level` et `league`, le tout transactionnellement.
- Restreindre la policy d'update de `profiles` pour que le client ne puisse
  plus écrire `xp`/`level`/`league` directement (laisser `username`,
  `interface_language`). Idéalement via une fonction dédiée ou des grants
  colonne par colonne.
- Adapter `ProfileService` (`addXP`, `updateLeague`) pour appeler la RPC au
  lieu d'écrire les colonnes en direct.
- Gérer l'idempotence de fin de leçon (pas de double crédit — cf. la garde
  `wasCompleted` actuelle dans `lesson_service.dart`).

**Critères d'acceptation.**
- [ ] Un `UPDATE profiles SET xp = …` direct depuis un client authentifié est
      refusé.
- [ ] L'XP ne s'obtient que via la fonction serveur ; le calcul niveau/ligue
      est identique à l'actuel.
- [ ] Terminer une leçon crédite la bonne XP, une seule fois ;
      `flutter analyze` + `flutter test` verts.

## 9. Rang du classement via fonction Postgres + index
**Labels :** `backend`, `performance`, `priority: medium`

**Contexte.** `ProfileService.fetchLeaderboard` récupère le top 20 puis, si
l'utilisateur n'y est pas, fait une **seconde requête** `COUNT(*) WHERE xp > moi`
pour son rang. Or il n'existe **aucun index sur `profiles.xp`** : le tri du
classement et ce comptage scannent toute la table.

**À faire.**
- Ajouter un index sur `profiles (xp desc)` (migration SQL).
- Exposer une fonction Postgres `get_leaderboard(limit int)` et/ou
  `get_my_rank()` qui renvoie le top N **et** le rang réel de l'appelant en un
  aller-retour, avec une règle de départage des ex æquo déterministe.
- Adapter `fetchLeaderboard` pour consommer la RPC (supprimer la 2ᵉ requête).

**Critères d'acceptation.**
- [ ] Index présent ; le plan d'exécution du classement l'utilise
      (`explain analyze` dans la PR).
- [ ] Le rang de l'utilisateur hors top N est correct, ex æquo gérés.
- [ ] Un seul aller-retour réseau pour le classement ; `analyze` + `test` verts.

---

## Ordre conseillé

**Côté app (tâches 1–6) :**
1. **#6** dès que possible (débloque la Phase 3, corrige un vrai bug) — c'est le
   chantier qui demande de comprendre l'archi services/écrans.
2. **#1** et **#4** en parallèle (rétention + bug device), indépendants.
3. **#2**, **#3**, **#5** quand le reste avance (polish), faisables par un
   nouveau venu.

**Côté backend (tâches 7–9, profil systèmes) :**
1. **#8** d'abord (faille d'intégrité : l'XP est falsifiable) puis **#7**
   (proxy ouvert) — les deux touchent à la sécurité.
2. **#9** ensuite (perf + dette du classement).
