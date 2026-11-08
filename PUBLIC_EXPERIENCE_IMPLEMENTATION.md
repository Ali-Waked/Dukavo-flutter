# Dukavo Public Mobile Experience — Implementation

Date: 2026-11-08
Scope: `mobile/` (Flutter). Companion to `PUBLIC_EXPERIENCE_AUDIT.md`.
Status: implemented; authenticated merchant and platform flows preserved.

---

## 1. What changed

The mobile app used to treat a signed-out visitor as an error state: the splash
sent every unauthenticated person to `/login`, and the only marketing pages were
legacy `/site/*` screens. This work turns the public experience into a
first-class part of the app:

- A five-destination public shell (Home, Features, Pricing, About, More) with a
  premium landing page, real API content, light/dark and AR/EN support.
- Canonical public routes (`/home`, `/features`, `/pricing`, `/how-it-works`,
  `/about`, `/faq`, `/blog`, `/contact`) with the legacy `/site/*` links kept as
  redirects.
- Auth-aware routing: public pages never force a login, protected pages still
  redirect to `/login?redirect=…`, and a successful login returns the visitor to
  the page they originally wanted.
- An honest invite-only `/register` page, a `/verify-email` screen and
  email-verification resend support, all built on existing backend features.
- Locale-aware API reads so switching AR/EN refetches public content instead of
  leaving stale prose on screen.

No WebView, no second state manager, no new runtime dependency, and no change to
the authenticated shells or their permission rules.

---

## 2. Routes

### Public routes

| Route | Screen | Data source |
| --- | --- | --- |
| `/home` | `PublicHomeScreen` | `/public/features`, `/public/pricing`, `/public/faq`, `/public/newsletters` |
| `/features` | `PublicFeaturesScreen` | `/public/features` |
| `/pricing` | `PublicPricingScreen` | `/public/pricing`, `/public/faq` |
| `/how-it-works` | `PublicHowItWorksScreen` | localized static copy (same as web) |
| `/about` | `PublicAboutScreen` | `/public/pages/about` |
| `/faq` | `PublicFaqScreen` | `/public/faq` |
| `/blog` | `PublicBlogScreen` | `/public/newsletters` (paginated) |
| `/blog/:slug` | `PublicBlogArticleScreen` | `/public/newsletters/{slug}` |
| `/contact` | `PublicContactScreen` | `POST /public/contact` |
| `/waitlist` | `PublicWaitlistScreen` | `POST /public/waitlist` |
| `/register` | `RegisterScreen` | none — invite-only explanation |
| `/pages/:key` | `PublicContentPageScreen` | `/public/pages/{key}` (terms, privacy, …) |

### Auth routes (unchanged backend)

| Route | Screen |
| --- | --- |
| `/login` (optional `?redirect=`) | `LoginScreen` |
| `/forgot-password` | `ForgotPasswordScreen` |
| `/reset-password?token=&email=` | `ResetPasswordScreen` |
| `/verify-email` | `VerifyEmailScreen` |
| `/setup` | `TenantSetupScreen` |

### Legacy redirects

| Old path | New path |
| --- | --- |
| `/site` | `/home` |
| `/site/features` | `/features` |
| `/site/pricing` | `/pricing` |
| `/site/faq` | `/faq` |
| `/site/newsletter` | `/blog` |
| `/site/newsletter/:slug` | `/blog/:slug` |
| `/site/contact` | `/contact` |
| `/site/waitlist` | `/waitlist` |
| `/site/page/:key` | `/pages/:key` |

The merchant overflow menu and the shop shell previously linked to `/site`; they
now point at `/home`, and the redirects above protect any saved or external
links.

### Shell

`StatefulShellRoute.indexedStack` owns four tabs (`/home`, `/features`,
`/pricing`, `/about`) so each tab keeps its scroll and form state. The fifth
destination, **More**, opens a modal bottom sheet rather than navigating. This
keeps the public route tree intact and avoids colliding with the authenticated
`/more` route.

The More sheet contains:

- Explore: How It Works, FAQ, Blog, Contact.
- Account: Sign in / Open app, Register (signed out only), Join the waitlist.
- Preferences: language (EN/AR) and theme (light/dark/system).
- Legal: Terms, Privacy, Browse shop.

The shared app bar shows the existing `AppLogo`, language and theme actions, and
an account action that opens the correct destination for the current auth
status.

---

## 3. Auth-aware behaviour

`splashDestination` now returns `/home` for `unauthenticated` (it previously
returned `/login`). The splash animation and timing from `b318636` are
unchanged.

`_redirect` in `app_router.dart` classifies paths:

- **Public**: marketing routes, `/blog/*`, `/pages/*`, legacy `/site/*`,
  `/shop/*`, `/register`, `/waitlist`, `/reset-password`. Every auth status may
  read them.
- **Auth**: `/login`, `/forgot-password`, `/register`. A signed-in merchant is
  sent to their permission-aware home; a platform operator to the platform
  dashboard.
- **Protected**: everything else. A signed-out visitor is sent to
  `/login?redirect=<encoded current URI>`.

`_loginLocation` preserves the full original URI, including query parameters.
`LoginScreen` receives the already-sanitized redirect and, after a successful
login, navigates to it; otherwise it falls back to `homePathFor`. The router's
normal permission checks run on that destination, so a preserved redirect can
never bypass RBAC.

`sanitizeRedirect` accepts only same-origin absolute paths:

- rejects `null`, empty strings, relative paths, schemes, authorities and `//`;
- rejects backslashes and control characters (including encoded NULs);
- refuses to bounce back into `/login`, `/register`, `/forgot-password`,
  `/reset-password` or `/splash`, preventing loops.

Platform operators are still confined to `/platform/*` except personal pages.
Merchant users without `platform` access still receive `/no-access` for platform
paths.

### Registration is invite-only

`config/fortify.php` enables `resetPasswords`, `emailVerification` and
`updatePasswords`, but **not** `Features::registration()`. There is no
`POST /auth/register` endpoint. `/register` therefore explains the real path in
(waitlist → invitation → sign in) and links to `/waitlist` and `/login`. It
does not render a form that could never succeed.

### Email verification

- `AuthRepository.resendVerificationEmail()` posts to
  `/api/v1/auth/email/verification-notification`.
- `VerifyEmailScreen` shows the session's verified state and email address,
  offers a resend, and surfaces the server's response.
- Fortify protects that endpoint with the `web` session guard while the mobile
  client uses a bearer token. The screen reports the server's refusal instead
  of fabricating success. Deep-link verification is still a documented
  limitation (see §8).

---

## 4. API integration

All requests go through the existing `ApiClient`; no endpoint was invented.

| Feature | Method and path | Notes |
| --- | --- | --- |
| Features | `GET /api/v1/public/features` | `available` and `coming_soon` grouped separately |
| Pricing | `GET /api/v1/public/pricing` | active plans; `price == null` renders “announced”; `purchase_available` respected |
| FAQ | `GET /api/v1/public/faq` | localized; rendered as expansion tiles |
| Content page | `GET /api/v1/public/pages/{key}` | published only; 404 shows a graceful “not available” state |
| Newsletter archive | `GET /api/v1/public/newsletters` | paginated, locale-keyed |
| Newsletter article | `GET /api/v1/public/newsletters/{slug}` | sanitized HTML body rendered natively |
| Waitlist | `POST /api/v1/public/waitlist` | hidden `website` honeypot; generic success |
| Contact | `POST /api/v1/public/contact` | hidden `website` honeypot; generic success |
| Newsletter subscribe | `POST /api/v1/public/newsletter/subscribe` | available through `MarketingActions` |
| Verification resend | `POST /api/v1/auth/email/verification-notification` | server-guarded; see §3 |

`MarketingActions` keeps the three public writes together and sends the same
`website` honeypot field the web forms use.

### Locale handling

- `effectiveLocaleProvider` resolves “follow device” to a concrete `en`/`ar`
  locale. The public providers watch it, so switching language disposes and
  refetches localized reads.
- Every localized request sends an explicit `?locale=` and keeps the
  `Accept-Language` header.
- `ApiClient` now falls back to the device language (instead of hardcoded `en`)
  for `Accept-Language` when no preference is stored.

---

## 5. Content rendering

`public_content.dart` contains two dependency-free renderers:

1. **Plain-text content pages** (`parseContentBlocks`, `parseLabeledItems`) —
   paragraphs, unordered/ordered lists, notes and `Title: description` items.
   Used by About and the generic content-page screen.
2. **Sanitized newsletter HTML** (`parseHtmlBlocks`, `parseHtmlInline`) —
   converts the backend's allow-listed HTML into native blocks and `TextSpan`s:
   headings, paragraphs, lists, blockquotes, `<pre>`, figures/captions, images,
   dividers, bold/italic/code and links (rendered as styled text). Scripts,
   styles and comments are dropped. No WebView and no HTML package.

All public copy is localized from `app_en.arb` / `app_ar.arb` (1078 keys each);
the ARB files stay in sync.

---

## 6. Design

- Brand colors unchanged: `#0F766E`, `#115E59`, `#A3E635`.
- Shared public widgets in `public_widgets.dart`: hero, section header, feature
  and plan cards, article cards, note/error/loading cards, CTA band, footer,
  detail scaffold and account routing.
- Mobile-first spacing, safe areas, `Wrap`-based chip rows, responsive grids and
  bounded content width.
- Light and dark themes use the existing `ColorScheme` tokens.
- Arabic switches to RTL automatically through Flutter's `Locale`; directional
  padding and alignment are used throughout the public widgets.
- Loading, empty, error and retry states exist for every API-backed section.

---

## 7. Tests

Added or updated:

| File | Coverage |
| --- | --- |
| `test/features/marketing/presentation/public_content_test.dart` | plain-text block parser, labeled items, HTML block parser, entity decoding, inline styles and link colors |
| `test/features/marketing/presentation/public_screens_test.dart` | Home (EN and AR), Features grouping, Pricing plans/FAQ, FAQ expansion, Contact validation, Waitlist email validation, Blog article HTML rendering, Register invite-only path |
| `test/app/router/public_router_test.dart` | protected path → login with preserved `redirect`, post-login return to destination, back-to-site action, redirect sanitization |
| `test/app/router/auth_destination_test.dart` | splash now sends signed-out visitors to `/home`; `sanitizeRedirect` accepts safe paths and rejects open-redirect/auth-loop targets |

The existing merchant, platform, shop, theme and auth tests are unchanged and
continue to exercise the preserved flows.

Commands run:

```bash
flutter pub get
flutter analyze     # No issues found!
flutter test
flutter build apk --debug
```

Build artifact: `build/app/outputs/flutter-apk/app-debug.apk`.

---

## 8. Known limitations and backend gaps

These are product/backend decisions documented rather than worked around:

| Gap | Reality | Mobile decision |
| --- | --- | --- |
| Public registration | Fortify registration is disabled; no `POST /auth/register` | `/register` explains the invite-only path and links to waitlist/login |
| Separate blog model | No blog table; `/public/newsletters` is the published article archive | `/blog` is the newsletter archive; no fake articles |
| Store discovery | No public store directory endpoint | No marketplace invented; `/shop` keeps the per-store link shape |
| Email verification deep link | Fortify signed routes exist, but mobile has no deep-link handler; resend is session-guarded | `/verify-email` shows the real state and server response; deep-link handling remains a follow-up |
| Account status page | Web has `/account-status`; mobile models `needsTenant` and platform separately | Invited/suspended states keep their existing routing; a dedicated status screen is a follow-up if the API exposes one |

---

## 9. Files

New:

- `lib/features/marketing/presentation/public_screens.dart`
- `lib/features/marketing/presentation/public_shell.dart`
- `lib/features/marketing/presentation/public_widgets.dart`
- `lib/features/marketing/presentation/public_content.dart`
- `lib/features/auth/presentation/register_screen.dart`
- `lib/features/auth/presentation/verify_email_screen.dart`
- `test/features/marketing/presentation/public_content_test.dart`
- `test/features/marketing/presentation/public_screens_test.dart`
- `test/app/router/public_router_test.dart`

Updated:

- `lib/app/router/app_router.dart`, `auth_destination.dart`, `route_paths.dart`
- `lib/app/theme/theme_controller.dart` (`effectiveLocaleProvider`)
- `lib/core/api/api_client.dart`, `api_paths.dart`
- `lib/features/marketing/application/marketing_providers.dart`,
  `data/newsletter_repository.dart`
- `lib/features/auth/application/auth_controller.dart`,
  `data/auth_data.dart`, `domain/auth_domain.dart`,
  `presentation/login_screen.dart`, `presentation/splash_screen.dart`
- `lib/features/shell/presentation/more_screen.dart`
- `lib/features/shop/presentation/shop_shell.dart`
- `lib/app/localization/l10n/app_en.arb`, `app_ar.arb` and generated
  localizations
- existing auth tests (verification method added to fakes),
  `test/app/router/auth_destination_test.dart`

Removed:

- `lib/features/marketing/presentation/marketing_screens.dart` (replaced by the
  new public screens; all references updated)

Not touched: merchant screens, `AppShell`, `PlatformShell`, permission mapping,
session/token handling, backend authorization, and the separate `frontend/` /
`backend/` working trees.
