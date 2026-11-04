# Dukavo Mobile

The Flutter client for **Dukavo**, the multi-tenant commerce platform for
merchants who sell and support customers over WhatsApp.

The app is the native companion to the Vue workspace and public site in the
sibling `frontend/` repository, and talks to the same Laravel API in the
sibling `backend/` repository at `/api/v1`. It reuses the existing contracts,
permissions and business rules; it does not contain a second API or fake data.

---

## Contents

1. [Status](#1-status)
2. [What the app covers](#2-what-the-app-covers)
3. [Technology](#3-technology)
4. [Architecture](#4-architecture)
5. [Prerequisites](#5-prerequisites)
6. [Local setup](#6-local-setup)
7. [Configuration](#7-configuration)
8. [Authentication and tenancy](#8-authentication-and-tenancy)
9. [Localization and theming](#9-localization-and-theming)
10. [Testing and quality](#10-testing-and-quality)
11. [Build and release](#11-build-and-release)
12. [Documentation](#12-documentation)
13. [Troubleshooting](#13-troubleshooting)
14. [Known gaps](#14-known-gaps)
15. [Repository layout](#15-repository-layout)
16. [License](#16-license)

---

## 1. Status

Source-level verification in this workspace (Flutter 3.47.9 / Dart 3.13.7):

- `flutter pub get` resolves all dependencies.
- `dart format --output=none --set-exit-if-changed lib test integration_test`
  is clean.
- `flutter analyze` reports **No issues found**.
- `flutter test` passes **118 unit and widget tests**.
- Both ARB files contain **871 keys** with identical key sets.
- Android debug APK build status and exact commands are recorded in
  [`BUILD_AND_RELEASE.md`](BUILD_AND_RELEASE.md). iOS builds require macOS and
  Xcode and are not produced on this Linux host.
- The device integration test requires a booted emulator/device and a reachable
  backend; it is not run on this host.

The endpoint-by-endpoint coverage matrix, including honest gaps and
not-applicable decisions, is in
[`WEB_TO_MOBILE_PARITY.md`](WEB_TO_MOBILE_PARITY.md).

## 2. What the app covers

Every screen below calls a real Laravel endpoint and respects the server's
permission gate.

### Merchant workspace

- **Dashboard and analytics** — revenue, orders, stock, trends, top products,
  dead stock, date-range/store filters, explicit limitations.
- **Catalogue** — products with variants, pricing, stock and images (upload,
  reorder, delete); category tree; slug availability; bundles.
- **Inventory** — stock per variant/store, low-stock filter, movement history,
  adjustments, receiving, intelligence overview/detail and CSV export.
- **Orders** — searchable/filterable list, detail, status transitions, payment
  marking and a native order builder.
- **Customers** — searchable list, create/edit/delete, contact and order
  context.
- **Conversations** — inbox filters, thread, replies, internal notes, approved
  templates, assignment, read state and retry.
- **Growth** — lost-sale recovery (summary, filters, AI draft, dismiss,
  do-not-contact), WhatsApp accounts (CRUD, verify, disconnect), AI action
  approvals (submit/approve/reject/execute) and automations (rules, runs,
  human tasks).
- **Reporting** — profit overview with filters and CSV export.
- **Stores** — list, create/edit/delete, make default.
- **Storefront, delivery and payments** — per-store storefront settings,
  shipping zones with fees/free-delivery thresholds, cash-on-delivery settings;
  online payment is shown unavailable with the server's reason.
- **Team and access** — users, custom roles, grouped permission editor, audit
  log.
- **Account** — profile, avatar, password, signed-in devices, notification
  preferences, theme, language and workspace settings.

### Platform console

A separate five-tab shell for platform operators: dashboard; tenants (CRUD,
suspend/activate, members); platform users (CRUD, role assignment); marketing
(pricing plans, FAQ, content pages, newsletters, waitlist, contact messages,
subscribers); and access control (roles/permissions, audit log). Platform-only
operators are never sent to tenant onboarding.

### Public marketing site

Native home, features, pricing, FAQ, newsletter index/article, contact,
waitlist and long-form content pages (about, privacy, terms). Content comes
from the same public API as the Vue site.

### Public storefront

`/shop/:tenantSlug/:storeSlug` works without a session: store home and product
grid, product detail with variants, client-side cart, checkout with
zone-derived city/area and idempotency key, order confirmation by opaque
token, and a tracking form that accepts a bare token or a pasted tracking link.
The server resolves all prices, shipping, discounts and totals.

### Native UX

Material 3 light/dark themes, Arabic RTL and English LTR, pull-to-refresh,
incremental pagination, skeleton/empty/error states, accessible validation,
confirmation dialogs and role-aware navigation.

## 3. Technology

| Concern | Choice |
| --- | --- |
| Framework | Flutter stable, Dart 3 |
| State | Riverpod 2 (`Provider`, `FutureProvider`, `StateNotifier`) |
| Navigation | `go_router` with merchant, platform, shop and marketing shells |
| HTTP | `dio` behind one `ApiClient` |
| Secure storage | `flutter_secure_storage` for the bearer token |
| Preferences | `shared_preferences` for theme, locale and tenant slug |
| Images | `cached_network_image`; `image_picker` for avatar/product images |
| Localization | ARB assets parsed by a hand-written delegate (no codegen) |
| Tests | `flutter_test`, `mocktail`, `integration_test` |

No `build_runner`, `freezed`, `json_serializable` or `gen-l10n` step is
required. A clean checkout can be analyzed and tested immediately after
`flutter pub get`.

## 4. Architecture

Feature-first Clean Architecture: `presentation → application → domain`, with
`data → core` for transport and storage. A single `ApiClient` owns the bearer
token, `X-Tenant`, CSRF priming, `Accept-Language`, response envelopes, raw
downloads and `ApiException` mapping. `PaginatedNotifier` gives every list the
same refresh/search/filter/load-more/error behaviour.

A generic resource engine (`core/resources/`) drives list → detail → form →
delete admin surfaces from declarative `ResourceSpec`s, while bespoke screens
handle dashboards, profit, inventory intelligence, recovery, checkout and the
public site.

See [`ARCHITECTURE.md`](ARCHITECTURE.md) for layer rules, routing redirects,
the permission model, storefront rules and an extension guide.

## 5. Prerequisites

- Flutter 3.24+ on the stable channel (the code targets Dart 3.5+).
- Android SDK for Android builds, or Xcode 15+ on macOS for iOS builds.
- A running Dukavo backend. Development defaults assume `php artisan serve`
  on port `8000`.
- JDK 17 for the Android Gradle build.

Check the toolchain:

```bash
flutter --version
flutter doctor -v
```

## 6. Local setup

```bash
cd mobile
flutter pub get
flutter run
```

Default API base URLs:

| Target | Base URL |
| --- | --- |
| Android emulator | `http://10.0.2.2:8000/api/v1` |
| iOS simulator | `http://127.0.0.1:8000/api/v1` |

Override at build time:

```bash
flutter run \
  --dart-define=DUKAVO_API_BASE_URL=http://192.168.1.20:8000/api/v1
```

Start the backend with CORS and Sanctum configured for the host you use. The
client primes `/sanctum/csrf-cookie` for Fortify's web-guarded login/logout/
forgot-password routes, then stores the returned bearer token in the platform
keychain/keystore.

### Android notes

- Application ID: `com.dukavo.mobile`.
- Cleartext HTTP is permitted only for `10.0.2.2`, `localhost` and
  `127.0.0.1` through
  `android/app/src/main/res/xml/network_security_config.xml`. Production hosts
  keep the HTTPS-only default.
- `INTERNET` permission is declared in
  `android/app/src/main/AndroidManifest.xml`.

### iOS notes

- Bundle identifier: `com.dukavo.mobile`.
- The ATS exception for local HTTP is development-only; use HTTPS in release.
- Photo-library and camera usage descriptions are declared for image capture.

## 7. Configuration

| Setting | Where | Default |
| --- | --- | --- |
| API base URL | `--dart-define=DUKAVO_API_BASE_URL` | platform default above |
| Public web/shop URL | `--dart-define=DUKAVO_WEB_BASE_URL` | derived from the API origin |
| CSRF URL | derived from the API origin | `/sanctum/csrf-cookie` |
| Theme | persisted in `shared_preferences` | system |
| Language | persisted in `shared_preferences` | device, English fallback |
| Tenant | persisted slug, sent as `X-Tenant` | first membership |
| App version | `AppConfig.appVersion` | `1.0.0` |

No secret is compiled into the app. The bearer token lives only in secure
storage, is never logged, and is cleared on logout or `401`.

## 8. Authentication and tenancy

1. Boot hydrates the token store and calls `/me` when a token exists.
2. A valid session with an active tenant goes to the first permitted merchant
   screen.
3. A valid session without a workspace goes to workspace setup
   (`POST /onboarding/tenant`).
4. A platform-only operator goes to `/platform/dashboard`, never to tenant
   setup.
5. No token or an invalid token goes to login.
6. Login primes CSRF, exchanges credentials at `/auth/login`, stores the token
   and loads `/me`.
7. Every tenant request carries `X-Tenant`; the backend resolves it against the
   caller's memberships, so a forged value cannot widen access.
8. A `401` anywhere clears the local session and returns to login.

Workspace switching re-reads `/me` with the new `X-Tenant`, replaces the
permission set and invalidates tenant-scoped caches before the new scope
renders.

## 9. Localization and theming

- Copy lives in `lib/app/localization/l10n/app_en.arb` and `app_ar.arb`.
  Both have 871 keys and identical key sets, enforced by tests.
- The delegate is hand-written and preloads both ARB assets during bootstrap;
  `flutter gen-l10n` is not required.
- A missing key renders the key itself, making omissions visible in review.
- Arabic sets RTL automatically; layouts use directional padding,
  `AlignmentDirectional` and `start`/`end`.
- The palette is defined once in `lib/app/theme/app_colors.dart` (primary
  `#0F766E`, accent `#A3E635`, light/dark surfaces and borders).
- Theme mode and language persist and are restored before the first frame.

## 10. Testing and quality

```bash
cd mobile
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test
```

Coverage includes:

- **Unit** — formatters, validators, pagination metadata, JSON models for
  orders, inventory, customers, payments, shipping, storefront, shop and
  marketing, analytics queries, auth domain, platform dashboard parsing, cart
  notifier and ARB parity.
- **Widget** — shared widgets, login validation/server errors/Arabic RTL,
  payment settings and shipping zones.
- **Integration** — `integration_test/app_boot_test.dart` on a real
  device/emulator. Credential login runs only when `DUKAVO_TEST_EMAIL` and
  `DUKAVO_TEST_PASSWORD` are supplied.

Device integration test:

```bash
flutter test integration_test/app_boot_test.dart -d <device-id> \
  --dart-define=DUKAVO_API_BASE_URL=http://10.0.2.2:8000/api/v1 \
  --dart-define=DUKAVO_TEST_EMAIL=owner@example.com \
  --dart-define=DUKAVO_TEST_PASSWORD=password
```

> **Current result:** `flutter analyze` reports no issues and `flutter test`
> passes all 118 unit/widget tests. Device integration tests still require an
> emulator/device and a reachable backend.

## 11. Build and release

Android debug and release instructions, signing setup, environment checks and
the exact verification log are in
[`BUILD_AND_RELEASE.md`](BUILD_AND_RELEASE.md).

Quick start:

```bash
flutter build apk --debug
flutter build appbundle --release \
  --dart-define=DUKAVO_API_BASE_URL=https://api.dukavo.com/api/v1
```

Before release: point the base URL at HTTPS, remove development cleartext/ATS
exceptions, configure signing, verify Sanctum/CORS for the production origin,
and run analyze + tests.

## 12. Documentation

| Document | Purpose |
| --- | --- |
| [`ARCHITECTURE.md`](ARCHITECTURE.md) | Layers, routing, state, resource engine, storefront, extension guide |
| [`WEB_TO_MOBILE_PARITY.md`](WEB_TO_MOBILE_PARITY.md) | Web ↔ mobile feature/endpoint matrix, gaps, not-applicable decisions |
| [`BUILD_AND_RELEASE.md`](BUILD_AND_RELEASE.md) | Toolchain, signing, build commands, verification results |
| [`docs/API_INTEGRATION_MAP.md`](docs/API_INTEGRATION_MAP.md) | Earlier endpoint map (kept for reference; parity doc is authoritative for coverage) |
| [`docs/DELIVERY_REPORT.md`](docs/DELIVERY_REPORT.md) | Earlier delivery snapshot (superseded by this README and the parity doc) |

## 13. Troubleshooting

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| `10.0.2.2` connection refused | backend not running or bound to localhost only | `php artisan serve --host=0.0.0.0` |
| `419` on login | CSRF cookie missing/blocked | confirm `/sanctum/csrf-cookie` is reachable and cookies are accepted |
| `401` after login | token not stored or `/me` rejected | check secure storage and `SANCTUM_STATEFUL_DOMAINS` |
| `403` on a screen | role lacks the permission | grant it in the backend; the app hides what it knows is unavailable |
| Arabic layout mirrored incorrectly | hard-coded left/right in a new widget | use `EdgeInsetsDirectional`, `AlignmentDirectional`, `start`/`end` |
| Text renders a key such as `orders.view` | missing ARB entry | add it to both ARB files |
| Gradle runs out of memory | `org.gradle.jvmargs=-Xmx8G` on a small host | lower it in `android/gradle.properties` or set `GRADLE_OPTS` |
| Android build cannot find SDK/JDK | `ANDROID_HOME`/`JAVA_HOME` unset | see [`BUILD_AND_RELEASE.md`](BUILD_AND_RELEASE.md) |

## 14. Known gaps

The app covers the merchant, platform, marketing and storefront surfaces
broadly, but a few web workflows are not yet native. They are listed with
rationale in
[`WEB_TO_MOBILE_PARITY.md`](WEB_TO_MOBILE_PARITY.md#8-remaining-gaps-and-rationale):

- conversation carts, voice messages and AI reply drafts/summaries/copilot;
- customer CRM timeline/memories and AI summary;
- merchant AI copilot/insights and store currency conversion;
- inventory transfers;
- platform AI content tools, newsletter slug check and inline content images;
- email-verification screen (verification links complete on web today).

Online payments are unavailable because the backend has no provider or
transaction ledger; cash on delivery is the only method, and the app reports
the server's reason for every unavailable method.

These are future work, not hidden regressions: no fake API, dummy business data
or client-side price calculation is used to fill them.

## 15. Repository layout

```
mobile/
├── android/                 Android host project (com.dukavo.mobile)
├── ios/                     iOS host project (com.dukavo.mobile)
├── assets/images/           Bundled image assets
├── docs/                    Earlier integration/delivery documents
├── integration_test/        Device/emulator end-to-end tests
├── lib/
│   ├── app/                 Router, theme, localization and app wiring
│   ├── core/                Transport, storage, permissions, resource engine, shared UI
│   ├── features/            One folder per feature (domain/data/application/presentation)
│   ├── bootstrap.dart       Dependency construction and first frame
│   └── main.dart            Entry point
├── test/                    Unit and widget tests
├── ARCHITECTURE.md
├── BUILD_AND_RELEASE.md
├── WEB_TO_MOBILE_PARITY.md
├── analysis_options.yaml
├── l10n.yaml
└── pubspec.yaml
```

This directory is its own Git repository. `backend/` and `frontend/` remain
independent repositories.

## 16. License

Proprietary. © Dukavo. All rights reserved.
