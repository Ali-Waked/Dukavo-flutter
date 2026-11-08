# Dukavo Public Mobile Experience — Audit

Date: 2026-11-08
Scope: `/root/dukavo/backend`, `/root/dukavo/frontend`, `/root/dukavo/mobile`
Status: Phase 1 (read-only audit). No application code was changed to produce this document.

---

## 1. Method

The audit inspected the actual source of all three repositories:

- `frontend/src/router/index.ts` — the authoritative public/authenticated route map and the `beforeEach` guard.
- `backend/routes/api/v1.php` — the authoritative HTTP surface, its middleware and prefixes.
- `backend/config/fortify.php` — authentication features actually enabled.
- `backend/config/dukavo.php` — the public feature catalogue and its `available` / `coming_soon` statuses.
- `mobile/lib/app/router/*`, `mobile/lib/features/*`, `mobile/lib/core/*` — existing Flutter routing, auth, API, localization and screens.

No endpoint was assumed. Every endpoint below exists in `routes/api/v1.php`.

---

## 2. Repository stack

| Repo | Stack | Role |
| --- | --- | --- |
| `backend` | Laravel + Sanctum + Fortify | API and authorization authority |
| `frontend` | Vue 3 + Vue Router + Pinia + Tailwind | Reference implementation for public copy and flows |
| `mobile` | Flutter + Riverpod + go_router + Dio | Native Android/iOS client (this task) |

The three directories are separate Git roots. The mobile working tree is clean at `b318636`.

### Mobile architecture (existing)

- `lib/bootstrap.dart` initializes `SharedPreferences`, `SecureTokenStore`, ARB bundles and one `ApiClient` before `runApp`.
- `lib/app/app.dart` owns `MaterialApp.router`, theme mode, locale and the global text scale clamp.
- `lib/app/router/app_router.dart` is the single `GoRouter`, with a `StateNotifier`-driven refresh listenable and one `_redirect` function.
- `lib/features/*/<layer>` follows **data → domain → application → presentation**.
- Riverpod is the only state manager (`StateNotifierProvider`, `FutureProvider`, `Provider`). No second state library exists.
- `lib/core/widgets/app_widgets.dart` provides `AppLogo`, `AppButton`, `AppTextField`, `SectionCard`, `LoadingView`, `ErrorView`, `EmptyState`, `StatusChip`, `PagedListView`.
- Theme: `AppColors.primary #0F766E`, `primaryDark #115E59`, `accent #A3E635`; full light and dark `ColorScheme` in `AppTheme`.
- Localization: ARB files at `lib/app/localization/l10n/app_en.arb` / `app_ar.arb`, generated into `lib/app/localization/generated/`. `AppLocalizations.preload()` loads them before first frame. RTL is handled by Flutter from the `Locale`.

### Authentication (existing)

- Sanctum token + cookie session stored by `SecureTokenStore`; `ApiClient` attaches the bearer token, `X-Tenant`, `Accept`, `Accept-Language`, and refreshes CSRF for cookie writes.
- `AuthController` exposes `AuthStatus.unknown | unauthenticated | needsTenant | platform | authenticated`.
- `bootstrap()` restores `/me`; 401 calls `AuthController.handleUnauthorized()` and clears local session.
- `auth_destination.dart` already centralizes permission-aware landing (`homePathFor`) and splash hand-off (`splashDestination`).
- Backend authorization is enforced by `auth:sanctum`, `active`, `tenant`, `platform` and `permission:*` middleware. The mobile client must not duplicate or weaken it.
- Fortify is configured with **`resetPasswords`, `emailVerification`, `updatePasswords` only**. `Features::registration()` is deliberately disabled, so **there is no `POST /api/v1/auth/register` endpoint**.

---

## 3. Frontend route classification

Classification legend:

- **A** Public marketing
- **B** Authentication / account entry
- **C** Merchant application (tenant authenticated)
- **D** Platform administration
- **E** Public customer storefront

### A. Public marketing (`frontend/src/router/index.ts`, `MarketingLayout`)

| Web route | Page | Backend API | Mobile today | Status |
| --- | --- | --- | --- | --- |
| `/` | `HomePage.vue` | `/public/features`, `/public/pricing`, `/public/faq`, `/public/newsletters` (used by home sections) | `/site` → `SiteHomeScreen`, basic hero + previews | **Partial** — no required headline, no how-it-works/benefits/final CTA/footer, no 5-tab nav |
| `/features` | `FeaturesPage.vue` | `GET /public/features` | `/site/features` → `SiteFeaturesScreen` | **Partial** — flat list, no grouped/available-vs-upcoming presentation, no hero |
| `/how-it-works` | `HowItWorksPage.vue` | none (localized static copy) | none | **Missing** |
| `/pricing` | `PricingPage.vue` | `GET /public/pricing`, `GET /public/faq` | `/site/pricing` → `SitePricingScreen` | **Partial** — plans and states exist; no invite note, tax note or pricing FAQ |
| `/waitlist` | `WaitlistPage.vue` | `POST /public/waitlist` | `/site/waitlist` → `SiteWaitlistScreen` | **Implemented** |
| `/contact` | `ContactPage.vue` | `POST /public/contact` | `/site/contact` → `SiteContactScreen` | **Implemented** — no hero, no honeypot field |
| `/about` | `AboutPage.vue` | `GET /public/pages/about` | `/site/page/about` → generic `SitePageScreen` | **Partial** — does not render `steps` / `cards` / `cta` layouts, no hero |
| `/blog` | `BlogPage.vue` | `GET /public/newsletters` | `/site/newsletter` → `SiteNewsletterScreen` | **Implemented as archive** — no featured treatment, no hero |
| `/blog/:slug` | `BlogArticlePage.vue` | `GET /public/newsletters/{slug}` | `/site/newsletter/:slug` → `SiteNewsletterArticleScreen` | **Partial** — `body` is sanitised HTML but mobile renders it as plain text |
| `/help` | `HelpPage.vue` | FAQ/content reads | none | **Missing** — FAQ covers most of the need |
| `/terms` | `TermsPage.vue` | `GET /public/pages/terms` | `/site/page/terms` | **Implemented** (generic renderer) |
| `/privacy` | `PrivacyPage.vue` | `GET /public/pages/privacy` | `/site/page/privacy` | **Implemented** (generic renderer) |
| `/acceptable-use` | `AcceptableUsePage.vue` | `GET /public/pages/acceptable-use` | not linked; generic route can serve it | **Available but unlinked** |
| `/features/*` legacy | redirects into `/features#anchors` | n/a | n/a | n/a |

### B. Authentication and account entry

| Web route | Page | Backend API | Mobile today | Status |
| --- | --- | --- | --- | --- |
| `/login` | `LoginPage.vue` | Fortify `POST /auth/login` | `/login` → `LoginScreen` | **Implemented**; no intended-destination return, no back-to-public affordance |
| `/forgot-password` | `ForgotPasswordPage.vue` | Fortify `POST /auth/forgot-password` | `/forgot-password` → `ForgotPasswordScreen` | **Implemented** |
| `/reset-password` | `ResetPasswordPage.vue` | Fortify `POST /auth/reset-password` | `/reset-password` → `ResetPasswordScreen` (`token`, `email` query) | **Implemented** |
| `/verify-email` | `VerifyEmailPage.vue` | Fortify signed verification routes | none | **Missing** — feature is enabled server-side |
| `/onboarding` | `OnboardingPage.vue` | `POST /onboarding/tenant` | `/setup` → `TenantSetupScreen` | **Implemented** |
| `/account-status` | `AccountStatusPage.vue` | session status from `/me` | none | **Missing** for invited/suspended accounts |
| registration | no web route | **none** (Fortify registration disabled) | none | **Cannot be faked**; invite-only waitlist is the public path |

### C. Merchant application (tenant authenticated)

All web routes below exist under `DashboardLayout` with `meta.requiresAuth = true` and per-route `meta.permission`. Mobile already exposes the equivalent screens and permissions:

`/dashboard`, `/profit`, `/analytics`, `/products`, `/products/new`, `/products/:slug`, `/products/:slug/edit`, `/bundles`, `/categories`, `/inventory`, `/customers`, `/customers/:id`, `/orders`, `/orders/:orderNumber`, `/recovery`, `/automations`, `/conversations`, `/whatsapp`, `/stores`, `/storefront`, `/shipping`, `/payments`, `/users`, `/roles`, `/ai/approvals`, `/ai/merchant-copilot`, `/audit`, `/notifications`, `/profile`, `/settings`, `/settings/workspace`.

**Status: implemented; must be preserved unchanged.** Mobile uses dedicated screens plus `ResourceListScreen`/`ResourceFormScreen` with `merchant_specs.dart`.

### D. Platform administration

Web routes: `/platform`, `/tenants`, `/platform/users`, `/platform/roles`, `/platform/audit`, `/pricing-plans`, `/faq-entries`, `/content-pages`, `/waitlist-entries`, `/contact-messages`, `/newsletter-subscribers`, `/newsletters`, `/newsletters/new`, `/newsletters/:id/edit`.

Backend prefix: `/api/v1/platform/*`, middleware `platform` (+ `permission:*` where noted). Mobile already exposes these through `PlatformShell` and `platform_specs.dart`.

**Status: implemented; keep separate from merchant navigation.** `AuthStatus.platform` currently redirects all non-platform areas to the platform dashboard, which must remain.

### E. Public customer storefront

| Web route | Backend API | Mobile today | Status |
| --- | --- | --- | --- |
| `/shop/:tenantSlug/:storeSlug` | `GET /public/storefront/{tenant}/{store}` | `/shop/:tenant/:store` → `ShopHomeScreen` | **Implemented** (story, categories, search, products) |
| `/.../products` | `GET .../products` | same catalogue screen | **Implemented** |
| `/.../products/:productSlug` | `GET .../products/{slug}` | `/shop/:tenant/:store/p/:slug` | **Implemented** |
| `/.../cart` | client-side cart | `/shop/:tenant/:store/cart` | **Implemented** |
| `/.../checkout` | `POST .../checkout` | `/shop/:tenant/:store/checkout` | **Implemented** |
| `/.../orders/:token` | `GET .../orders/{token}` | `/shop/:tenant/:store/order/:token` | **Implemented** |
| `/.../track` | uses order token | `/shop/:tenant/:store/track` | **Implemented** |

There is **no store directory / marketplace endpoint**. Dukavo is designed around individual merchant storefronts, so no discovery/directory may be invented. `/shop` without slugs must keep explaining the shop link shape.

---

## 4. Public API inventory (verified)

All routes are under `/api/v1`; responses use the standard `success` envelope unless noted.

| Method | Endpoint | Auth | Notes |
| --- | --- | --- | --- |
| GET | `/public/features` | none | `config('dukavo.marketing.features')`, each with `status: available \| coming_soon` |
| GET | `/public/pricing` | none | active plans only, ordered; `price: null` means “announced, not priced”; `purchase_available` distinguishes saleability |
| GET | `/public/faq` | none | localized from `Accept-Language`; returns `question`, `answer`, `category` |
| GET | `/public/pages/{key}` | none | published only; 404 otherwise; keys include `about`, `terms`, `privacy`, `acceptable-use` |
| GET | `/public/newsletters` | none | paginated published editions, newest first; localized |
| GET | `/public/newsletters/{slug}` | none | full sanitised HTML `body`; localized |
| POST | `/public/waitlist` | none, throttled | generic 202-style success; no email enumeration |
| POST | `/public/contact` | none, throttled | same generic success contract |
| POST | `/public/newsletter/subscribe` | none, throttled | same contract |
| POST | `/public/newsletter/unsubscribe` | none, throttled | same contract |
| GET | `/public/storefront/{tenantSlug}/{storeSlug}` | none, throttled | storefront story/settings |
| GET | `/public/storefront/.../categories` | none | categories |
| GET | `/public/storefront/.../products` | none | paginated catalogue with search/category filters |
| GET | `/public/storefront/.../products/{slug}` | none | product detail |
| GET | `/public/storefront/.../shipping-zones` | none | shipping options |
| GET | `/public/storefront/.../payment-methods` | none | payment options |
| POST | `/public/storefront/.../checkout` | none, tighter throttle | reserves stock and writes order |
| GET | `/public/storefront/.../orders/{token}` | none (secret token) | secure order tracking |
| POST | `/auth/login`, `/auth/logout` | session/token | Fortify + Dukavo logout override |
| POST | `/auth/forgot-password`, `/auth/reset-password` | none | Fortify |
| GET | `/auth/email/verify/{id}/{hash}` etc. | signed | Fortify email verification |
| POST | `/onboarding/tenant` | auth | creates workspace |
| GET | `/me`, `/permissions` | auth | session and permission projection |

**Missing backend functionality:** public registration (`POST /auth/register`) is intentionally absent. There is also no public “blog” table separate from the newsletter archive, no public store directory, and no public search across merchants. These are product decisions, not Flutter gaps.

---

## 5. RBAC summary (mobile)

- `Permissions` is derived from the server projection; navigation must never compute permissions locally.
- `_permissionRedirect` in `app_router.dart` maps protected paths to `noAccess` when the role lacks the permission.
- Platform routes additionally require `session.isPlatformUser`.
- Merchant and platform shells are separate (`AppShell` vs `PlatformShell`).
- The public experience must be readable by every status, including `unknown`, `unauthenticated`, `needsTenant`, `platform` and `authenticated`.

---

## 6. Gaps found

### Routing / navigation

1. Unauthenticated users are sent to `/login` from the splash (`splashDestination`) and from every non-public route. There is no public home landing.
2. Public routes live under `/site/*`; the requested scheme (`/home`, `/features`, `/pricing`, `/how-it-works`, `/about`, `/faq`, `/blog`, `/contact`, `/register`) does not exist.
3. No 5-destination public bottom navigation (Home, Features, Pricing, About, More). The current shell has Home, Pricing, FAQ, Newsletter.
4. No intended-destination preservation (`?redirect=`) or return-after-login.
5. `/register` does not exist and must be an honest invite-only explanation, not a fake form.
6. `/site` detail links (`/site/page/:key`, `/site/newsletter/:slug`) are used by the merchant More screen and shop shell; they must keep working or redirect cleanly.

### Content / screens

7. Home is a generic preview, not the requested premium landing narrative.
8. `How It Works` and a proper `About` layout renderer are missing.
9. Blog article bodies are sanitised HTML but the mobile detail screen renders them as raw text.
10. Features are a flat list; available vs. coming-soon is a chip but there is no grouped hierarchy.
11. Pricing lacks the invite/tax context and pricing FAQ that the web page shows.
12. FAQ/pricing/newsletter/content requests are not explicitly locale-keyed and do not refetch on an in-app language switch.
13. `Accept-Language` falls back to `en` when the preference is “follow device”, even if the device is Arabic.
14. Contact has no hero and no honeypot; duplicate submission is only guarded by the disabled button.
15. Email verification and account status screens are absent.

### Preservation constraints

16. The merchant `More` screen links to `/site`; the shop shell links to `/site`. These must be updated or redirected, not broken.
17. Existing public screens already implement loading/empty/error states and API integration; they should be reused rather than rewritten from scratch.
18. Frontend has uncommitted marketing/blog/FAQ/i18n changes. They are reference material only and must not be staged in the mobile commit.

---

## 7. Recommended implementation approach

### Route model

Introduce the requested public scheme and keep legacy URLs as redirects:

```
/home                  public landing (shell tab 1)
/features              public capabilities (shell tab 2)
/pricing               public pricing (shell tab 3)
/about                 public about (shell tab 4)
/how-it-works          public workflow (detail)
/faq                   public FAQ (detail)
/blog                  public archive (detail)
/blog/:slug            public article (detail)
/contact               public contact (detail)
/register              invite-only registration explanation (detail)
/login                 existing LoginScreen
/forgot-password       existing ForgotPasswordScreen
/reset-password        existing ResetPasswordScreen
/more-public           not a route; More opens a bottom sheet
```

Legacy redirects, to avoid breaking existing links:

```
/site                  → /home
/site/features         → /features
/site/pricing          → /pricing
/site/faq              → /faq
/site/newsletter       → /blog
/site/newsletter/:slug → /blog/:slug
/site/contact          → /contact
/site/waitlist         → /waitlist (keep the existing waitlist screen)
/site/page/:key        → /pages/:key or keep as a public detail
```

Keep `/waitlist` and `/site/waitlist` working because pricing, register, and the More sheet all funnel to it.

### Navigation shell

Use `StatefulShellRoute.indexedStack` with four branches (`/home`, `/features`, `/pricing`, `/about`) so tab state survives switching. A fifth **More** destination opens a modal bottom sheet instead of navigating. The sheet contains How It Works, FAQ, Blog, Contact, Login, language and theme controls, plus legal links. This avoids a route collision with the authenticated `/more` and keeps the public stack intact behind the login screen.

The shell app bar shows the real logo, a language toggle, a theme toggle and an account/login action. It reads auth state only to decide whether the action says “Sign in” or opens the appropriate dashboard.

### Auth-aware routing

- `splashDestination` → `/home` for `unauthenticated`.
- `_isPublicPath` covers the new public routes, the storefront, and auth routes.
- Protected redirect: `/login?redirect=<encoded current path+query>`.
- Login success: if a safe internal `redirect` exists, return to it (the normal router permission rules then apply); otherwise `homePathFor`.
- Sanitize `redirect`: only same-origin paths starting with `/`, never `//`, never another scheme.
- Keep expired sessions flowing through `handleUnauthorized()` → unauthenticated → login, while public pages remain reachable.
- `unknown` status: splash, then public home.

### Data layer

- Reuse `marketing_providers.dart`, `newsletter_repository.dart` and `marketing_models.dart`.
- Add `locale` query parameter to localized requests (FAQ, content pages, newsletters) while keeping `Accept-Language`.
- Make localized providers watch the active locale so a language switch disposes and refetches them.
- Make `ApiClient` use the effective device language when the preference is “follow device”.
- Add a small content-page block renderer (paragraph, list, note) and labeled-item parser for About, matching `frontend/src/utils/content.ts`. This is plain text, no HTML injection.
- For newsletter `body` (sanitised HTML), add a dependency-free lightweight block renderer that converts the allow-listed HTML into `TextSpan`/`RichText` blocks (paragraphs, headings, lists, emphasis, links as text). No WebView.
- Preserve 15-second timeouts and existing `ApiException` messaging.

### Screens

- **Home**: branded hero with required AR/EN headline, subtitle, primary `Get Started` → `/register`, secondary `Explore Features` → `/features`. Ecosystem visual built from existing icons (products, orders, WhatsApp, inventory, analytics/AI). Benefits strip, feature preview (API), 5-step how-it-works, pricing preview (API), FAQ preview (API), final CTA, footer.
- **Features**: hero + API features grouped into `Available now` and `Coming soon`, with the status explained; empty/error states.
- **Pricing**: hero, invite note, plans from API, tax note, pricing FAQ from API, CTA.
- **How It Works**: localized static 5-step loop, three setup cards, security card, CTA.
- **About**: hero from `/public/pages/about`, plus layout-aware sections (`prose`, `steps`, `cards`, `cta`); 404 → “not available yet”; error retry.
- **FAQ**: hero, API entries in expansion cards, contact CTA, loading/empty/error.
- **Blog**: hero, featured first article, paginated archive, article detail with rendered body and related/back link.
- **Contact**: hero, validated form, honeypot, success/error, disabled while submitting.
- **Register**: invite-only explanation, waitlist CTA, sign-in link. No fake account creation.
- **More sheet**: How It Works, FAQ, Blog, Contact, Login, language, theme, legal.
- **Footer**: logo, tagline, product/company/legal links, copyright, language/theme toggles.

### What must not change

- Merchant screens, `AppShell`, `PlatformShell`, RBAC mapping, token/session handling, backend authorization.
- The splash animation and its timing (already committed in `b318636`).
- Existing public API contracts.
- Frontend uncommitted work.

---

## 8. Missing backend functionality (to document, not invent)

| Need | Reality | Decision |
| --- | --- | --- |
| Public registration | `Features::registration()` disabled; no `POST /auth/register` | `/register` explains invite-only access and links to `/waitlist` and `/login`. Document the gap. |
| Public blog model | No separate blog table; `/public/newsletters` is the published article archive | Treat `/blog` as the newsletter archive. Do not create fake articles or a parallel backend. |
| Store discovery / marketplace | No public store directory endpoint; only per-tenant storefronts | Do not invent one. Keep `/shop` as a link-format explainer. |
| Email verification deep link | Fortify verification routes exist, but mobile has no deep-link handler or verify screen | Add a clear account-status/verification message where the session exposes it; do not fabricate a token flow. Document the limitation. |
| Account status page | Web has `/account-status`; mobile only knows `needsTenant` and `platform` | Map invited/suspended states to an explanatory screen if `/me` exposes them; otherwise document. |

---

## 9. Test surface to add

- Public route access for every `AuthStatus`, including `unknown`.
- Splash → `/home` for unauthenticated.
- Protected route → login with preserved `redirect`, then return after login.
- Platform user never lands in a merchant route; merchant never lands in the platform console.
- Public bottom navigation and More sheet destinations.
- Pricing/FAQ/newsletter/about APIs: loading, empty, error, retry, locale switch.
- AR/RTL and EN/LTR; light and dark.
- Contact validation + success/error + duplicate-submit guard.
- Storefront access remains unauthenticated and unchanged.
- Existing merchant and platform tests continue to pass.

---

## 10. Conclusion

The mobile app already has a solid authenticated product, a shared API client, a working public marketing data layer, and complete storefront flows. The public experience is therefore an **extension**, not a rewrite:

1. Add the requested public route scheme and a 5-destination public shell.
2. Make the splash and router treat unauthenticated users as first-class public visitors.
3. Reuse the existing marketing providers/screens, filling the real gaps (Home, How It Works, About layouts, blog HTML, pricing FAQ, locale refresh, register explanation).
4. Preserve every merchant/platform route, permission rule and backend guarantee.
