# LinguaCE 🏔

**Application mobile d'apprentissage de la langue tchétchène (нохчийн мотт) assistée par IA.**

[![CI](https://github.com/DorianMuzi/LinguaCE/actions/workflows/ci.yml/badge.svg)](https://github.com/DorianMuzi/LinguaCE/actions/workflows/ci.yml)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.8+-02569B?logo=flutter)](https://flutter.dev)

LinguaCE aide à apprendre le tchétchène — une langue caucasienne du nord-est —
grâce à un assistant conversationnel (Claude), des leçons interactives, un
système de progression gamifié et le système de translittération latine de 1992.

---

## ✨ Fonctionnalités

- 🤖 **Chat IA** — un tuteur spécialisé en grammaire tchétchène (Claude)
- 📚 **Leçons & exercices** — flashcards, QCM, traduction
- 🔤 **Translittération** automatique cyrillique → latin (système de 1992)
- 🏆 **Gamification** — XP, niveaux, séries, ligues, classement
- 🌍 **Interface multilingue** — FR / EN / RU / CE
- 🎨 **Design system bi-thème** — clair & sombre (style « Copilot »), responsive mobile/desktop
- 🔐 **Authentification** — Supabase (email + Google)

## 🛠 Stack technique

| Domaine | Technologie |
|---|---|
| Framework | Flutter / Dart |
| IA | API Anthropic Claude |
| Backend / Auth | Supabase |
| Design | Système de tokens maison (`lib/design/`) |
| Polices | Google Fonts (Playfair Display, Inter, Space Mono) |

---

## 🚀 Démarrage

### Prérequis
- [Flutter](https://docs.flutter.dev/get-started/install) 3.8 ou supérieur
- Un compte [Supabase](https://supabase.com) (gratuit)
- Une clé API [Anthropic](https://console.anthropic.com)

### 1. Cloner le projet
```bash
git clone https://github.com/DorianMuzi/LinguaCE.git
cd LinguaCE
flutter pub get
```

### 2. Configurer les secrets
Les clés ne sont **jamais** dans le code source. Copie le modèle et renseigne tes valeurs :
```bash
cp env.example.json env.json
```
Puis édite `env.json` :
```json
{
  "ANTHROPIC_API_KEY": "sk-ant-...",
  "ANTHROPIC_MODEL": "claude-haiku-4-5-20251001",
  "SUPABASE_URL": "https://votre-projet.supabase.co",
  "SUPABASE_ANON_KEY": "eyJhbG..."
}
```
> `env.json` est ignoré par git — il ne sera jamais committé.

### 3. Configurer la base de données

Le schéma complet est **versionné** dans `supabase/migrations/`. Applique-le
en une commande avec le [CLI Supabase](https://supabase.com/docs/guides/cli) :

```bash
supabase link --project-ref <ton-project-ref>   # une seule fois
supabase db push
```

Cela crée automatiquement **toutes les tables, politiques RLS, privilèges et
le catalogue de leçons** — aucun copier-coller de SQL.

> Pour réinitialiser une base locale de dev : `supabase db reset`.

### 4. Lancer l'app
```bash
flutter run --dart-define-from-file=env.json
```

> **Android Studio / VS Code** : ajoute `--dart-define-from-file=env.json`
> dans les arguments de ta configuration de lancement
> (Run > Edit Configurations > Additional run args).

---

## ⚡ Edge Functions

L'app s'appuie sur deux Edge Functions Supabase (dossier `supabase/functions/`).

### `chat` — fournie dans le dépôt ✅
Proxy serveur vers l'API Anthropic (Claude). Il garde la clé **côté serveur**
et évite les limites CORS du navigateur. Pour le déployer :

```bash
supabase functions deploy chat
supabase secrets set ANTHROPIC_API_KEY=sk-ant-...   # ta clé Anthropic
```

### `transliterate` — algorithme propriétaire, non inclus 🔒
Convertit le cyrillique tchétchène en latin (système 1992 « Muziŋ Dar »).
L'algorithme officiel est **propriétaire** et n'est pas publié. Sans cette
fonction, la translittération ne s'affiche simplement pas — **le reste de
l'app fonctionne normalement**.

Pour brancher ta propre version, déploie une fonction nommée `transliterate`
respectant ce **contrat** :

| | Format |
|---|---|
| **Entrée** (POST, JSON) | `{ "text": "Текст" }` |
| **Sortie** (JSON) | `{ "result": "Tekst" }` |

Tu es libre d'y mettre la logique de translittération de ton choix.

## 📁 Structure

```
lib/
├── config/        # Configuration & secrets (via --dart-define)
├── design/        # Design system : tokens, themes, composants, responsive
├── models/        # Modeles de donnees
├── data/          # Donnees statiques (lecons, etc.)
├── services/      # Claude, Supabase, auth, profil, chat, transliteration
├── screens/       # Ecrans (splash, auth, accueil, chat, apprendre, progres…)
├── widgets/       # Widgets partages (nav bar, drawer, xp bar)
└── main.dart      # Point d'entree
```

## 🎨 Design system

Le langage visuel repose sur des **tokens sémantiques** (`lib/design/lingua_tokens.dart`)
exposés via `ThemeExtension`. Accès dans un widget : `context.tokens.accent`.
Le thème bascule automatiquement clair/sombre et suit le réglage système.

## 🤝 Contribuer

Les contributions sont les bienvenues ! Consulte le guide
[CONTRIBUTING.md](CONTRIBUTING.md) (workflow, style, design system, contenu
linguistique) et le [Code de conduite](CODE_OF_CONDUCT.md).

En résumé : ouvre une *issue* pour discuter d'un changement, puis une
*pull request* — `flutter analyze` doit passer sans erreur, et l'app doit
rester correcte en thème clair **et** sombre.

## 📄 Licence

Distribué sous licence **Apache 2.0**. Voir [LICENSE](LICENSE).

---

<p align="center">Fait avec ❤️ pour préserver et diffuser la langue tchétchène.</p>
