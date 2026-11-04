# Dukavo Mobile — Delivery Report

> **Historical snapshot (2026-11-02).** This report predates the platform,
> merchant-growth, marketing and public-storefront work. Current status:
> `flutter analyze` clean, **113 tests passing**, 862 ARB keys per locale, and
> the authoritative coverage matrix is
> [`../WEB_TO_MOBILE_PARITY.md`](../WEB_TO_MOBILE_PARITY.md). Build status is in
> [`../BUILD_AND_RELEASE.md`](../BUILD_AND_RELEASE.md). Keep this file for the
> original delivery history; do not treat its numbers as current.

**Date:** 2026-11-02
**Directory:** `dukavo/mobile` (independent Git repository)
**Status:** Feature implementation complete for the agreed scope. `flutter pub get`, `flutter analyze` and `flutter test` run successfully on Flutter 3.47.9 / Dart 3.13.7. The APK build was attempted and is blocked by a missing Android SDK; iOS builds need macOS, and the device integration test was **not** run. See §5–§8.

---

## 1. Summary

A Flutter merchant app for Dukavo was built against the existing Laravel API rather than a guessed contract. It covers authentication and workspace selection, permission-aware navigation, dashboard, catalogue, orders, customers, inventory, conversations, notifications, analytics, profile and settings.

| Area | State |
|---|---|
| Application code | Written (111 Dart files across `lib/`, `test/`, `integration_test/`) |
| API contract | Audited against `backend/routes/api/v1.php`, resources, requests and services |
| Localization | 507 keys, English + Arabic, full parity |
| Dependencies | `flutter pub get` resolves 114 packages; `pubspec.lock` committed |
| Static analysis | `flutter analyze` — **No issues found** |
| Unit/widget tests | `flutter test` — **85 tests, all passing** |
| Device integration test | Written, **not executed** (needs an emulator/device) |
| Android/iOS builds | **Not produced** — APK build attempted but blocked by missing Android SDK; iOS needs macOS |
| Documentation | README + API integration map + this report |
| Git | 18 conventional commits, nothing pushed |

---

## 2. Implemented functionality

### 2.1 Foundation
- Material 3 theme from the brand palette (`#0F766E` primary, `#A3E635` accent, `#F8FAFC` background, `#0F172A` text), with light and dark variants.
- Persisted theme mode and locale through `shared_preferences`.
- English LTR and Arabic RTL, driven by ARB files loaded by a hand-written localization delegate so the project builds without `flutter gen-l10n`.
- One centralized Dio client: bearer token, `X-Tenant`, `Accept-Language`, Sanctum CSRF priming, envelope unwrapping, uniform `ApiException` mapping, and typed `get`/`post`/`patch`/`delete`/`deleteJson` helpers.
- Token storage in `flutter_secure_storage`; only non-sensitive preferences are stored in shared preferences.

### 2.2 Authentication and session
- Login through Fortify's `/auth/login` with CSRF cookie priming and `X-XSRF-TOKEN`.
- Bearer token persisted securely and restored silently via `/me` on cold start.
- Workspace (tenant) selection and onboarding (`/onboarding/tenant`), including the "needs tenant" state.
- Forgot-password request; logout with token revocation.
- Session model exposes roles, effective permissions and the backend permission catalogue. UI gating derives from `/me`, never from a hard-coded role.
- `refreshSession()` keeps the shell's name and avatar in sync after profile edits.

### 2.3 Navigation
- Single `ShellRoute` with five primary destinations: dashboard, orders, products, conversations, more.
- Every destination and route is permission-gated against `PermissionSlugs`; the landing page falls back to the first permitted screen when `dashboard.view` is absent.
- `NoAccessScreen` for routes the caller cannot use; a `More` workspace lists every non-tab screen.
- Detail screens are pushed outside the shell so the tab bar does not appear on a thread or order.

### 2.4 Feature modules
| Module | Delivered |
|---|---|
| Dashboard | KPIs, revenue trend, top products, dead stock, store filter |
| Products | Paginated list, search, detail, create/edit with variants, archive/delete, stock display |
| Categories | Tree, create/edit/delete, slug availability |
| Orders | Filterable list, detail, totals, status timeline, server-validated transitions, native order builder (server prices every line) |
| Customers | List/search, detail, create/edit/delete, address display |
| Inventory | Stock levels, low-stock filter, movement ledger, absolute adjust, additive receive, store filter |
| Conversations | Inbox, thread, replies, internal notes, approved templates, assignment, read state, retry, create |
| Notifications | Centre, unread badge, read/read-all, per-channel preferences |
| Analytics | KPIs, sales trends, product performance, stock health, backend limitations, date-range/store/currency filters |
| Storefront | Store-scoped shop visibility, branding, contact details, social links, policies, SEO and public shop link |
| Shipping | Store-scoped delivery zones with city/area matching, fees, free-delivery thresholds, active state and ordering |
| Payments | Cash-on-delivery settings and the server's honest availability state for online payment |
| Profile | Edit, avatar upload/remove, password change, signed-in device revocation |
| Settings | Workspace settings, theme, language, notification preferences, sign out |
| Stores | Read-only store list feeding filters and order/stock defaults |

---

## 3. Architecture and quality controls

- Feature-first Clean Architecture: `domain/` (entities, repository contracts), `data/` (models, remote data sources, repository implementations), `application/` (Riverpod controllers), `presentation/` (screens/widgets).
- The domain layer imports no Flutter, Dio or transport type; `Paginated<T>`/`PaginationMeta` live in `core/api` and are the only shared pagination contract.
- UI never calls Dio directly; every screen goes through a repository exposed by a provider.
- Riverpod 2.x with manual `AsyncNotifier`/`Notifier`; no code generation, `build_runner` or `freezed`, so the project has no generation prerequisite.
- Centralized `ApiPaths`, `RoutePaths`, `PermissionSlugs`, `Formatters` and `Validators`.
- Android cleartext traffic is restricted to `10.0.2.2`, `localhost` and `127.0.0.1` via a network security config — not a global `usesCleartextTraffic` flag.
- No secrets are logged; tokens live only in secure storage and are never written to preferences or logs.

---

## 4. API fidelity

The integration map (`docs/API_INTEGRATION_MAP.md`) was derived from the backend route file, form requests, API resources and reporting services. Three defects were found and fixed during the final audit:

1. **Analytics permission** — `/tenant/analytics` is guarded by `dashboard.view`, not `profit.view`. The mobile gate was corrected so permitted roles see analytics and others do not receive a guaranteed 403.
2. **Customer addresses** — `CustomerAddressResource` emits `type`, `contact_name`, `line_one`, `line_two`; the parser read `label`, `line1`, `line2` and rendered blank addresses. Both shapes are now accepted, with tests.
3. **Inventory movement labels** — a missing `type_label` now falls back to the movement type instead of an empty string.

Unused path constants for deliberately out-of-scope surfaces (product images, inventory transfers/intelligence, message media) were removed so the declared API surface matches what the app calls.

Addressing rules follow the backend: products by slug, orders read by `order_number` but mutated by numeric id, categories/customers/conversations by numeric id, tenant-scoped endpoints with `X-Tenant`.

---

## 5. Verification performed

Toolchain: Flutter 3.47.9 (stable), Dart 3.13.7, Linux aarch64.

| Command | Result |
|---|---|
| `flutter pub get` | 114 dependencies resolved, `pubspec.lock` written |
| `flutter analyze` | **No issues found** (33.7 s) |
| `flutter test` | **85 tests passed** (27 s) |
| `flutter build apk` | Attempted — fails with `No Android SDK found`; no Android SDK/emulator on this host |
| `flutter build ios` | Not run — requires macOS + Xcode |
| `flutter test integration_test/…` | Not run — requires a booted device/emulator and reachable backend |

The first test run exposed six failures, all fixed:

- The login footer `Row` overflowed by 12 px at 440 logical pixels; it is now a wrapping `Wrap`.
- The compact-currency helper returned `USD1.2M`; it now uses the locale symbol (`$1.2M`).
- A test treated `2024-13-40` as invalid, but Dart normalises it; the case now uses an unparseable string.
- Four analyzer errors (nullable closure return, generic `const`, `Object` vs `bool?`, unchecked nullable calls) and the remaining warnings were corrected.

Additional static audits still hold:

- All relative and `package:dukavo_mobile/` imports resolve.
- Every `RoutePaths`, `ApiPaths`, `Formatters`, `AppColors` and `PermissionSlugs` member referenced in `lib/` is defined.
- ARB parity: 507 keys in `app_en.arb` and 507 in `app_ar.arb`, identical key sets.
- Every literal `context.tr('…')` key exists in both ARB files.
- Backend permission slugs match `PermissionRegistry`.
- Model JSON keys match the corresponding API resources/requests.

---

## 6. Test coverage

| Test | Coverage |
|---|---|
| `test/core/utils/formatters_test.dart` | Money, compact currency, dates, numbers, initials, relative time |
| `test/core/utils/validators_test.dart` | Required, email, length, numeric rules |
| `test/core/api/paginated_test.dart` | Pagination metadata parsing and single-page synthesis |
| `test/core/widgets/app_widgets_test.dart` | `StatusChip`, `EmptyState`, `KeyValueRow` |
| `test/app/localization/app_localizations_test.dart` | Delegate, fallback and interpolation |
| `test/features/auth/domain/auth_domain_test.dart` | Session/permissions/tenant membership |
| `test/features/auth/presentation/login_screen_test.dart` | Render, validation, short password, server error, Arabic |
| `test/features/orders/data/order_model_test.dart` | Order, items and history JSON contract |
| `test/features/inventory/data/inventory_model_test.dart` | Inventory and movement JSON contract |
| `test/features/customers/data/customer_model_test.dart` | Customer aggregates and both address shapes |
| `test/features/analytics/domain/analytics_query_test.dart` | Query equality/hash and defaults |
| `test/features/storefront/data/storefront_model_test.dart` | Storefront settings parsing, defaults and null-clearing payloads |
| `test/features/shipping/data/shipping_model_test.dart` | Delivery zone parsing, numeric strings, coverage and defaults |
| `test/features/payments/data/payment_model_test.dart` | COD settings, honest online availability and safe defaults |
| `integration_test/app_boot_test.dart` | Device boot smoke test; credentialed login only with `DUKAVO_TEST_EMAIL`/`DUKAVO_TEST_PASSWORD` |

The widget harness preloads both ARB files and uses the real theme and delegates, so localization failures surface as test failures rather than fallback strings. The integration test is intentionally skipped for credentials unless both dart-defines are supplied.

---

## 7. Deliberately not implemented

These backend surfaces are out of scope for this release and are documented in the API map:

- Platform administration, RBAC/team management, audit log.
- Bundles; product image upload, deletion and reordering (product media is not exposed in the mobile UI).
- Inventory transfers and inventory intelligence.
- CRM memories, carts, voice, AI conversation extras, recovery campaigns.
- WhatsApp account management and webhook configuration.
- Profit intelligence, automations and marketing administration.
- Push notifications (the backend exposes no device-token/FCM/APNs endpoint; the app implements the in-app notification centre and preferences only).
- Offline data cache and background sync; only preferences are persisted locally.
- Biometric/app-lock.
- Password-reset completion screen or deep-link handling. The repository method and API path exist, but the app only requests the reset email; completing it happens on the web.
- iOS build verification (impossible on Linux even with an SDK).

---

## 8. Remaining environment limits

| Limit | Impact |
|---|---|
| No Android SDK or emulator on this host | APK/AAB builds and the device integration test have not been run |
| Linux host | iOS compilation/signing impossible regardless of SDK |
| No `gradle-wrapper.jar` in the Flutter template snapshot | Flutter supplies it on first build; an Android build may need `flutter create .` or a Gradle bootstrap |

Dependency resolution, static analysis and unit/widget tests are no longer blocked: they pass with the SDK at `/root/flutter` (Flutter 3.47.9 / Dart 3.13.7). Android toolchain setup is the remaining prerequisite for an installable build.

---

## 9. How to verify

```bash
cd mobile
flutter pub get
flutter analyze
flutter test
```

Already green here. To produce an installable build:

```bash
flutter build apk --debug
```

To run on a device, start the backend and an emulator, then:

```bash
flutter run --dart-define=DUKAVO_API_BASE_URL=http://10.0.2.2:8000/api/v1
```

The integration test:

```bash
flutter test integration_test/app_boot_test.dart -d <device-id> \
  --dart-define=DUKAVO_API_BASE_URL=http://10.0.2.2:8000/api/v1 \
  --dart-define=DUKAVO_TEST_EMAIL=... \
  --dart-define=DUKAVO_TEST_PASSWORD=...
```

Expected first-build adjustments are limited to Android SDK/Gradle alignment — no architecture change should be required.

---

## 10. Commit history

| Commit | Message |
|---|---|
| `1eb39e0` | `chore: scaffold Flutter project with Android and iOS hosts` |
| `3e0539a` | `feat(core): add transport, storage, theme and localization foundation` |
| `2562960` | `feat(auth): add Sanctum session flow and workspace onboarding` |
| `fe656b0` | `feat(catalogue): add dashboard, catalogue, inventory and order flows` |
| `f57f626` | `feat(inbox): add conversations, notifications, analytics and settings` |
| `860448d` | `feat(app): wire router, theme, locale and bootstrap` |
| `ec42c71` | `test: cover models, utilities, widgets and app boot` |
| `b6a7c0a` | `docs: document setup, architecture and API integration` |
| `29d182a` | `feat(shell): add permission-aware navigation and more workspace` |
| `dc976a2` | `fix(auth): gate analytics on dashboard.view` |
| `25bd02e` | `fix(customers): map the address resource field names` |
| `71de235` | `refactor(api): drop path constants for unimplemented surfaces` |
| `9f9c8ef` | `docs: add delivery report with verification status` |
| `be9073b` | `fix(core): satisfy analyzer and correct compact currency` |
| `f98ac7a` | `fix(ui): clear analyzer lints and stop login footer overflow` |
| `ee4ac92` | `test: align date and skip expectations with the toolchain` |
| `16ea323` | `chore: lock dependencies and exclude build output from analysis` |

This report and the README status update are committed as the final `docs:` commit. Nothing has been pushed to a remote.
