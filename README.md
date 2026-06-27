<div align="center">

<img src="assets/images/IconeApp.png" alt="LinguaCE" width="100" height="100" />

# LinguaCE

**The first AI-powered app for learning the Chechen language.**

[![CI](https://github.com/DorianMuzi/LinguaCE/actions/workflows/ci.yml/badge.svg)](https://github.com/DorianMuzi/LinguaCE/actions/workflows/ci.yml)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3-02569B?logo=flutter)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/platform-Android-3DDC84?logo=android)](#)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](#contributing)
[![Discord](https://img.shields.io/badge/Discord-join-5865F2?logo=discord&logoColor=white)](https://discord.gg/fnPmjfttc)

[Join Discord](https://discord.gg/fnPmjfttc) · [Open Issues](https://github.com/DorianMuzi/LinguaCE/issues) · [Instagram](https://www.instagram.com/lingua_ce)

</div>

## What is LinguaCE?

Duolingo supports 40+ languages. Chechen is not one of them.

LinguaCE is an open-source, Duolingo-style mobile app for learning Chechen — a
language spoken by ~1.5 million people with almost no digital learning tools. The
app is powered by Flutter, the Claude AI API, and a custom Latin transliteration
system called the **Chechen Latin Script**.

It features **Naxçi**, an AI language assistant with a deep understanding of
Chechen grammar, culture, and oral tradition.

## Features

- 🎓 **Gamified learning** — XP, streaks, 8 progression levels (Dözal → Noxčijn Mott)
- 🤖 **Naxçi AI assistant** — powered by Claude API with a Chechen-specific grammar system prompt
- 🔤 **Chechen Latin Script** — a proprietary Latin transliteration system for the Chechen language
- 🏆 **5 cultural leagues** — Stone, Forest, Mountain, Eagle, Noxčo
- 🔐 **Auth & database** — Supabase authentication and real-time data
- 📱 **Cross-platform** — Android (active), iOS and desktop (roadmap)

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile framework | Flutter 3 / Dart |
| AI assistant | Anthropic Claude API (claude-sonnet-4-5) |
| Backend & Auth | Supabase |
| Transliteration | Chechen Latin Script (proprietary) |
| Target platforms | Android · iOS · macOS · Windows · Linux |

## Roadmap

```
✅  PHASE 1 — Core
    Flutter app structure, Claude API integration (Naxçi),
    Supabase auth, Chechen Latin Script, app icon & UI

🔧  PHASE 2 — Stability (current)
    Android network fix · Live XP/streak/level data
    Profile screen · Drawer navigation · Markdown rendering

🎯  PHASE 3 — Beta
    iOS & desktop builds · Full lesson content (8 levels)
    Designer onboarding · App Store submission

🔮  PHASE 4 — Voice
    TTS/STT for Chechen (Coqui YourTTS + Whisper)
    Mozilla Common Voice · Chechen corpus
```

## 💬 Join the Community

We're building LinguaCE in the open — and we'd love you to be part of it.

Whether you're a Flutter developer, a Chechen native speaker, a designer, or just
curious — there's a place for you.

👉 **[Join the LinguaCE Discord](https://discord.gg/fnPmjfttc)**

On the server you'll find:

- **#flutter-dart** — technical discussions & bug tracking
- **#claude-api** — AI integration & Naxçi development
- **#chechen-linguistics** — language validation & corpus building
- **#chechen-latin-script** — transliteration system discussions
- **#general** — open to everyone

All skill levels welcome. All backgrounds welcome. The language belongs to everyone.

## 🤝 Open Roles

We're actively looking for contributors. All roles are volunteer-based and fully remote.

| Role | Priority | Status |
|---|---|---|
| Flutter / Dart Developer | 🔴 High | Open now |
| Chechen Linguist / Native Speaker | 🔴 High | Open now |
| UI/UX Designer (Mobile) | 🟡 Medium | Open — Beta phase |
| ML Engineer (Speech / NLP) | 🟡 Medium | Open — Phase 2 |
| Community & Growth Manager | ⚪ Later | Post-launch |

→ See full role descriptions in [CONTRIBUTING.md](CONTRIBUTING.md)
→ Or [open an issue](https://github.com/DorianMuzi/LinguaCE/issues) to introduce yourself

## Getting Started

```bash
# Clone the repo
git clone https://github.com/DorianMuzi/LinguaCE.git
cd LinguaCE

# Install dependencies
flutter pub get

# Set up environment variables (keys are never committed)
cp env.example.json env.json
# then edit env.json — add your ANTHROPIC_API_KEY and Supabase URL + anon key

# Apply the database schema (Supabase CLI)
supabase link --project-ref <your-project-ref>
supabase db push

# Run on Android
flutter run --dart-define-from-file=env.json

# Run on Chrome (web)
flutter run -d chrome --dart-define-from-file=env.json
```

> The AI chat is proxied through a Supabase Edge Function (`supabase/functions/chat`).
> Deploy it with `supabase functions deploy chat`, then
> `supabase secrets set ANTHROPIC_API_KEY=...`. See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

> ⚠️ Note: Android emulator networking requires a fix for Supabase auth — see issue #1.

## Project Structure

```
lib/
├── main.dart        # Entry point
├── config/          # App config & secrets wiring (--dart-define)
├── design/          # Design system (tokens, theme, components)
├── i18n/            # Localization (FR · EN · RU · CE)
├── screens/         # App screens (home, chat, learn, progress, profile…)
├── widgets/         # Reusable UI components
├── services/        # Claude API, Supabase, lessons, profile, chat
├── models/          # Data models (user, lesson, message…)
└── data/            # Mock / fallback data
```

## Contributing

1. Fork the repository
2. Create a branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m 'Add some feature'`
4. Push to the branch: `git push origin feature/your-feature`
5. Open a Pull Request

Please read [CONTRIBUTING.md](CONTRIBUTING.md) before submitting a PR.

## About the Language

Chechen (Нохчийн мотт / Noxçiyŋ mott) is a Northeast Caucasian language spoken
primarily in the Chechen Republic (Russia) and by a large diaspora worldwide. It
is classified as a vulnerable language by UNESCO, with limited digital resources
and almost no existing language learning tools.

LinguaCE is built with deep respect for Chechen culture, oral tradition, and the
communities working to preserve the language.

## License

This project is licensed under the **Apache License 2.0** — see the
[LICENSE](LICENSE) file for details.

The **Chechen Latin Script** transliteration system is proprietary and **not**
covered by the Apache 2.0 license.

<div align="center">

**Noxçiyŋ mott bayna djabala ca beza. 🤍**

*The Chechen language must not disappear.*

[Discord](https://discord.gg/fnPmjfttc) · [Instagram](https://www.instagram.com/lingua_ce) · [GitHub Issues](https://github.com/DorianMuzi/LinguaCE/issues)

</div>
