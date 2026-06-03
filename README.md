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

### 3. Configurer la base Supabase
Dans le **SQL Editor** de ton projet Supabase, exécute :

```sql
-- Table des profils
create table if not exists public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  username    text not null,
  xp          integer not null default 0,
  level       integer not null default 1,
  streak      integer not null default 0,
  lessons_completed integer not null default 0,
  league      text not null default 'Aigle',
  interface_language text not null default 'FR',
  last_activity timestamptz,
  created_at  timestamptz default now()
);
alter table public.profiles enable row level security;
create policy "Profil visible par son proprietaire"
  on public.profiles for select using (auth.uid() = id);
create policy "Profil modifiable par son proprietaire"
  on public.profiles for update using (auth.uid() = id);
create policy "Profil creable a l'inscription"
  on public.profiles for insert with check (auth.uid() = id);

-- Table des messages de chat
create table if not exists public.chat_messages (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users(id) on delete cascade,
  role        text not null check (role in ('user', 'assistant')),
  content     text not null,
  created_at  timestamptz default now()
);
alter table public.chat_messages enable row level security;
create policy "Messages visibles par leur auteur"
  on public.chat_messages for select using (auth.uid() = user_id);
create policy "Messages creables par leur auteur"
  on public.chat_messages for insert with check (auth.uid() = user_id);
create policy "Messages supprimables par leur auteur"
  on public.chat_messages for delete using (auth.uid() = user_id);
```

### 4. Lancer l'app
```bash
flutter run --dart-define-from-file=env.json
```

> **Android Studio / VS Code** : ajoute `--dart-define-from-file=env.json`
> dans les arguments de ta configuration de lancement
> (Run > Edit Configurations > Additional run args).

---

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
