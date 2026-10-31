# Dukavo Mobile

The Flutter client for **Dukavo**, the multi-tenant commerce platform for
merchants who sell and support customers over WhatsApp.

This app is the native companion to the Vue workspace in the sibling
`frontend/` repository. It talks to the same Laravel API in the sibling
`backend/` repository, under the versioned JSON surface at `/api/v1`, and
reuses the existing contracts rather than introducing mobile-only endpoints.

---

## Contents

1. [Current status](#1-current-status)
2. [Key features](#2-key-features)
3. [Technology stack](#3-technology-stack)
4. [Architecture](#4-architecture)
5. [Prerequisites](#5-prerequisites)
6. [Local setup](#6-local-setup)
7. [Configuration](#7-configuration)
8. [Authentication and tenancy](#8-authentication-and-tenancy)
9. [Localization and theming](#9-localization-and-theming)
10. [Testing and quality checks](#10-testing-and-quality-checks)
11. [Backend API integration](#11-backend-api-integration)
12. [Build and release](#12-build-and-release)
13. [Troubleshooting](#13-troubleshooting)
14. [Known limitations](#14-known-limitations)
15. [Repository layout](#15-repository-layout)
16. [License](#16-license)

---

## 1. Current status

The application is **implemented at source level** and has not yet been
compiled in the environment where it was authored. The Flutter SDK is not
installed there, and downloading it was not possible on the available network.
Consequently:

- `flutter pub get`, `flutter analyze`, `flutter test` and `flutter build` have
  **not** been run against this tree.
- Verification so far is a manual and scripted audit: imports resolve, ARB
  keys exist in both languages, provider references exist, API paths and
  resource shapes were checked against `backend/routes/api/v1.php` and
  `backend/app/Http/Resources/`.
- iOS builds require macOS and Xcode; they cannot be produced on Linux even
  with a Flutter SDK.

Run the commands in [Testing and quality checks](#10-testing-and-quality-checks)
on a machine with Flutter before treating a build as verified. The exact
delivery status is summarised in [`docs/DELIVERY_REPORT.md`](docs/DELIVERY_REPORT.md).

## 2. Key features

Everything listed here is wired to a real API route and permission.

- **Authentication and session** — Sanctum bearer-token login, CSRF-primed
  Fortify routes, token persistence in platform secure storage, silent session
  restore via `/me`, workspace onboarding, workspace switching, logout and
  password recovery.
- **Role-aware navigation** — the bottom navigation and "More" workspace are
  built from the permission slugs returned by `/me`; a screen the caller cannot
  use is not offered, and every request is still authorised by the server.
- **Dashboard** — revenue, order and stock aggregates, revenue trend, top
  products, dead stock and recent activity.
- **Catalogue** — products with variants, images, pricing and stock; category
  tree with create/edit/delete; slug availability checks.
- **Inventory** — stock levels per variant and store, low-stock filter,
  movement history, absolute adjustment, additive receiving and transfers.
- **Orders** — searchable, filterable order list, order detail with totals and
  status timeline, status transitions with optional payment marking, and a
  native order builder with customer and product pickers.
- **Customers** — searchable list, create/edit/delete and a detail view with
  contact information and order context.
- **Conversations** — inbox with status/channel/unread filters, thread view,
  replies, internal notes, approved templates, assignment, read state, retry
  and conversation creation.
- **Notifications** — unread badge, notification centre, mark read/unread,
  mark all read, delete, and per-channel preference settings that respect what
  the backend can actually deliver.
- **Analytics** — executive KPIs, sales trend, product performance, stock
  health and explicit limitations, with date-range and store filters.
- **Profile and settings** — profile editing, avatar upload/removal, password
  change, signed-in device management, workspace settings, theme and language.
- **Native UX** — Material 3 surfaces, light/dark themes, Arabic RTL and
  English LTR, pull-to-refresh, incremental pagination, skeleton/empty/error
  states and accessible form validation.

## 3. Technology stack

| Concern | Choice |
| --- | --- |
| Framework | Flutter (stable channel), Dart 3 |
| State management | Riverpod 2 (`StateNotifier`, `FutureProvider`, `Provider`) |
| Navigation | `go_router` with a single `ShellRoute` |
| HTTP | `dio` behind one `ApiClient` |
| Secure storage | `flutter_secure_storage` for the bearer token |
| Preferences | `shared_preferences` for theme, locale and tenant slug |
| Images | `cached_network_image`; `image_picker` for avatars |
| Localization | ARB assets loaded by a hand-written delegate (no codegen) |
| Tests | `flutter_test`, `mocktail`, `integration_test` |

No code generation is required: there is no `build_runner`, `freezed` or
`json_serializable` step, so a clean checkout can be opened and built without
generating files first.

## 4. Architecture

The app follows feature-first Clean Architecture. Dependencies point inward:

```
presentation  ->  application  ->  domain
                       |
                       v
                     data  ->  core
```

- **domain** — immutable entities, value objects, query objects and repository
  interfaces. It imports no Flutter, Dio or plugin package.
- **data** — JSON models, remote data sources and repository implementations.
  This is the only layer that knows endpoint paths and response envelopes.
- **application** — Riverpod providers, list notifiers, actions and screen
  state. Widgets read state and call actions; they never call Dio.
- **presentation** — screens and widgets. They receive domain objects and
  localised copy, and never parse JSON.
- **core** — transport, storage, permissions, formatting, validation,
  pagination and shared widgets.
- **app** — bootstrap, router, theme and localization wiring.

Cross-cutting rules:

- A single `ApiClient` attaches the bearer token, the `X-Tenant` header and
  `Accept-Language`, primes Sanctum's CSRF cookie, normalises the
  `{success, message, data, meta}` envelope and maps every failure to
  `ApiException`.
- Pagination is shared through `Paginated<T>`, `PaginationMeta` and
  `PaginatedNotifier<T>`, so every list has the same refresh/load-more/error
  behaviour.
- Permissions come from the session payload. Hiding a control is a courtesy;
  the server remains the security boundary.

## 5. Prerequisites

- Flutter **3.24 or newer** on the stable channel (the code targets Dart 3.5+).
- An Android SDK for Android builds, or Xcode 15+ for iOS builds.
- A running Dukavo backend. The default development URLs assume
  `php artisan serve` on port `8000`.

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

The default API base URL is chosen from the target platform:

| Target | Default base URL |
| --- | --- |
| Android emulator | `http://10.0.2.2:8000/api/v1` |
| iOS simulator | `http://127.0.0.1:8000/api/v1` |

Both are overridable at build time:

```bash
flutter run \
  --dart-define=DUKAVO_API_BASE_URL=http://192.168.1.20:8000/api/v1
```

Start the backend with CORS and Sanctum configured for the host you use. The
mobile client authenticates with a bearer token, but Fortify's login, logout,
forgot-password and reset-password routes run under the `web` middleware, so
the client first requests `/sanctum/csrf-cookie` and sends the resulting
`X-XSRF-TOKEN` header and cookies. The token returned by login is then stored in
the platform keychain/keystore and used for every other request.

### Android notes

- Application ID: `com.dukavo.mobile`.
- Cleartext HTTP is permitted only for `10.0.2.2`, `localhost` and
  `127.0.0.1` through `android/app/src/main/res/xml/network_security_config.xml`.
  Production hosts keep the platform's HTTPS-only default.
- `INTERNET` permission is declared in `android/app/src/main/AndroidManifest.xml`.

### iOS notes

- Bundle identifier: `com.dukavo.mobile`.
- The ATS exception for local HTTP is development-only; use HTTPS in release.
- Photo-library and camera usage descriptions are declared for avatar capture.

## 7. Configuration

| Setting | Where | Default |
| --- | --- | --- |
| API base URL | `--dart-define=DUKAVO_API_BASE_URL` | platform default above |
| CSRF URL | derived from the API origin | `/sanctum/csrf-cookie` |
| Theme | persisted in `shared_preferences` | system |
| Language | persisted in `shared_preferences` | device, English fallback |
| Tenant | persisted slug, sent as `X-Tenant` | first membership |
| App version | `AppConfig.appVersion` | `1.0.0` |

No secret is compiled into the app. The bearer token lives only in secure
storage, is never logged, and is cleared on logout or a `401` response.

## 8. Authentication and tenancy

1. The app boots, hydrates the token store and calls `/me` when a token exists.
2. A valid session with an active tenant goes to the dashboard.
3. A valid session without a workspace goes to workspace setup
   (`POST /onboarding/tenant`).
4. No token, or an invalid token, goes to login.
5. Login primes CSRF, exchanges credentials at `/auth/login`, stores the token
   and loads `/me`.
6. Every tenant-scoped request carries `X-Tenant`; the backend resolves it
   against the caller's memberships, so a forged value cannot widen access.
7. A `401` anywhere clears the local session and returns to login.

Workspace switching re-reads `/me` with the new `X-Tenant` value and refreshes
the permission set and navigation.

## 9. Localization and theming

- Copy lives in `lib/app/localization/l10n/app_en.arb` and `app_ar.arb`.
- Both files are bundled as assets and preloaded during bootstrap. The delegate
  is hand-written, so `flutter gen-l10n` is not required.
- A missing key renders the key itself; that is intentional, because a visible
  key in a screenshot is easier to catch than a blank label.
- Arabic sets RTL automatically through Flutter's `Directionality`; layouts use
  directional padding and alignment rather than left/right constants.
- The palette is defined once in `lib/app/theme/app_colors.dart`:
  primary `#0F766E`, primary dark `#115E59`, accent `#A3E635`, background
  `#F8FAFC`, surface `#FFFFFF`, text `#0F172A`, muted `#64748B`, border
  `#E2E8F0`.
- Theme mode (light/dark/system) and language are persisted and restored before
  the first frame.

## 10. Testing and quality checks

The repository contains:

- **Unit tests** for formatters, validators, pagination metadata, order and
  inventory JSON models, analytics query equality, auth domain objects and the
  localization delegate.
- **Widget tests** for shared widgets and the login form, including validation,
  server-error rendering and Arabic RTL copy.
- **Integration tests** in `integration_test/app_boot_test.dart` for a real
  device/emulator. The credential-based test is skipped unless
  `DUKAVO_TEST_EMAIL` and `DUKAVO_TEST_PASSWORD` are supplied.

Run them on a machine with Flutter:

```bash
cd mobile
flutter pub get
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test
flutter test integration_test/app_boot_test.dart -d <device-id>
```

The integration login test needs a reachable backend:

```bash
flutter test integration_test/app_boot_test.dart -d <device-id> \
  --dart-define=DUKAVO_API_BASE_URL=http://10.0.2.2:8000/api/v1 \
  --dart-define=DUKAVO_TEST_EMAIL=owner@example.com \
  --dart-define=DUKAVO_TEST_PASSWORD=password
```

> **Verification caveat:** these commands have not been executed in the
> authoring environment because Flutter is unavailable there. Do not treat the
> suite as green until it has been run and the output recorded.

## 11. Backend API integration

The complete endpoint-by-endpoint map — method, path, permission, mobile
feature, request payload and response shape — is in
[`docs/API_INTEGRATION_MAP.md`](docs/API_INTEGRATION_MAP.md).

In summary, the mobile client uses the existing v1 surface:

- Auth and session: `/auth/login`, `/auth/logout`, `/auth/forgot-password`,
  `/auth/reset-password`, `/me`, `/onboarding/tenant`.
- Profile: `/profile`, `/profile/avatar`, `/profile/password`,
  `/profile/sessions`, `/profile/notifications`,
  `/profile/notifications/channels`.
- Notifications: `/notifications`, `/notifications/unread-count`,
  `/notifications/read-all`, `/notifications/{id}/read|unread`.
- Workspace: `/tenant/dashboard*`, `/tenant/analytics`, `/tenant/stores`,
  `/tenant/settings`.
- Catalogue: `/tenant/products*`, `/tenant/categories*`.
- Commerce: `/tenant/orders*`, `/tenant/customers*`, `/tenant/inventory*`.
- Inbox: `/tenant/conversations*`.

Resources addressed by slug use the slug (products); order reads use the
human order number and order mutations use the numeric id; categories,
customers and conversations use numeric ids.

## 12. Build and release

Android:

```bash
flutter build appbundle --release \
  --dart-define=DUKAVO_API_BASE_URL=https://api.dukavo.com/api/v1
```

iOS (macOS only):

```bash
flutter build ipa --release \
  --dart-define=DUKAVO_API_BASE_URL=https://api.dukavo.com/api/v1
```

Before release:

- point the base URL at HTTPS;
- remove the development cleartext/ATS exceptions;
- configure signing (keystore for Android, certificates/profiles for iOS);
- verify the backend's Sanctum stateful domains and CORS settings include the
  production origin;
- run `flutter analyze` and the full test suite.

## 13. Troubleshooting

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| `10.0.2.2` connection refused | backend not running or bound to localhost only | start `php artisan serve --host=0.0.0.0` |
| `419` on login | CSRF cookie missing or blocked | confirm `/sanctum/csrf-cookie` is reachable and cookies are accepted |
| `401` immediately after login | token not stored or `/me` rejected | check secure-storage permissions and `SANCTUM_STATEFUL_DOMAINS` |
| `403` on a screen | role lacks the permission | grant the permission in the backend; the app hides what it knows is unavailable |
| Arabic layout looks mirrored incorrectly | hard-coded left/right in a new widget | use `EdgeInsetsDirectional`, `AlignmentDirectional` and `start`/`end` |
| Text renders a key such as `orders.view` | missing ARB entry | add the key to both `app_en.arb` and `app_ar.arb` |

## 14. Known limitations

The mobile app intentionally covers the merchant workflow, not every surface of
the web product. The following backend areas are **not implemented in mobile**
yet:

- platform administration (tenants, platform users, platform roles, audit);
- workspace team users, custom roles and permission editing;
- smart bundles, bundle recommendations and AI assistance;
- conversation carts/order builder, voice messages, AI reply drafts and
  summaries, recovery opportunities;
- WhatsApp account management and connection status;
- profit intelligence and exports;
- automations, audit logs, marketing content administration;
- product image upload/reorder (the API paths exist in `ApiPaths`, but no
  screen uses them yet).

Store management is read-only in mobile: the store list feeds pickers and the
order builder, but there is no create/edit/delete store screen.

These are tracked as future work, not as regressions in the implemented scope.

## 15. Repository layout

```
mobile/
├── android/                 Android host project (com.dukavo.mobile)
├── ios/                     iOS host project (com.dukavo.mobile)
├── assets/images/           Bundled image assets
├── docs/                    Integration and delivery documentation
├── integration_test/        Device/emulator end-to-end tests
├── lib/
│   ├── app/                 Router, theme, localization and app wiring
│   ├── core/                Transport, storage, auth primitives, shared UI
│   ├── features/            One folder per feature: domain/data/application/presentation
│   ├── bootstrap.dart       Dependency construction and first frame
│   └── main.dart            Entry point
├── test/                    Unit and widget tests
├── analysis_options.yaml
├── l10n.yaml
└── pubspec.yaml
```

This directory is its own Git repository. `backend/` and `frontend/` remain
independent repositories; nothing here modifies or nests inside them.

## 16. License

Proprietary. © Dukavo. All rights reserved.
