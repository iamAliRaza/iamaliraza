# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Personal portfolio site built with Flutter, **targeting web only**. No ios/android/macos/linux/windows
platform folders exist in this repo — only `web/`. Do not run `flutter create --platforms=...` to add
other platforms unless explicitly asked; keep code and dependencies web-compatible (avoid
`dart:io`, plugins without web support, etc.). Toolchain: Flutter stable (3.47.x), Dart SDK
`^3.12.2`.

The portfolio UI is built from a Figma Community template ("Developer Personal Portfolio"). It's a
single scrolling page — pinned NavBar, Hero, About, How I Build, Experience, Projects, Contact, Footer — over an animated
ambient background. Content is centred in a max-1440px canvas and is **responsive** across three
tiers (mobile / tablet / desktop) — see "Responsive layout" below.

Content lives in `lib/data/datasources/portfolio_content.dart` — that's the file to edit for any
content change; no widget code should need to change alongside it. Content decisions are kept in a
local, uncommitted file (`CLAUDE.local.md`); read it before changing content, and keep that kind of
note out of committed files. How the content is modelled:
- **Hero:** `Profile.roleTitle` is the honorific rendered muted before the uppercased name, and
  `Profile.headline` is the role line beneath it. `Profile.stats` are the figures under the buttons.
- **Projects:** two rows by `ProjectCategory`. A project with a `ProjectShowcase` (Featured) gets a
  cover card that opens `project_details_dialog.dart`, with a gallery and `StoreLink`s. One without
  (Earlier Work) gets a text card with no tap action. `ProjectsSection` hides a row when its list is
  empty. Each `*_cover.jpg` is 3 store frames composed on black at 1024×500.
- **Experience:** one `ExperienceEntry` per company with its `ExperienceRole`s inside, newest first.
- **Skills:** `portfolioSkillGroups`, shown by `about/skills_panel.dart` in three levels: a highlighted
  **spotlight** card (logos tinted white), **tiles** (brand colours, one row scrolling sideways) and
  quiet **list** cards.
- **Logos:** mobile logos come from devicon's CDN (`cdn.jsdelivr.net/gh/devicons/devicon/...`), AI and
  social ones from Simple Icons (`cdn.jsdelivr.net/npm/simple-icons/icons/...`), Riverpod's from
  riverpod.dev and Jaspr's from that project's repo. A spotlight skill with no published logo shows a
  neutral Material icon.
- **Header logo:** `assets/icons/brand/logo.svg`, an A and R joined into one line mark, matching the
  favicon. It scrolls to top.
- The hero photo is rendered through a grayscale `ColorFilter.matrix`.

## Commands

```bash
flutter pub get                                          # install dependencies
flutter run -d chrome                                     # run with hot reload in Chrome
flutter run -d chrome --release                           # use this (not debug) for any perf/fps judgement
flutter build web                                          # production build -> build/web
flutter analyze                                             # static analysis (uses analysis_options.yaml / flutter_lints)
dart format .                                               # format
```

There is no separate lint/format script — `flutter analyze` and `dart format .` cover linting and
formatting, using the default `flutter_lints` rule set (see `analysis_options.yaml`).

There is no test suite in this repo (no `test/` directory, no `flutter_test` dependency) — this is
a deliberate choice, not an oversight. Don't add one back without being asked.

## Architecture

This project applies **Clean Architecture's dependency rule in a layer-first folder structure**
(code under `lib/` is grouped by technical responsibility, not by feature):

```
presentation ──▶ domain ◀── data        core is shared code available to all three
```

`domain` depends on nothing. It defines the entities and the `PortfolioRepository` contract, `data`
implements that contract, and `presentation` uses only the contract. `HomeBinding` is the composition
root and the one place in `presentation` that imports `data`. Use cases and DTOs are deliberately
omitted: there is no business logic beyond fetch/filter and no external data format to translate.

### `lib/core/` — single source of truth (colors, dimensions, strings, breakpoints)

- `theme/app_colors.dart`, `theme/app_text_styles.dart`, `theme/app_theme.dart` — every color and
  text style used anywhere in the app, plus the Material 3 dark `ThemeData` built from them.
  Widgets must never inline a `Color(...)` / `Colors.x` or a raw font size — always
  `AppColors.x` / `AppTextStyles.x` (add a new token there if one is missing). Font is
  **Plus Jakarta Sans** via `google_fonts` (`GoogleFonts.plusJakartaSans` /
  `plusJakartaSansTextTheme`). `AppColors` also holds the background layer's base greys
  (`networkNode` / `networkLine` / `networkAccent`); their alpha comes from the background config.
- `constants/app_dimensions.dart` — spacing scale (`spaceXs`…`spaceXxl`), radii, fixed component
  sizes (nav height, skill tile, project card, footer glyphs, per-breakpoint hero photo sizes).
  Same rule: no raw numbers for spacing/radius/sizes in widgets.
- `constants/app_strings.dart` — UI text only (nav labels, headings, button labels, footer chrome)
  as the base `'en_US'` map. **Never** the portfolio's real content (name, bio, projects, etc.) —
  that lives in the data layer instead, so it can be swapped without touching UI code.
- `localization/app_translations.dart`, `localization/app_locales.dart` — GetX `Translations`
  scaffold. Only English is populated; UI text is looked up as `'key'.tr` in widgets. Adding a
  language means adding its map alongside `appStringsEnUS` and registering it in
  `AppTranslations.keys`.
- `responsive/app_breakpoints.dart`, `responsive/responsive_context.dart` — see below.

### Responsive layout

- Breakpoints live only in `AppBreakpoints`: `mobile = 600`, `desktop = 1024`, `wide = 1280` (all
  Featured project cards side by side).
- Widgets branch via the `ResponsiveContext` extension on `BuildContext`: `context.isMobile`
  (< 600), `context.isTabletOrBelow` (< 1024), `context.isDesktop` (≥ 1024), `context.screenWidth`.
  These read the **full viewport** (`MediaQuery.sizeOf`), not local constraints — fine for
  page/section-level widgets, but re-check that assumption before reusing a section widget inside
  a narrower container.
- Current behaviour per section:
  - **NavBar** — logo on the left at every size; desktop shows inline links on the
    right; tablet-and-below collapses them into a hamburger that
    opens a `Get.bottomSheet` menu (`_MobileNavMenu`), which closes before scrolling (250ms delay
    so `ensureVisible` doesn't run mid-close-animation).
  - **Hero** — row (text 3 : photo 2) on tablet+desktop, stacked + centred on mobile; photo is
    552 / 320 / 220px by tier, shrinking to its column so it stays a circle.
  - **About** — Education/Certifications cards side-by-side (equal height via `IntrinsicHeight`)
    on desktop, stacked on tablet-and-below.
  - **Contact** — one card; the two buttons sit in a `Wrap`, and card padding drops on mobile.
  - Page horizontal padding is `spaceMd` on mobile, `spaceXl` otherwise (`HomeScreen`).
  - The background picks node density, pulse rate and parallax (desktop only) from the same
    breakpoints.

### `lib/domain/` — plain Dart, zero third-party deps

- `entities/` — `Profile`, `SocialLink` (+ `SocialPlatform` enum), `Skill`, `EducationEntry`,
  `SkillGroup`, `CertificationEntry`, `ExperienceEntry` (+ `ExperienceRole`), `WorkflowOverview` (+ `WorkflowStage`), `Project` (+ `ProjectCategory` enum, `ProjectShowcase`,
  `StoreLink`).
- `repositories/portfolio_repository.dart` — the one abstract contract the data layer implements.
  No separate UseCase classes — there's no real business logic beyond fetch/filter, so
  presentation depends directly on this abstraction.

### `lib/data/` — compile-time content behind the domain contract

- `datasources/portfolio_content.dart` — **the real content**, as top-level `const` domain
  entities (`portfolioProfile`, `portfolioSocialLinks`, `portfolioWorkflow`, `portfolioSkillGroups`,
  `portfolioExperience`, `portfolioEducation`, `portfolioCertifications`, `portfolioProjects`). Enums are used directly
  (`SocialPlatform.github`, `ProjectCategory.featured`), so typos fail at compile time. This is
  the one file to edit when content changes; no widget code should need to change, and widgets
  never import it directly.
- `repositories/portfolio_repository_impl.dart` — implements `PortfolioRepository` by returning
  those constants synchronously; `getProjects({category})` does the filtering.
- **No storage layer, deliberately.** The content is static and nothing persists between visits,
  so there are no DTO models, no local DB and no codegen. Hive was used here originally (seeded
  into IndexedDB and wiped on every start) and was removed as pure overhead before the first
  deploy. Don't reintroduce a local DB or a model/DTO layer without a real persistence need —
  `PortfolioRepository` is already the seam where a CMS/JSON source would plug in.

### `lib/presentation/` — GetX (state, DI, navigation)

- `controllers/portfolio_section.dart` — `enum PortfolioSection { home, about, experience, projects, contact }`.
- `controllers/home_controller.dart` (`GetxController`) — owns the page `ScrollController` and a
  `GlobalKey` per `PortfolioSection`. `scrollTo(section)` runs `Scrollable.ensureVisible`, which
  already stops below the pinned nav sliver, so don't add a manual offset.
  A scroll listener keeps `activeSection` (an `Rx`) on the section being read, which bolds its
  desktop nav link. How I Build has no key, so it counts as part of About.
- `bindings/home_binding.dart` — registers `PortfolioRepository` (→ `PortfolioRepositoryImpl`) and
  `HomeController` via `Get.lazyPut`. Section widgets are `StatelessWidget`s that call
  `Get.find<PortfolioRepository>()` / `Get.find<HomeController>()` directly in `build`.
- `screens/home_screen.dart` — a `Stack` of (1) the ambient background, wrapped in
  `IgnorePointer` + `RepaintBoundary`, under (2) a `CustomScrollView` whose first sliver is a
  **pinned `SliverPersistentHeader` holding the NavBar** (opaque `navBackground`), followed by one `SliverToBoxAdapter`
  column of every section inside `ConstrainedBox(maxWidth: AppDimensions.canvasWidth)`. Each
  section with a nav target is wrapped in a `KeyedSubtree` with its controller key (How I Build and
  the Footer have none). The nav is deliberately a sliver
  inside the same scrollable, **not** a `Stack` overlay — an overlay sat in a separate hit-test
  tree and swallowed mouse-wheel scrolling wherever it covered the page. `HomeScreen` is a
  `StatefulWidget` purely to own the pointer `ValueNotifier` (fed by a non-opaque `MouseRegion`)
  that drives the background's parallax — deliberately *not* `setState`, so mouse movement never
  rebuilds the page.
- `widgets/` — one subfolder per section (`navbar/`, `hero/`, `about/`, `how_i_build/`, `experience/`, `projects/`, `contact/`,
  `footer/`), plus `common/` for cross-section pieces:
  - `HoverBuilder` — `MouseRegion` + `isHovered` rebuild; the shared mechanism behind every widget
    that mirrors a Figma default/hover variant pair (nav links, buttons, chips, cards, badges).
    Use it for any new hover state rather than hand-rolling a `MouseRegion`.
  - `GlassCard` — translucent bordered card, optional `enableHoverGlow`.
  - `PillButton` — pill CTA; each caller passes its own Figma hover variant
    (`hoverBackgroundColor` / `hoverBorder` / `hoverTextStyle`) since they differ per button.
  - `HorizontalScrollList` — horizontal `SingleChildScrollView` that also allows **mouse
    click-drag** (Flutter's default scroll behaviour doesn't), with padding applied inside the
    scrollable so items clip at the card border. On tablet/desktop it overlays arrow buttons, shown
    only when there's more to scroll that way. Used for project rows, the Mobile skills row and the dialog gallery.
  - `CursorFollower` — the small dot that chases the mouse. It wraps the app in `main.dart` (above
    the Navigator, so it works over dialogs), has its own ticker and painter so it never rebuilds
    the page, stops when settled, and ignores touch and reduced-motion users.
  - `BulletText` (one bulleted line with a hanging indent), `SectionHeading`, and `AppAssetImage`
    (see Assets).
- Links open through `common/open_external_url.dart` (`url_launcher`, external application) from
  `common/social_icon_row.dart` (hero and contact), the "Email me" button and the project details dialog's store
  button.
- `widgets/background/` — `ArchitectureBackground`, the decorative "living architecture" layer
  behind everything (clustered nodes, sparse links, a few large arcs, soft grayscale atmosphere,
  drifting with occasional node activations and multi-hop pulses). **Every knob lives in
  `architecture_background_config.dart`** — tune there, not in the painter (safe direction is
  *down*). Ground rules if you touch it: one `AnimationController` / one `CustomPaint` / one
  `CustomPainter` and never a widget per node; the painter repaints via
  `super(repaint: listenable)` so animation frames cause zero widget rebuilds; the composition
  (clusters/nodes/edges/arcs/shaders) is rebuilt only on viewport resize, never per frame; no
  `saveLayer`, blur, shadow or clipping anywhere. It honours the OS reduced-motion setting
  (`MediaQuery.disableAnimationsOf`, `respectReducedMotion`) and dims nodes behind text areas
  (`textAreaDimming`). Cluster centres in `_wideClusters` intentionally avoid the portrait disc —
  a cluster centred under it just gets its candidates rejected and thins the network instead of
  filling anything. Measured in a release build at 75fps (display refresh) with zero frames over
  20ms, idle and under scroll+parallax.
- `main.dart` is just `void main() => runApp(const MyApp());` — no async bootstrap. `MyApp` wires
  `GetMaterialApp(theme: AppTheme.dark, translations: AppTranslations(),
  initialBinding: HomeBinding(), home: HomeScreen())`.

### Assets

Committed under `assets/images/{profile,projects}/` and
`assets/icons/{social,skills,flags,brand}/` (declared via directory-level entries in `pubspec.yaml` —
every listed directory must exist or the build fails, and entries aren't recursive, so
`assets/images/projects/` stays flat: `<app>_cover.jpg`, `<app>_01.jpg…`, `<app>_play_qr.svg`,
`<app>_ios_qr.svg`). The QR SVGs are static and point at the store listings; don't tint them or
they won't scan. Icon sources are listed under Project above; `profile_photo.jpg` is not a Figma asset. `assets/icons/flags/pk.png` is the footer's Pakistan flag — a PNG on purpose, because the
available Pakistan flag SVGs use transforms/clipPaths that `flutter_svg` renders wrong. The footer
also reuses `icons/skills/flutter.svg` for its "Built in Flutter" glyph.

`AppAssetImage` (`lib/presentation/widgets/common/app_asset_image.dart`) renders SVG via
`flutter_svg` and everything else via `Image.asset`, with an `errorBuilder` fallback icon for any
path that 404s. It also takes an optional
`color` — the social icon SVGs are dark-stroke assets tinted white via `ColorFilter` at the
call site (`SocialIconRow`) rather than needing a separate light-colored asset. The
hero photo uses its own `Image.asset` (not `AppAssetImage`) so its glow + grayscale can fade in
with the image via `frameBuilder`.

### Figma MCP (local desktop server)

This project uses Figma's **local desktop MCP server**, not the remote `mcp.figma.com` one:
- Registered in local scope (private, in `~/.claude.json` for this project — not committed) as
  `figma-dev-mode` → `http://127.0.0.1:3845/mcp`. The Figma plugin
  (which brings the remote server) is disabled in `.claude/settings.json`.
- The **Figma desktop app must be running** with its MCP server enabled; it works against the
  file/frame currently open/selected in the app, or a pasted Figma link.
- Design tools are read-only: `get_design_context`, `get_screenshot`, `get_metadata`,
  `get_variable_defs`, `get_figjam`, `get_motion_context`. It also has Code Connect tools, some of
  which write mappings. There is no `download_assets` tool, and it can't edit designs.
- Asset URLs it returns are `localhost:3845` URLs that only resolve while the app is running —
  download the bytes into `assets/` and commit them; never reference those URLs from code.
- Treat `get_design_context` output as a reference: map it onto the existing `AppColors` /
  `AppTextStyles` / `AppDimensions` tokens and `common/` widgets rather than pasting its values in.

### Web shell

- `web/index.html` — standard Flutter bootstrap plus a custom black splash spinner that covers the
  engine download and removes itself once `flutter-view` / `flt-glass-pane` mounts (15s fallback).
- `web/index.html` also carries the page title, description, canonical URL, Open Graph/Twitter tags,
  Person structured data and a `<noscript>` fallback. Keep them in step with the hero positioning.
- `web/_headers` — security headers for Cloudflare Pages.
- `web/manifest.json`, `web/icons/`, `web/favicon.png` — the AR ligature logo, white on black.
  `web/og-image.jpg` is the 1200×630 link-preview image.
- `.github/workflows/deploy.yml` builds on every push to `main` and deploys `build/web` to the
  `iamaliraza` Cloudflare Pages project. The deploy step skips until the `CLOUDFLARE_API_TOKEN` and
  `CLOUDFLARE_ACCOUNT_ID` repository secrets exist.
- `.metadata` — Flutter tooling bookkeeping (tracks SDK revision per platform); not for manual edits.

### README.md is Ali's GitHub profile

The repo is `github.com/iamAliRaza/iamaliraza` — named after his username, so GitHub renders
`README.md` at the top of his **profile page**. Treat it as public, profile-first copy, not
project docs: intro, highlights, stack, selected projects, contact links, then a collapsed
`<details>` "About this repository" block for the tech write-up. Rules:
- Use **absolute** `https://github.com/iamAliRaza/iamaliraza/blob/main/...` URLs for repo files —
  relative links break when the README renders on the profile page.
- Content must match `portfolio_content.dart`, with no invented claims.
- Keep detailed conventions here in CLAUDE.md, not in the README.
