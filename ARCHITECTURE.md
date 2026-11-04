# Dukavo Mobile — Architecture

This document describes how the Flutter client is structured, why the structure
is shaped this way, and where a new feature belongs. It is the reference for
maintainers; user-facing setup and build instructions live in
[`README.md`](README.md) and [`BUILD_AND_RELEASE.md`](BUILD_AND_RELEASE.md).

---

## 1. Design goals

The app is a native companion to the Dukavo Laravel + Vue platform. The
architecture follows four rules:

1. **One API contract.** The mobile client consumes the existing `/api/v1`
   surface. It does not invent mobile-only endpoints, fake data, or a second
   business-logic layer. Where the backend had no endpoint for a screen the
   screen was left out or the missing endpoint was added to the Laravel app in
   the existing route/permission style (one platform AI availability route is
   the only such addition).
2. **The server is the security boundary.** Permissions returned by `/me` drive
   navigation and button visibility, but every request is authorised again by
   Laravel. Hiding a control is a courtesy, never a guarantee.
3. **Tenant and store isolation are explicit.** Every tenant request carries
   `X-Tenant`; store-scoped screens carry a store id in the path or query. A
   workspace switch discards cached tenant data before the new scope renders.
4. **Feature-first, layered.** A feature owns its domain, data, application and
   presentation code. Cross-cutting transport, storage, permissions, shared
   widgets and the generic resource engine live in `core/`.

---

## 2. Runtime composition

```
main.dart
  └── bootstrap()
        ├── WidgetsFlutterBinding.ensureInitialized()
        ├── SharedPreferences  -> AppPreferences
        ├── SecureTokenStore.init()
        ├── AppLocalizations.preload()        (ARB assets, before first frame)
        ├── ApiClient(baseUrl, csrfUrl, tokenStore, preferences)
        ├── apiClient.setTenantSlug(persisted tenant)
        └── runApp(ProviderScope(overrides: [preferences, tokenStore, apiClient]))
              └── DukavoApp
                    ├── ThemeController      (light / dark / system)
                    ├── LocaleController     (en / ar / system)
                    └── MaterialApp.router   (GoRouter)
```

`core/providers.dart` declares the three infrastructure providers so they can
be overridden in exactly one place. Any attempt to construct a second
`ApiClient`, token store or preferences object fails at runtime, which keeps the
token and tenant headers consistent across every request.

No code generation is used. ARB files are bundled assets parsed by a
hand-written delegate; there is no `build_runner`, `freezed`,
`json_serializable` or `gen-l10n` step.

---

## 3. Layers

```
presentation  ──reads──▶  application  ──calls──▶  data  ──uses──▶  core
      │                        │                     │
      └──────── domain objects ┘                     └── domain models
```

| Layer | Location | May import | Must not |
| --- | --- | --- | --- |
| domain | `features/*/domain` | Dart core, other domain files | Flutter, Dio, Riverpod, plugins |
| data | `features/*/data` | domain, `core/api`, `core/storage` | widgets, BuildContext |
| application | `features/*/application` | domain, data, Riverpod | widgets, Dio directly |
| presentation | `features/*/presentation` | application, domain, core widgets | JSON parsing, Dio |
| core | `core/*` | Flutter, Dio, plugins | feature presentation |
| app | `app/*` | everything needed for wiring | business rules |

A widget watches a provider and calls notifier methods. It never calls the API
client itself. A data source owns endpoint paths and response envelopes; the
rest of the app sees typed models or `JsonResource` values.

---

## 4. Directory map

```
lib/
├── app/
│   ├── app.dart                  MaterialApp.router, locale/theme wiring
│   ├── config/app_config.dart    API/web URLs, timeouts, version
│   ├── localization/             ARB assets + delegate
│   ├── router/
│   │   ├── app_router.dart       route table + redirect rules
│   │   └── route_paths.dart      every navigable location
│   └── theme/                    palette, Material 3 themes, controller
├── core/
│   ├── api/
│   │   ├── api_client.dart       Dio, auth headers, CSRF, envelope, errors
│   │   ├── api_paths.dart        every endpoint used by the app
│   │   ├── api_exception.dart    normalised failures
│   │   ├── cookie_store.dart     CSRF cookies for the web-guarded auth routes
│   │   └── paginated.dart        Paginated<T> + PaginationMeta
│   ├── auth/permissions.dart     permission slugs + typed getters
│   ├── pagination/               shared paginated notifier
│   ├── providers.dart            infrastructure providers
│   ├── resources/                generic admin resource engine
│   ├── storage/                  secure token store, preferences
│   ├── utils/                    formatters, validators
│   └── widgets/app_widgets.dart  shared Material 3 widgets
└── features/
    ├── auth/                     session, login, onboarding
    ├── dashboard/                merchant overview
    ├── analytics/                executive reporting
    ├── products/                 catalogue + media
    ├── categories/               category tree
    ├── inventory/                stock, movements, adjustments
    ├── orders/                   list, detail, transitions, order builder
    ├── customers/                CRM-lite customer records
    ├── conversations/            WhatsApp inbox
    ├── notifications/            notification centre
    ├── stores/                   store list + selector
    ├── storefront/               storefront settings
    ├── shipping/                 delivery zones
    ├── payments/                 payment settings
    ├── profile/                  profile, avatar, password, sessions
    ├── settings/                 workspace + app preferences
    ├── team/                     shared user form, role permissions
    ├── merchant/                 merchant additions and admin specs
    ├── platform/                 platform console
    ├── marketing/                public marketing site
    └── shop/                     public storefront
```

---

## 5. Transport: `ApiClient`

`core/api/api_client.dart` is the only place that knows how to talk HTTP.

- **Base URL** — `AppConfig.apiBaseUrl`, defaulting to
  `http://10.0.2.2:8000/api/v1` on Android and `http://127.0.0.1:8000/api/v1`
  elsewhere, overridable with `--dart-define=DUKAVO_API_BASE_URL=...`.
- **Auth** — a bearer token read from `SecureTokenStore`. The token is written
  once at login and cleared on logout or `401`.
- **CSRF** — Fortify's login/logout/forgot/reset routes run under the `web`
  middleware. Before those calls the client fetches `/sanctum/csrf-cookie`
  through `CookieStore` and sends `X-XSRF-TOKEN`.
- **Tenancy** — `X-Tenant` is attached to tenant requests from the persisted
  slug. The backend resolves it against the caller's memberships.
- **Locale** — `Accept-Language` follows the active locale so server-rendered
  validation messages and labels match the UI.
- **Envelope** — `{success, message, data, meta}` is normalised. `list()`
  returns `Paginated<T>`; `get()/post()/patch()/delete()` return `data`.
- **Downloads** — `download(path, query: ...)` returns raw bytes with
  `responseType: bytes`; exports write CSV to `Directory.systemTemp`.
- **Errors** — every failure becomes `ApiException` with a human message,
  status code, validation errors and optional payload. Screens render
  `error.message`; they do not inspect Dio exceptions.

Timeouts are 20 s to connect and 30 s to receive. `_send` also supports
`FormData` for avatar and product-image uploads.

---

## 6. Authentication and routing

`AuthController` exposes one of four statuses:

| Status | Meaning | Redirect target |
| --- | --- | --- |
| `unknown` | token hydration/`/me` in flight | `/splash` |
| `unauthenticated` | no valid token | `/login` |
| `needsTenant` | valid user with no workspace | `/setup` |
| `platform` | platform-only operator, no merchant workspace | `/platform/dashboard` |
| `authenticated` | user with an active tenant | first permitted merchant screen |

`Session.isPlatformUser` is true when the user holds a platform role;
`isPlatformOnly` additionally requires no tenant membership. A platform-only
operator must never be sent to tenant onboarding, hence the dedicated status.

The router (`app/router/app_router.dart`) applies these rules:

1. Public marketing (`/site/**`) and public storefront (`/shop/**`) bypass all
   auth redirects.
2. Splash/login/setup are only reachable in the matching auth state.
3. Platform mode may reach `/platform/**` and personal screens
   (profile/settings/notifications); everything else returns to the platform
   dashboard.
4. A merchant user with a platform role may also open `/platform/**`; a
   merchant without one gets `/no-access`.
5. Merchant paths are permission-checked per area. Creation/edit routes check
   the narrower create/update permission before the list permission.
6. `homePathFor()` picks the first destination the permission set allows, so a
   role without `dashboard.view` never lands on a 403.
7. `_AuthStatusListenable` re-runs redirects only when the auth status changes,
   not on every provider tick.

`RoutePaths` centralises every location and every detail helper
(`product(slug)`, `order(orderNumber)`, `shopCheckout(tenant, store)`, ...).
`ApiPaths` does the same for endpoints. A backend rename therefore produces a
small, reviewable diff rather than scattered string edits.

### Shells

- `AppShell` — merchant bottom tabs: dashboard, orders, products,
  conversations, more.
- `PlatformShell` — platform bottom tabs: dashboard, tenants, users, marketing,
  more. It is separate because merchant tabs would answer `403` for a
  platform-only operator.
- `ShopShell` — public storefront home and cart.
- `MarketingSiteShell` — public marketing home, features, pricing, FAQ,
  newsletter, contact, waitlist, content pages.

Detail, form, checkout, order and long-form screens are siblings of the shells
so they own the full viewport and their own app bar.

---

## 7. State management

Riverpod is used without code generation:

- **`Provider`** — infrastructure and pure dependencies.
- **`FutureProvider` / `FutureProvider.family`** — read-only loads keyed by id,
  slug, store or filter.
- **`StateNotifierProvider`** — session, list pagination, carts and multi-step
  screen state.
- **`AsyncValue`** — every async screen renders `loading`, `error` and `data`
  explicitly; skeletons are used where the layout is known.

`PaginatedNotifier<T>` (in `core/pagination/`) provides one implementation of
refresh, load-more, search, filter, empty and error handling. `ResourcePager`
builds on it for the generic engine.

Workspace switching calls `/me` with the new `X-Tenant`, replaces the session
and permission set, and invalidates tenant-scoped providers so stale data from
the previous workspace cannot be shown.

---

## 8. The generic resource engine

Many back-office surfaces are list → detail → create/edit → delete over a JSON
resource. `core/resources/` implements that once:

| File | Responsibility |
| --- | --- |
| `json_resource.dart` | type-safe accessors over a JSON map (`text`, `number`, `boolean`, `map`, `list`) |
| `resource_spec.dart` | declarative contract: path, fields, filters, actions, create/edit/delete paths, detail route, bespoke sections |
| `resource_pager.dart` | pagination, search and single-select filters |
| `resource_screens.dart` | `ResourceListScreen`, `ResourceDetailScreen`, `ResourceFormScreen` |

A `ResourceSpec` declares:

- field type (`text`, `multiline`, `integer`, `decimal`, `boolean`, `select`,
  `date`, `password`, `json`) and whether a field appears in list/detail/form;
- row title, subtitle and status chip;
- search parameter and `extraQuery`;
- single-select `ResourceFilterSpec` chips;
- create/edit/delete capability and paths;
- detail API path (`detailPath`) and in-app route (`detailRoute`) — these can
  differ, e.g. audit API `/audit-logs/1` but route `/audit/1`;
- `ResourceActionSpec` POST/PATCH actions with optional body, confirmation and
  visibility predicate;
- optional `extraDetail` and `extraForm` widgets for resource-specific sections.

`ResourceFieldType.json` renders read-only JSON on detail and a validated JSON
text editor on forms. Parsing happens before submit, so malformed JSON never
reaches the API.

Specs live next to their feature: `platform_specs.dart`, `merchant_specs.dart`.
Bespoke screens (dashboard, profit, inventory intelligence, recovery, shop,
checkout) remain hand-written where the workflow is not CRUD.

---

## 9. Permissions

`core/auth/permissions.dart` mirrors `App\Support\PermissionRegistry` and adds
typed getters (`canViewProducts`, `canApproveAi`, `canExportProfit`, ...). The
set comes from `/me` and is refreshed on login and workspace switch.

Permission checks appear in three places:

1. router redirects (area access);
2. navigation lists (`more_screen.dart`, `platform_more_screen.dart`);
3. action buttons and forms (create/edit/delete/approve/export).

The server repeats every check. A client with a tampered permission set can
still render a button, but the request will be rejected.

---

## 10. Localisation, RTL and theming

- `app_en.arb` and `app_ar.arb` each contain 862 keys and must stay in parity.
  A test enforces identical key sets, non-empty values and the presence of keys
  referenced by the new surfaces.
- The delegate is hand-written and loads both ARB files as assets during
  bootstrap. Missing keys render the key itself so they are visible in review.
- Arabic sets `Directionality.rtl`. Layout uses directional padding,
  `AlignmentDirectional`, `start`/`end` and logical borders; no hard-coded
  left/right values in new code.
- Theme mode (light/dark/system) and locale (en/ar/system) persist in
  `SharedPreferences` and are restored before the first frame.
- `AppColors` defines the palette once; `AppTheme` builds Material 3 light and
  dark `ThemeData` from it.

---

## 11. Public storefront

`features/shop/` talks only to the public storefront API:

```
/api/v1/public/storefront/{tenantSlug}/{storeSlug}
```

It implements store home and product listing, product detail, client-side cart,
checkout and order lookup by token. Key rules:

- The cart is held locally. Prices, shipping, discounts and totals are resolved
  by the server at checkout; the client never sends a price.
- Products in the public payload have no product id; variants are addressed by
  `variants[].id`.
- Checkout requires `customer_name`, `customer_phone`, `payment_method`
  (`cod`/`online`), `idempotency_key` (8–100 chars) and `shipping_address`
  (`line_one`, `city`, a two-letter `country`, optional `area`/`notes`).
- Shipping cities come from active zones. If zones exist with a non-null city
  and the chosen city does not match, checkout fails; the UI derives city and
  area options from the same zone payload.
- Online payment is always shown as unavailable because the backend has no
  provider/ledger yet; cash on delivery is the available method.
- The order confirmation screen reads by opaque token, never by numeric id.

Public routes are reachable without a session, so a merchant can share
`/shop/{tenant}/{store}` and a customer can order without an account.

---

## 12. Public marketing site

`features/marketing/` consumes the public marketing endpoints:

- `GET /public/features`
- `GET /public/pricing`
- `GET /public/faq`
- `GET /public/pages/{key}`
- `GET /public/newsletters` and `/public/newsletters/{slug}`
- `POST /public/contact`
- `POST /public/waitlist`
- `POST /public/newsletter/subscribe` and `/unsubscribe`

The native site mirrors the Vue public pages: home, features, pricing, FAQ,
newsletter index/article, contact, waitlist and long-form content pages. The
same content is used, so there is no duplicated copy to maintain. SEO,
sitemaps, robots and cookie banners are web-only concerns and are intentionally
absent from the app.

---

## 13. Platform console

`features/platform/` is a separate five-tab console for platform operators:

- **Dashboard** — tenant/user/waitlist/contact/subscriber/plan KPIs, growth
  series, status breakdown, selectable range.
- **Tenants** — list, create, edit, delete, suspend/activate, members.
- **Users** — list, create, edit, assign/revoke roles.
- **Marketing** — pricing plans, FAQ entries, content pages, newsletters,
  waitlist, contact messages, newsletter subscribers.
- **More** — roles/permissions, audit log, profile, settings, and a shortcut
  into a merchant workspace when the operator also has a membership.

Tenant detail includes member management; user detail includes role assignment.
Platform role taps open the permissions editor, because managing permissions is
the meaningful action for a role.

---

## 14. Merchant additions

Beyond the original merchant scope the app now covers:

- **Team & access** — users, roles, permission editing, audit log.
- **Catalogue** — product image upload/reorder/delete, bundles.
- **Inventory** — intelligence overview/detail and CSV export.
- **Growth** — lost-sale recovery queue with AI draft, dismiss and
  do-not-contact actions; WhatsApp account management; AI action approvals;
  automation rules, runs and human tasks.
- **Reporting** — profit overview with filters and CSV export.
- **Stores** — list, create/edit/delete and make-default.
- **Storefront** — settings, shipping zones and payments per store.

These screens reuse `ResourceSpec` where the workflow is CRUD and use bespoke
screens where it is not (profit, inventory intelligence, recovery, hubs).

---

## 15. Error, empty and loading states

Every asynchronous surface renders three explicit branches:

- **loading** — skeleton or centred progress, matching the final layout where
  practical;
- **error** — the server's message, a retry action, and no fabricated content;
- **empty** — an icon, a localised title and, where useful, a call to action.

Lists support pull-to-refresh and incremental pagination. Forms validate
locally, show field-level errors, disable submit while pending, and surface
server validation errors without losing input. Destructive actions use
`ConfirmDialog` and, for checkout/AI actions, an idempotency key.

---

## 16. Testing strategy

- **Unit** — formatters, validators, pagination metadata, JSON models for
  orders/inventory/customers/payments/shipping/storefront/shop/marketing,
  analytics query equality, auth domain, platform dashboard parsing, cart
  notifier and ARB parity.
- **Widget** — shared widgets, login validation/server errors/Arabic RTL,
  payment settings and shipping zones.
- **Integration** — `integration_test/app_boot_test.dart` boots the real app on
  a device/emulator; credential login runs only when
  `DUKAVO_TEST_EMAIL`/`DUKAVO_TEST_PASSWORD` are supplied.

Current verified result: `flutter analyze` reports no issues and
`flutter test` passes 113 tests. Device integration tests require an emulator
or physical device and a reachable backend.

---

## 17. Extension guide

To add a CRUD admin resource:

1. Add endpoint paths to `ApiPaths`.
2. Add route constants/helpers to `RoutePaths`.
3. Create a `ResourceSpec` with fields, filters and actions.
4. Register list/detail/create/edit routes in `app_router.dart`.
5. Add permission checks to the router redirect and navigation entry.
6. Add ARB keys to **both** locale files.
7. Add a model/parsing test and run `dart format`, `flutter analyze`,
   `flutter test`.

To add a bespoke workflow:

1. Define domain models and a repository interface.
2. Implement the data source against `ApiClient`.
3. Expose Riverpod providers and a `StateNotifier` for actions.
4. Build the screen with explicit loading/error/empty branches.
5. Add routes, permissions, localisation and tests.

Never add a fake API, seed the UI with dummy business data, or duplicate
pricing/authorisation rules that belong to Laravel.
