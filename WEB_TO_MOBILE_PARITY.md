# Web → Mobile Parity

This document maps the Dukavo web platform (Laravel API + Vue client) to the
Flutter app. It records what is implemented, what is intentionally not
applicable to a native app, and what remains outstanding. It is deliberately
honest: a row marked ✗ is not implemented, even when the backend endpoint
exists.

- **Mobile source:** `mobile/` (Flutter 3.47.9, Dart 3.13.7)
- **API source of truth:** `backend/routes/api/v1.php`
- **Web source of truth:** `frontend/src/router/index.ts`
- **Last verified:** 2026-11-04
- **Quality gates:** `flutter analyze` clean; `flutter test` 122 passing;
  `dart format --set-exit-if-changed` clean.

---

## 1. Status legend

| Mark | Meaning |
| --- | --- |
| ✅ | Implemented in mobile against the real endpoint, with the same permission gate |
| ◐ | Implemented with a narrower scope than web (documented in Notes) |
| ✗ | Endpoint exists but the mobile surface is not built yet |
| — | Not applicable to a native mobile app (reason given) |

A ✅ does not imply pixel-for-pixel visual parity with Vue; it means the user
can complete the same business task against the same API and permissions.

---

## 2. Authentication, session and account

| Web surface | Mobile route | API | Status | Notes |
| --- | --- | --- | --- | --- |
| Login | `/login` | `POST /auth/login` | ✅ | Sanctum bearer token + CSRF priming; stores token in secure storage |
| Forgot password | `/forgot-password` | `POST /auth/forgot-password` | ✅ | Sends the reset link; the link itself opens the web reset page |
| Reset password form | `/reset-password?token=&email=` | `POST /auth/reset-password` | ◐ | Native form validates and submits the token; reset emails still link to the web page until app-link configuration exists |
| Email verification | `/verify-email` | Laravel verification routes | ✗ | No mobile screen; backend verification link is web-based |
| Session restore | boot | `GET /me` | ✅ | Silent restore, tenant + permission hydration |
| Workspace onboarding | `/setup` | `POST /onboarding/tenant` | ✅ | Name, slug, country, currency, timezone, locale, first store |
| Account status (pending/suspended) | — | `GET /me`, login errors | ◐ | Server message is surfaced on login; no dedicated status page |
| Workspace switching | More → workspace | `GET /me` with `X-Tenant` | ✅ | Session, permissions and tenant-scoped caches refresh |
| Logout | More/Settings | `POST /auth/logout` | ✅ | Clears token and local state |
| Profile, avatar, password, sessions | `/profile` | `/profile*` | ✅ | Avatar upload/remove, password change, revoke sessions |
| Notification preferences | `/settings` | `/profile/notifications*` | ✅ | Channel toggles respect backend capabilities |
| Theme / language | `/settings` | local | ✅ | Light/dark/system, English/Arabic/system |

---

## 3. Merchant workspace

### 3.1 Dashboard, analytics and reporting

| Web surface | Mobile route | API | Status | Notes |
| --- | --- | --- | --- | --- |
| Dashboard | `/dashboard` | `/tenant/dashboard*` | ✅ | KPIs, revenue trend, top products, dead stock, recent activity |
| Analytics | `/analytics` | `/tenant/analytics` | ✅ | Range/store filters, sales, products, stock health, limitations |
| Profit intelligence | `/profit` | `/tenant/profit` | ✅ | Filters, per-store/product breakdown, cost-completeness flags |
| Profit CSV export | `/profit` export | `GET /tenant/profit/export` | ✅ | Raw bytes written to a temp CSV; path shown |
| AI merchant copilot | `/ai/merchant-copilot` | `POST /tenant/ai/merchant-copilot` | ✗ | Endpoint and `ai.use` permission exist; no mobile chat screen |
| AI insights | dashboard panel | `GET /tenant/ai/insights` | ✗ | No mobile panel |
| AI availability | — | `GET /tenant/ai/availability` | ✗ | No mobile capability probe |

### 3.2 Catalogue

| Web surface | Mobile route | API | Status | Notes |
| --- | --- | --- | --- | --- |
| Product list | `/products` | `GET /tenant/products` | ✅ | Search, pagination, pull-to-refresh |
| Product create/edit | `/products/new`, `/products/:slug/edit` | `POST/PATCH /tenant/products` | ✅ | Variants, pricing, stock, status |
| Product detail | `/products/:slug` | `GET /tenant/products/{slug}` | ✅ | Full detail |
| Product delete | detail | `DELETE /tenant/products/{slug}` | ✅ | Confirmation dialog |
| Product slug check | form | `GET /tenant/products/slug-availability` | ✅ | Debounced availability feedback |
| Product images | detail | `/tenant/products/{slug}/images*` | ✅ | Upload, reorder, update, delete |
| Categories | `/categories` | `/tenant/categories*` | ✅ | Tree, create/edit/delete, slug check |
| Bundles | `/bundles` | `/tenant/bundles*` | ✅ | List/create/edit/delete |
| Bundle recommendations | web | `/tenant/bundles/recommendations` | ✗ | No mobile recommendations/explain surface |
| Bundle preview | web | `GET /tenant/bundles/{id}/preview` | ✗ | No mobile preview |

### 3.3 Inventory

| Web surface | Mobile route | API | Status | Notes |
| --- | --- | --- | --- | --- |
| Stock list | `/inventory` | `GET /tenant/inventory` | ✅ | Store filter, low-stock filter, pagination |
| Movements | inventory item | `/tenant/inventory/{id}/movements` | ✅ | Movement history |
| Adjust / receive | inventory item | `/tenant/inventory/adjust|receive` | ✅ | Absolute adjustment and additive receiving |
| Transfers | web | `POST /tenant/inventory/transfers` | ✗ | API path reserved; no transfer form |
| Intelligence overview | `/inventory/intelligence` | `/tenant/inventory/intelligence` | ✅ | Summary, filters, per-item metrics, export |
| Intelligence detail | item | `/tenant/inventory/{id}/intelligence` | ✅ | Available/reserved, demand, cover, suggested order |
| Intelligence export | overview | `/tenant/inventory/intelligence/export` | ✅ | CSV to temp directory |

### 3.4 Orders

| Web surface | Mobile route | API | Status | Notes |
| --- | --- | --- | --- | --- |
| Order list | `/orders` | `GET /tenant/orders` | ✅ | Search, status/store filters, pagination |
| Order detail | `/orders/:orderNumber` | `GET /tenant/orders/{orderNumber}` | ✅ | Totals, items, timeline |
| Transitions | detail | `GET/POST /tenant/orders/{id}/transitions|transition` | ✅ | Allowed transitions, optional payment marking |
| Order builder | `/orders/new` | `POST /tenant/orders` | ✅ | Customer/product pickers, validation |
| Order update/delete | web | `PATCH/DELETE /tenant/orders/{id}` | ◐ | Delete is available on detail; line-item editing is not exposed |
| Conversation cart → order | conversation | `/conversations/{id}/cart*` | ✗ | Cart lifecycle endpoints are not surfaced in mobile |
| Voice-message → order | conversation | `/voice-messages*` | ✗ | No voice message screen |

### 3.5 Customers and CRM

| Web surface | Mobile route | API | Status | Notes |
| --- | --- | --- | --- | --- |
| Customer list | `/customers` | `GET /tenant/customers` | ✅ | Search, pagination |
| Create/edit/delete | `/customers/new`, `/:id/edit` | `/tenant/customers*` | ✅ | Validated form, confirmation |
| Customer detail | `/customers/:id` | `GET /tenant/customers/{id}` | ✅ | Contact and order context |
| CRM overview | web | `/tenant/customers/{id}/crm/overview` | ✗ | No mobile CRM summary |
| CRM timeline | web | `/tenant/customers/{id}/crm/timeline` | ✗ | No mobile timeline |
| AI summary + refresh | web | `/tenant/customers/{id}/crm/summary*` | ✗ | No mobile summary |
| Customer memories | web | `/tenant/customers/{id}/memories*` | ✗ | No mobile memory management |

### 3.6 Conversations

| Web surface | Mobile route | API | Status | Notes |
| --- | --- | --- | --- | --- |
| Inbox | `/conversations` | `GET /tenant/conversations` | ✅ | Status/channel/unread filters, summary, pagination |
| Thread | `/conversations/:id` | `GET /tenant/conversations/{id}/messages` | ✅ | Messages, read state, retry |
| Reply / note / template | thread | `POST .../messages|notes|templates` | ✅ | Permission-gated |
| Assignment | thread | `POST .../assign` | ✅ | Assignee list from API |
| Conversation status update | thread | `PATCH /tenant/conversations/{id}` | ✅ | Status change from the thread menu |
| Conversation create/delete | web | `POST/DELETE /tenant/conversations` | ✗ | Not surfaced in mobile; the inbox consumes existing threads |
| Media / voice messages | thread | `.../media`, `/voice-messages*` | ✗ | Text and template messages only |
| AI reply draft | thread | `POST .../ai-reply-draft` | ✗ | No mobile draft action |
| AI summary | thread | `POST .../ai-summary` | ✗ | No mobile summary action |
| AI sales copilot | thread | `POST .../ai-sales-copilot` | ✗ | No mobile suggestion panel |

### 3.7 Growth, automation and recovery

| Web surface | Mobile route | API | Status | Notes |
| --- | --- | --- | --- | --- |
| Lost-sale recovery queue | `/recovery` | `/tenant/recovery-opportunities*` | ✅ | Summary, status filters, detail |
| Recovery AI draft | detail | `POST .../ai-draft` | ✅ | Returns draft through server response |
| Recovery dismiss / do-not-contact | detail | `POST .../dismiss|do-not-contact` | ✅ | Confirmation dialogs |
| Recovery contact / assign / snooze | web | `POST .../contact|assign|snooze` | ✗ | Not surfaced in mobile actions |
| WhatsApp accounts | `/whatsapp` | `/tenant/whatsapp-accounts*` | ✅ | List/create/edit/delete, verify, disconnect (the read-only `configuration` endpoint is not surfaced) |
| AI approvals | `/ai/approvals` | `/tenant/ai/actions*` | ✅ | List/detail, submit, approve, reject, execute |
| Automations hub | `/automations` | — | ✅ | Rules, runs, tasks entry points |
| Automation rules | `/automations` | `/tenant/automation/rules*` | ✅ | CRUD with JSON conditions/actions |
| Automation runs | runs | `/tenant/automation/runs*` | ✅ | Read-only history |
| Automation tasks | tasks | `/tenant/automation/tasks*` | ✅ | Complete/dismiss human tasks |
| Automation metadata | web | `GET /tenant/automation/meta` | ✗ | Hub uses static entries instead of the meta endpoint |

### 3.8 Stores, storefront, delivery and payments

| Web surface | Mobile route | API | Status | Notes |
| --- | --- | --- | --- | --- |
| Store list | `/stores` | `GET /tenant/stores` | ✅ | List, detail, create/edit/delete |
| Make default | store detail | `POST /tenant/stores/{id}/default` | ✅ | Confirmation |
| Storefront settings | `/storefront` | `/tenant/stores/{id}/storefront` | ✅ | Visibility, branding, contact, policies, sharing metadata |
| Shipping zones | `/shipping` | `/tenant/stores/{id}/shipping-zones*` | ✅ | CRUD, fees, free-delivery threshold |
| Payments | `/payments` | `/tenant/stores/{id}/payments` | ✅ | Cash on delivery; online shown unavailable with server reason |
| Store currency conversion | `/stores/:id/currency` | `/tenant/currencies`, `/stores/{id}/currency*` | ✅ | Server-owned rate preview with sample prices, confirmation dialog and idempotent apply; history shows past conversions |

### 3.9 Team, roles and audit

| Web surface | Mobile route | API | Status | Notes |
| --- | --- | --- | --- | --- |
| Team users | `/users` | `/tenant/users*` | ✅ | List/create/edit/delete, role assignment |
| Roles | `/roles` | `/tenant/roles*` | ✅ | List/create/edit/delete |
| Role permissions | role detail | `PUT /tenant/roles/{id}/permissions` | ✅ | Grouped permission editor |
| Role assign/revoke | user detail | `POST /tenant/roles/{id}/assign|revoke` | ✅ | Available from user roles section |
| Audit log | `/audit` | `/tenant/audit-logs*` | ✅ | List/detail, JSON old/new values |

---

## 4. Platform console

Platform operators use a separate five-tab shell because merchant tabs would
answer `403`. Platform-only users are never sent to tenant onboarding.

| Web surface | Mobile route | API | Status | Notes |
| --- | --- | --- | --- | --- |
| Platform dashboard | `/platform` | `GET /platform/dashboard` | ✅ | KPI cards, growth series, status breakdown, range selector |
| Tenants | `/tenants` | `/platform/tenants*` | ✅ | List/create/detail/edit/delete, suspend/activate, members |
| Platform users | `/platform/users` | `/platform/users*` | ✅ | List/create/detail/edit, role assign/revoke |
| Platform roles | `/platform/roles` | `/platform/roles*` | ✅ | CRUD + permission sync; taps open the permission editor |
| Platform audit | `/platform/audit` | `/platform/audit-logs*` | ✅ | List/detail, JSON diffs |
| Pricing plans | `/pricing-plans` | `/platform/pricing-plans*` | ✅ | CRUD, features/limits JSON |
| FAQ entries | `/faq-entries` | `/platform/faq-entries*` | ✅ | CRUD, bilingual fields |
| Content pages | `/content-pages` | `/platform/content-pages*` | ✅ | List/detail/edit, sections JSON, publish metadata |
| Waitlist | `/waitlist-entries` | `/platform/waitlist-entries*` | ✅ | List/detail/edit/delete |
| Contact messages | `/contact-messages` | `/platform/contact-messages*` | ✅ | List/detail/edit/delete |
| Newsletter subscribers | `/newsletter-subscribers` | `/platform/newsletter-subscribers*` | ✅ | List/detail/edit/delete |
| Newsletters | `/newsletters` | `/platform/newsletters*` | ✅ | List/create/edit/delete, bilingual body HTML |
| Newsletter slug check | form | `/platform/newsletters/slug-availability` | ✗ | No mobile debounced check |
| Newsletter content images | editor | `/platform/newsletters/content-images` | ✗ | No in-app image insertion for article bodies |
| AI newsletter content | editor | `POST /platform/ai/newsletter-content` | ✗ | No mobile generation action |
| Platform AI insights/availability | web panel | `/platform/ai/insights`, `/ai/availability` | ✗ | Backend availability route exists; mobile panel not built |

---

## 5. Public marketing site

The native marketing site reads the same public endpoints as Vue. Content is
not duplicated in the app.

| Web surface | Mobile route | API | Status | Notes |
| --- | --- | --- | --- | --- |
| Home | `/site` | features/pricing/faq/newsletters | ✅ | Hero, feature/pricing/newsletter previews, footer links |
| Features | `/site/features` | `GET /public/features` | ✅ | Localised feature list |
| Pricing | `/site/pricing` | `GET /public/pricing` | ✅ | Plans, intervals, highlight |
| FAQ | `/site/faq` | `GET /public/faq` | ✅ | Expandable entries |
| Blog / newsletter index | `/site/newsletter` | `GET /public/newsletters` | ✅ | List + subscribe dialog |
| Article | `/site/newsletter/:slug` | `GET /public/newsletters/{slug}` | ✅ | HTML body, reading time |
| Contact | `/site/contact` | `POST /public/contact` | ✅ | Validation + throttled endpoint |
| Waitlist | `/site/waitlist` | `POST /public/waitlist` | ✅ | Validation + success state |
| About / Privacy / Terms | `/site/page/:key` | `GET /public/pages/{key}` | ✅ | Server-rendered content pages |
| How it works | web `/how-it-works` | content page if published | ◐ | No dedicated link; reachable only if a `how-it-works` content page exists |
| Help | web `/help` | content page if published | ◐ | Same as above |
| Acceptable use | web `/acceptable-use` | content page if published | ◐ | Same as above |
| SEO, sitemap, robots, social cards | web only | — | — | No meaning in a native app; the Vue site remains the SEO surface |
| Cookie consent banner | web only | — | — | The app uses OS storage, not browser cookies (CSRF cookie is transport-only) |
| Browser keyboard shortcuts / multi-window | web only | — | — | Native navigation and gestures replace them |

---

## 6. Public storefront

Addressed by `/shop/:tenantSlug/:storeSlug` and readable without a session.

| Web surface | Mobile route | API | Status | Notes |
| --- | --- | --- | --- | --- |
| Store home + product grid | `/shop/:tenant/:store` | `GET /public/storefront/{tenant}/{store}` + `products` | ✅ | Categories, search, pagination |
| Product detail | `/shop/:tenant/:store/p/:slug` | `GET .../products/{slug}` | ✅ | Variant/quantity selection |
| Cart | `/shop/:tenant/:store/cart` | client-held | ✅ | Prices resolved by server at checkout |
| Checkout | `/shop/:tenant/:store/checkout` | `POST .../checkout` | ✅ | Zone-derived city/area, COD/online, idempotency key |
| Order confirmation | `/shop/:tenant/:store/order/:token` | `GET .../orders/{token}` | ✅ | Opaque token, totals, status |
| Order tracking form | `/shop/:tenant/:store/track` | `GET .../orders/{token}` | ✅ | Accepts a bare token or a pasted tracking link; opens the same token-authorised order view |
| Shipping quote / payment methods | checkout | `GET .../shipping-zones`, `/payment-methods` | ✅ | Online payment unavailable until a provider exists |

Storefront business rules enforced in mobile:

- The client never sends a price; the server resolves prices, shipping,
  discounts and totals.
- Public products have no product id; variants are addressed by `variants[].id`.
- `customer_name`, `customer_phone`, `payment_method`, an 8–100 character
  `idempotency_key` and a valid `shipping_address` are required.
- City options come from active shipping zones; an unmatched city fails
  checkout, so the UI derives the dropdown from the same zone payload.
- Online payment is shown as unavailable with the server's reason.

---

## 7. Explicitly not applicable

These web concerns have no native equivalent and are not gaps:

| Concern | Why not applicable |
| --- | --- |
| SEO metadata, sitemap, robots.txt, Open Graph | Search engines index the Vue marketing site; an installed app is not crawlable. |
| Cookie consent banner | The app has no analytics/marketing cookies. The CSRF cookie is an HTTP transport detail, not user tracking. |
| Browser back/forward, URL bar, tabs, keyboard shortcuts | Replaced by native navigation, system back, deep links and gestures. |
| Responsive desktop breakpoints | The app targets phones/tablets; layouts use Flutter constraints, not CSS breakpoints. |
| Server-side rendered marketing HTML | Content is fetched from the same public API and rendered natively. |
| Web push notifications | The backend has no web-push subscription contract; mobile push requires FCM/APNs infrastructure that does not exist yet. |
| Web-only file manager / drag-and-drop uploads | Mobile uses the platform photo picker and multipart upload. |

---

## 8. Remaining gaps and rationale

These are real gaps, not "not applicable". They are documented so the next
iteration can pick them up without re-auditing the backend.

| Area | Missing mobile surface | Backend status | Why it was deferred |
| --- | --- | --- | --- |
| Conversations | Cart lifecycle, voice messages, AI drafts/summaries/copilot | Implemented | Requires media playback/recording and a multi-step cart UI; the text inbox is complete |
| Customers | CRM overview/timeline/AI summary/memories | Implemented | Depends on AI availability and a richer detail layout; base customer CRUD is complete |
| AI | Merchant copilot, tenant insights, availability probe | Implemented | Conversational UI and capability gating need product copy; AI approvals are implemented |
| Inventory | Transfers | Implemented | Needs a two-store/item picker workflow; stock adjustments and intelligence are complete |
| Platform | AI insights/newsletter generation, newsletter slug check, content images | Implemented (availability route added) | Editor/image tooling is web-first; the rest of platform marketing is complete |
| Auth | Email-verification screen | Implemented | Verification links complete on the web; mobile sends the reset email and has a native reset form |
| Marketing | Dedicated how-it-works/help/acceptable-use links | Content pages | Reachable through content pages when published; about/privacy/terms are linked |

None of these gaps fabricates data or bypasses the backend. Every implemented
screen calls a real endpoint and respects the server permission.

---

## 9. Backend changes made for parity

The mobile work required one small backend addition, made in the existing
route/permission style:

- `GET /api/v1/platform/ai/availability` (`permission:ai.use`) — exposes the
  platform AI capability list used by the Vue AI panel. Two feature tests were
  added to `tests/Feature/AiPlatformEndpointTest.php`; the file passes
  **7 tests / 22 assertions**.

No other backend or frontend behaviour was rewritten. The Vue app and Laravel
business logic remain authoritative.

---

## 10. Re-verifying parity

```bash
cd mobile
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test

cd ../backend
php artisan test --filter=AiPlatformEndpointTest
```

For a full endpoint audit, compare `lib/core/api/api_paths.dart` with
`backend/routes/api/v1.php`. Every path in the mobile client should appear in
the backend file, and every permission gate should match the route middleware.
