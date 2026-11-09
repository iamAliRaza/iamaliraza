<h1 align="center">Hi, I'm Ali Raza</h1>

<p align="center">
  <b>Mobile Product Engineer — Flutter &amp; Native Android</b>
</p>

<p align="center">
  <a href="https://iamaliraza.com"><b>iamaliraza.com</b></a> ·
  <a href="https://linkedin.com/in/aliraza--">LinkedIn</a> ·
  <a href="mailto:hello@iamaliraza.com">Email</a>
</p>

---

I own mobile products end to end, directing AI agents across development, testing, release and
automation, backed by nine years in native Android and Flutter. I'm a Senior Mobile Engineer at
**eXceeders**, where I own Android and iOS for
**PerfeXe**, an AI-powered agentic workspace platform, as the sole mobile engineer on a 7-person
product team.

### Highlights

- **Led the move to Flutter** at eXceeders, taking core StemeXe modules from proof of concept to
  production and establishing Flutter as a product-line capability.
- **One codebase, 5–7 white-labelled apps.** Rebuilt a legacy Android codebase around MVVM and Clean
  Architecture so client apps for insurance, government, real estate and fintech ship from a single
  source.
- **Migrated a live 50K+ download app to Flutter**, end to end — Pakrism, including AppsFlyer and
  Stripe integration.
- **Agentic delivery.** Direct AI agents across planning, build, testing and release with Claude Code
  and MCP, including Figma-to-code automation, with human review on every change and production
  rollout.

### Tech I work with

![Kotlin](https://img.shields.io/badge/Kotlin-7F52FF?style=flat&logo=kotlin&logoColor=white)
![Java](https://img.shields.io/badge/Java-ED8B00?style=flat&logo=openjdk&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=flat&logo=android&logoColor=white)
![Jetpack Compose](https://img.shields.io/badge/Jetpack%20Compose-4285F4?style=flat&logo=jetpackcompose&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)
![Jaspr](https://img.shields.io/badge/Jaspr-1E1E1E?style=flat)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=flat&logo=firebase&logoColor=black)
![Git](https://img.shields.io/badge/Git-F05032?style=flat&logo=git&logoColor=white)
![Claude Code](https://img.shields.io/badge/Claude%20Code-D97757?style=flat&logo=claude&logoColor=white)
![Fastlane](https://img.shields.io/badge/Fastlane-00F200?style=flat&logo=fastlane&logoColor=black)
![Codemagic](https://img.shields.io/badge/Codemagic-F45E3F?style=flat&logo=codemagic&logoColor=white)

**Architecture:** MVVM · Clean Architecture · feature-first and layer-first
**Integration:** REST · XMPP · Socket.io · Retrofit · Stripe · AppsFlyer · FCM

### Selected projects

| Project | What it is |
|---|---|
| **PerfeXe** | B2B AI-powered digital workplace that businesses roll out to their employees under their own brand. Sole mobile engineer, owning Android and iOS. |
| **StemeXe** | White-labelled B2B workplace app: 5–7 production apps from a single codebase, across insurance, government, real estate and fintech. |
| **Flutter Migration — Pakrism** | Migrated a 50K+ download production Android app to Flutter end to end, adding new feature modules, replacing Firebase Dynamic Links with AppsFlyer and integrating Stripe. |
| **E-Tijarat** | Cross-platform e-commerce app in React Native on a REST/JSON backend. |
| **Malabes** | Native Android e-commerce app integrated with WordPress through CiyaShop APIs, so admins manage products and supported UI from the WordPress panel. |
| **Location-Aware Profile Manager** | Android utility that fires actions — silent mode, Wi-Fi/Bluetooth toggles, reminders, messages — when you arrive at a pinned place, using Maps, Places and Geofencing APIs. |

---

<details>
<summary><b>About this repository</b> — the source of iamaliraza.com</summary>

<br>

This repo is both my GitHub profile README and the source of
[iamaliraza.com](https://iamaliraza.com): a single-page portfolio built with **Flutter Web**.

- **Layer-first architecture** — `presentation → domain → data`, with shared `core` tokens for every
  colour, text style, spacing value and UI string. All real content lives in one content file, so
  content changes never touch widget code.
- **State & DI** with GetX; content is compile-time `const` entities behind a repository
  interface — no database, no codegen, nothing to load before the first frame.
- **Responsive** across mobile, tablet and desktop breakpoints, inside a 1440px canvas.
- **Ambient "living architecture" background** — clustered nodes, links, arcs and travelling pulses
  drawn by a single `CustomPainter` with zero widget rebuilds per frame. Honours reduced-motion and
  holds display refresh rate in release builds.
- **Built with an AI-assisted workflow** — Claude Code plus a Figma MCP server.
  [`CLAUDE.md`](https://github.com/iamAliRaza/iamaliraza/blob/main/CLAUDE.md) documents the
  project's conventions for both humans and agents.

UI based on the Figma Community template "Developer Personal Portfolio".

**Run locally**

```bash
flutter pub get
flutter run -d chrome      # dev, with hot reload
flutter build web          # production build -> build/web
```

</details>
