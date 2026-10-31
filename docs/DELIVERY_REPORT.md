# Dukavo Mobile — Delivery Report

**Date:** 2026-10-31
**Directory:** `dukavo/mobile` (independent Git repository)
**Status:** Feature implementation complete for the agreed scope. **Runtime verification is blocked** — no Flutter/Dart SDK is available in this environment, so nothing has been compiled, analyzed, tested or built. See §6–§8.

---

## 1. Summary

A Flutter merchant app for Dukavo was built against the existing Laravel API rather than a guessed contract. It covers authentication and workspace selection, permission-aware navigation, dashboard, catalogue, orders, customers, inventory, conversations, notifications, analytics, profile and settings.

| Area | State |
|---|---|
| Application code | Written (95 Dart files across `lib/`, `test/`, `integration_test/`) |
| API contract | Audited against `backend/routes/api/v1.php`, resources, requests and services |
| Localization | 445 keys, English + Arabic, full parity |
| Unit/widget/integration tests | Written, **not executed** |
| `flutter analyze` / `flutter test` / builds | **Not run — SDK absent** |
| Documentation | README + API integration map + this report |
| Git | 13 conventional commits, nothing pushed |

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
| Profile | Edit, avatar upload/remove, password change, signed-in device revocation |
| Settings | Workspace settings, theme, language, notification preferences, sign out |
| Stores | Read-only store list feeding filters and order/stock defaults |

---

## 3. Architecture and quality controls

- Feature-first Clean Architecture: `domain/` (entities, repository contracts), `data/` (models, remote data sources, repository implementations), `application/` (Riverpod controllers), `presentation/` (screens/widgets).
- The domain layer imports no Flutter, Dio or transport type; `Paginated<T>`/`PaginationMeta` live in `core/api` and are the only shared pagination contract.
- UI never calls Dio directly; every screen goes through a repository exposed by a provider.
- Riverpod 2.x with manual `AsyncNotifier`/`Notifier`; no code generation, `build_runner` or `freezed`, so the project has no generation prerequisite.
- Centralized `ApiPaths`, `RoutePaths`, `PermissionSlugs`, `Formatters` and `Validators`; static checks confirmed no unresolved references (see §5).
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

## 5. Static verification performed

These checks ran successfully against the source tree:

- All relative and `package:dukavo_mobile/` imports resolve to existing files.
- Every `RoutePaths`, `ApiPaths`, `Formatters`, `AppColors` and `PermissionSlugs` member referenced in `lib/` is defined.
- Every `*Provider` referenced in `lib/` has a definition.
- ARB parity: 445 keys in `app_en.arb` and 445 in `app_ar.arb`, identical key sets.
- Every literal `context.tr('…')` key exists in both ARB files.
- Backend permission slugs were cross-checked against `PermissionRegistry`; the mobile catalogue only contains slugs the backend seeds.
- Model JSON keys were diffed against the corresponding API resources/requests for orders, products, inventory, conversations, dashboard, analytics, profile, stores, categories, notifications and customers.

**These are source-level checks, not a compiler.** They do not prove type correctness, API runtime behavior or UI rendering.

---

## 6. Tests written (unexecuted)

| Test | Coverage |
|---|---|
| `test/core/utils/formatters_test.dart` | Money, dates, numbers, compact values |
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
| `integration_test/app_boot_test.dart` | Device boot smoke test; credentialed login only with `DUKAVO_TEST_EMAIL`/`DUKAVO_TEST_PASSWORD` |

The widget harness preloads both ARB files and uses the real theme and delegates, so localization failures surface as test failures rather than fallback strings.

---

## 7. Deliberately not implemented

These backend surfaces are out of scope for this release and are documented in the API map:

- Platform administration, RBAC/team management, audit log.
- Bundles; product image upload, deletion and reordering (product media is read-only/absent in the UI).
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

## 8. Environment blockers

| Blocker | Impact |
|---|---|
| No Flutter/Dart SDK installed | `flutter pub get`, `dart format`, `flutter analyze`, `flutter test`, `flutter build` never ran |
| SDK download infeasible (1.58 GB at ~10–70 KB/s; timed out at 64 MB) | Cannot install the toolchain here |
| Linux host | iOS compilation/signing impossible regardless of SDK |
| No `gradle-wrapper.jar` in the Flutter template snapshot | Flutter normally supplies it on first build; an Android build may need `flutter create .` or a Gradle bootstrap |

Consequences: dependency resolution is unproven, any analyzer error or type mismatch is undiscovered, widget tests have never rendered, and the Android/iOS hosts have never been assembled. The pinned versions (Flutter 3.47.9 / Dart 3.13.7 target, AGP 8.7.3, Kotlin 2.1.0, Gradle 8.12) may require adjustment on first build.

---

## 9. How to verify

```bash
cd mobile
flutter pub get
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test
flutter build apk --debug
```

Run the integration test on a booted emulator with the backend reachable:

```bash
flutter test integration_test/app_boot_test.dart \
  --dart-define=DUKAVO_API_BASE_URL=http://10.0.2.2:8000/api/v1 \
  --dart-define=DUKAVO_TEST_EMAIL=... \
  --dart-define=DUKAVO_TEST_PASSWORD=...
```

Expected first-run adjustments are limited to dependency version resolution, Gradle/AGP alignment, and any analyzer findings — no architecture change should be required.

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

This report is committed as the final `docs:` commit. Nothing has been pushed to a remote.
