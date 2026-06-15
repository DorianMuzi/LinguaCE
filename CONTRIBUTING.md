# Contribuer à LinguaCE 🏔

Merci de l'intérêt que tu portes à LinguaCE ! Toute contribution — code,
correction, traduction, contenu linguistique — est la bienvenue.

> 💬 **Une question, envie de te présenter ou de coordonner une tâche ?**
> Rejoins le Discord du projet : <https://discord.gg/fnPmjfttc>
> (canaux `#flutter-dart`, `#claude-api`, `#chechen-linguistics`…)

## 🚀 Mise en route

L'installation (Flutter, `env.json`, schéma Supabase) est décrite dans le
[README](README.md#-démarrage). Avant toute chose, assure-toi que l'app
démarre chez toi :

```bash
flutter pub get
flutter run --dart-define-from-file=env.json
```

## 🌳 Workflow

1. **Fork** le dépôt, puis crée une branche depuis `main` :
   ```bash
   git checkout -b feat/ma-fonctionnalite   # ou fix/mon-correctif
   ```
2. Fais tes changements (commits clairs, voir ci-dessous).
3. Ouvre une **Pull Request** vers `main` en décrivant le quoi et le pourquoi.

Pour un changement important, **ouvre d'abord une issue** pour en discuter
avant de coder — ça évite les efforts perdus.

### Convention de commits
Format conseillé : `type: description courte`
- `feat:` nouvelle fonctionnalité
- `fix:` correction de bug
- `ui:` design / mise en page
- `docs:` documentation
- `refactor:` refonte sans changement de comportement
- `chore:` maintenance (deps, config…)

## ✅ Checklist avant d'ouvrir une PR

- [ ] `flutter analyze` passe **sans erreur ni warning**
- [ ] L'app a été testée en thème **clair ET sombre**
- [ ] Le rendu reste correct sur **mobile et desktop** (redimensionne la fenêtre)
- [ ] Aucun secret committé (clé API, mot de passe…) — voir ci-dessous
- [ ] Les fichiers touchés gardent le style existant

## 🎨 Règles de design

LinguaCE utilise un **design system à base de tokens** (`lib/design/`).

- **Jamais de couleur codée en dur** (`Color(0xFF...)`) dans un écran.
  Utilise toujours `context.tokens` (`accent`, `surfaceRaised`, `textPrimary`…).
- Réutilise les composants existants : `CopilotCard`, `CopilotButton`,
  `AccentChip`, `SectionLabel`, `StatTile`.
- Respecte les échelles `LinguaSpacing` et `LinguaRadius`.
- Tout doit fonctionner dans les deux thèmes — c'est garanti si tu passes
  par les tokens.

## 🔐 Sécurité des secrets

- Les clés vivent **uniquement** dans `env.json`, qui est ignoré par git.
- Ne mets jamais de clé dans le code, un commit, une issue ou une capture.
- Si tu exposes une clé par accident, **révoque-la immédiatement** et
  régénère-en une nouvelle.

## 🗣 Contenu linguistique (tchétchène)

Le contenu pédagogique demande de la rigueur :

- Appuie-toi sur des **sources fiables** (dictionnaires, grammaires de
  référence) et cite-les dans ta PR.
- N'altère pas les **exemples déjà validés** sans justification.
- Respecte le **système de translittération latine de 1992** utilisé par
  le projet.
- En cas de doute sur une forme grammaticale, signale-le plutôt que de
  deviner.

## 🐛 Signaler un bug / proposer une idée

Ouvre une **issue** en précisant :
- **Bug** : étapes pour reproduire, comportement attendu vs observé,
  plateforme (Android / iOS / web), thème (clair / sombre).
- **Fonctionnalité** : le besoin, le cas d'usage, et si possible une piste.

Pour en discuter à chaud, le [Discord](https://discord.gg/fnPmjfttc) est souvent
plus rapide qu'une issue.

## 📜 Licence

En contribuant, tu acceptes que ton travail soit distribué sous la licence
**Apache 2.0** du projet (voir [LICENSE](LICENSE)).

---

<p align="center">Баркалла — merci pour ta contribution ! 🙏</p>
