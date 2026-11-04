# Dukavo Mobile — API Integration Map

> **Reference note.** This map covers the original merchant scope. The app now
> also calls platform, team/RBAC, growth, automation, marketing and public
> storefront endpoints; the complete, current coverage matrix is
> [`../WEB_TO_MOBILE_PARITY.md`](../WEB_TO_MOBILE_PARITY.md), and
> `lib/core/api/api_paths.dart` is the authoritative list of paths used by the
> client.

This document maps every endpoint the Flutter client calls to the backend route,
the permission that protects it, the mobile layer that owns it, and the payload
or response shape the client relies on.

Source of truth:

- Routes and permissions: `backend/routes/api/v1.php`.
- Response shapes: `backend/app/Http/Resources/`.
- Request validation: `backend/app/Http/Requests/`.
- Mobile transport: `lib/core/api/api_client.dart`.
- Mobile path constants: `lib/core/api/api_paths.dart`.

Base URL: `<origin>/api/v1` (for example
`http://10.0.2.2:8000/api/v1` from the Android emulator).

---

## 1. Transport conventions

### Headers

| Header | When | Value |
| --- | --- | --- |
| `Accept` | every request | `application/json` |
| `Authorization` | after login | `Bearer <plain-text Sanctum token>` |
| `X-Tenant` | tenant-scoped requests | active tenant slug |
| `Accept-Language` | every request | `en` or `ar` |
| `X-XSRF-TOKEN` | Fortify routes | value of the `XSRF-TOKEN` cookie |
| `Content-Type` | JSON writes | `application/json` |
| `Content-Type` | avatar upload | `multipart/form-data` |
| `Idempotency-Key` | workspace onboarding | generated UUID-style key |

### Envelope

Success:

```json
{
  "success": true,
  "message": "Optional human-readable message.",
  "data": {},
  "meta": {
    "current_page": 1,
    "last_page": 4,
    "per_page": 20,
    "total": 73,
    "from": 1,
    "to": 20
  }
}
```

Error:

```json
{
  "success": false,
  "message": "Human-readable summary.",
  "errors": {
    "email": ["The email field is required."]
  },
  "code": "OPTIONAL_BUSINESS_CODE"
}
```

`ApiClient` unwraps `data`, converts `meta` into `PaginationMeta`, maps
`errors` into `ApiException.fields` and maps HTTP status codes to
`statusCode`. A `204 No Content` is treated as an empty success.

### Authentication flow

Fortify's login, logout, forgot-password and reset-password routes run under
the `web` middleware. The client therefore:

1. calls `GET /sanctum/csrf-cookie` (outside `/api/v1`);
2. sends the cookie-derived `X-XSRF-TOKEN` header on the Fortify request;
3. stores the returned bearer token in secure storage;
4. sends `Authorization: Bearer ...` on every subsequent request.

A `401` from any endpoint clears the stored token and returns the app to login.

---

## 2. Authentication and session

| Method | Path | Permission | Mobile owner | Notes |
| --- | --- | --- | --- | --- |
| `POST` | `/auth/login` | public (throttled) | `features/auth/data/auth_data.dart` | Body `{email, password}`; CSRF-primed. Returns `{user, token, token_type}` in `data`. |
| `POST` | `/auth/logout` | authenticated | same | Revokes the current token and ends the cookie session. |
| `GET` | `/me` | authenticated (`tenant.optional`) | same | Boot payload: `user`, `active_tenant`, `tenants`, `roles`, `permissions`, `permission_catalogue`. |
| `POST` | `/onboarding/tenant` | authenticated | same | Body `{name, store_name?}` plus `Idempotency-Key`; returns the provisioned `{id, name, slug}`. |
| `POST` | `/auth/forgot-password` | public (throttled) | same | Body `{email}`. Response is intentionally generic. |
| `POST` | `/auth/reset-password` | public (throttled) | same | Body `{email, token, password, password_confirmation}`. |

Mobile session state: `AuthStatus.unknown` → `unauthenticated` |
`needsTenant` | `authenticated`. `AuthController` exposes the session,
permission set and a `refreshSession()` used after profile edits.

## 3. Profile, devices and notification preferences

| Method | Path | Permission | Mobile owner | Notes |
| --- | --- | --- | --- | --- |
| `GET` | `/profile` | authenticated | `features/profile/data/profile_data.dart` | `ProfileResource`. |
| `PATCH` | `/profile` | authenticated | same | Body `{name?, email?, phone?, locale?}`. |
| `POST` | `/profile/avatar` | authenticated | same | Multipart field `avatar`; JPG/PNG/WebP, max 2048 KB. |
| `DELETE` | `/profile/avatar` | authenticated | same | Returns the updated profile. |
| `PUT` | `/profile/password` | authenticated | same | Body `{current_password, password, password_confirmation}`. |
| `GET` | `/profile/sessions` | authenticated | same | List of Sanctum tokens with `is_current`. |
| `DELETE` | `/profile/sessions` | authenticated | same | Revokes every other device. |
| `DELETE` | `/profile/sessions/{token}` | authenticated | same | Revokes one device by token id. |
| `GET` | `/profile/notifications` | authenticated (`tenant.optional`) | same | Per-channel event preferences. |
| `PUT` | `/profile/notifications` | authenticated (`tenant.optional`) | same | Same shape as the GET body. |
| `GET` | `/profile/notifications/channels` | authenticated (`tenant.optional`) | same | `{channel: {event: {available, reason, label}}}`. |

## 4. Notification centre

| Method | Path | Permission | Mobile owner | Notes |
| --- | --- | --- | --- | --- |
| `GET` | `/notifications` | authenticated | `features/notifications/data/notification_data.dart` | Paginated; filters include `unread`. |
| `GET` | `/notifications/unread-count` | authenticated | same | `{count}`. |
| `POST` | `/notifications/read-all` | authenticated | same | Marks every notification read. |
| `POST` | `/notifications/{id}/read` | authenticated | same | Numeric id. |
| `POST` | `/notifications/{id}/unread` | authenticated | same | Numeric id. |
| `DELETE` | `/notifications/{id}` | authenticated | same | Deletes one notification. |

## 5. Dashboard and analytics

All routes below require the `tenant` middleware and the permission shown.

| Method | Path | Permission | Mobile owner | Notes |
| --- | --- | --- | --- | --- |
| `GET` | `/tenant/dashboard` | `dashboard.view` | `features/dashboard/data/dashboard_data.dart` | Headline aggregates and recent activity. |
| `GET` | `/tenant/dashboard/revenue` | `dashboard.view` | same | Revenue series for the chart. |
| `GET` | `/tenant/dashboard/top-products` | `dashboard.view` | same | Top products list. |
| `GET` | `/tenant/dashboard/dead-stock` | `dashboard.view` | same | Dead-stock list. |
| `GET` | `/tenant/analytics` | `dashboard.view` | `features/analytics/data/analytics_data.dart` | Query `from`, `until`, `store_id`, `currency`, `product_limit`; returns `context`, `range`, `comparison`, `kpis`, `sales_trends`, `product_performance`, `stock_health`, `limitations`. |

`GET /tenant/dashboard/summary` and `GET /tenant/analytics/metrics` exist in the
backend but are not used by mobile; the screens read the aggregate endpoints
above.

## 6. Stores and workspace settings

| Method | Path | Permission | Mobile owner | Notes |
| --- | --- | --- | --- | --- |
| `GET` | `/tenant/stores` | `stores.view` | `features/stores/data/store_data.dart` | Read-only in mobile; feeds the store picker and order builder. |
| `GET` | `/tenant/settings` | `settings.view` | `features/settings/data/settings_data.dart` | Fields `name`, `contact_email`, `phone`, `currency`, `timezone`, `locale`. |
| `PATCH` | `/tenant/settings` | `settings.manage` | same | Partial update of the same fields. |

Store create/update/delete/default routes exist but no mobile screen calls them.

### 6.1 Storefront, shipping and payment settings

| Method | Path | Permission | Mobile owner | Notes |
| --- | --- | --- | --- | --- |
| `GET` | `/tenant/stores/{store}/storefront` | `storefront.view` | `features/storefront/data/storefront_data.dart` | Returns `store_id`, `name`, `slug`, `status`, `description`, `logo_url`, `storefront_enabled`, `currency`, `settings`, `updated_at`. |
| `PATCH` | `/tenant/stores/{store}/storefront` | `storefront.manage` | same | Partial update; `settings` is merged server-side. Presentation fields are nullable and may be cleared with `null`. |
| `GET` | `/tenant/stores/{store}/shipping-zones` | `shipping.view` | `features/shipping/data/shipping_data.dart` | Unpaginated list (`data` is a list). |
| `POST` | `/tenant/stores/{store}/shipping-zones` | `shipping.manage` | same | Body `{name, city?, areas?, fee, free_shipping_threshold?, is_active?, sort_order?}`. The server lower-cases areas. |
| `PATCH` | `/tenant/stores/{store}/shipping-zones/{zone}` | `shipping.manage` | same | The zone must belong to the store in the URL. |
| `DELETE` | `/tenant/stores/{store}/shipping-zones/{zone}` | `shipping.manage` | same | Returns `204`. |
| `GET` | `/tenant/stores/{store}/payments` | `payments.view` | `features/payments/data/payment_data.dart` | Returns `settings` (`cod_enabled`, `cod_instructions`) and `methods` with the server's availability and reason. |
| `PATCH` | `/tenant/stores/{store}/payments` | `payments.manage` | same | Only `cod_enabled` and `cod_instructions` are accepted. Online payment is never reported as available. |

The mobile store picker is local UI state; every request still resolves the
store through the tenant-scoped route binding, so a sibling tenant's store id
returns `404`.

## 7. Catalogue

| Method | Path | Permission | Mobile owner | Notes |
| --- | --- | --- | --- | --- |
| `GET` | `/tenant/products` | `products.view` | `features/products/data/product_data.dart` | Paginated; filters include `search`, `status`, `category_id`. |
| `POST` | `/tenant/products` | `products.create` | same | Product payload with variants. |
| `GET` | `/tenant/products/slug-availability` | `products.view` | same | Query `slug`; returns availability. |
| `GET` | `/tenant/products/{slug}` | `products.view` | same | Products are addressed by slug. |
| `PATCH` | `/tenant/products/{slug}` | `products.update` | same | Update by slug. |
| `DELETE` | `/tenant/products/{slug}` | `products.delete` | same | Archive/delete by slug. |
| `GET` | `/tenant/categories` | `categories.view` | `features/categories/data/category_data.dart` | Unpaginated list (`data` is a list). |
| `GET` | `/tenant/categories/tree` | `categories.view` | same | Nested tree used by the category screen. |
| `GET` | `/tenant/categories/slug-availability` | `categories.view` | same | Query `slug`. |
| `POST` | `/tenant/categories` | `categories.manage` | same | Create. |
| `GET` | `/tenant/categories/{id}` | `categories.view` | same | Numeric id. |
| `PATCH` | `/tenant/categories/{id}` | `categories.manage` | same | Numeric id. |
| `DELETE` | `/tenant/categories/{id}` | `categories.manage` | same | Returns `204`. |

Product image routes (`/images`, `/images/reorder`) are defined in
`ApiPaths` but no mobile screen uploads or reorders images yet.

## 8. Orders

| Method | Path | Permission | Mobile owner | Notes |
| --- | --- | --- | --- | --- |
| `GET` | `/tenant/orders` | `orders.view` | `features/orders/data/order_data.dart` | Paginated; query `search`, `status`, `customer_id`. Eager-loads store, customer and items. |
| `POST` | `/tenant/orders` | `orders.create` | same | Body `{customer_id?, store_id, customer_name?, customer_phone?, notes?, items:[{product_id?, product_variant_id, quantity}]}`. The server prices the order. |
| `GET` | `/tenant/orders/{order_number}` | `orders.view` | same | Read by human order number (`ORD-000123`). |
| `GET` | `/tenant/orders/{id}/transitions` | `orders.view` | same | Returns `{current, allowed:[{status,label}], is_cancellable}`. |
| `POST` | `/tenant/orders/{id}/transition` | `orders.update` | same | Body `{status, note?, payment_status?}`. |
| `PATCH` | `/tenant/orders/{id}` | `orders.update` | same | Reserved for future edit screen; the current mobile flow creates and transitions only. |
| `DELETE` | `/tenant/orders/{id}` | `orders.delete` | same | Numeric id. |

Order statuses: `pending`, `confirmed`, `processing`, `shipped`, `delivered`,
`cancelled`. Payment statuses: `unpaid`, `partially_paid`, `paid`, `refunded`.

## 9. Customers

| Method | Path | Permission | Mobile owner | Notes |
| --- | --- | --- | --- | --- |
| `GET` | `/tenant/customers` | `customers.view` | `features/customers/data/customer_data.dart` | Paginated; `search`, `status`. |
| `POST` | `/tenant/customers` | `customers.create` | same | Body includes `name`, `phone`, `email`, `status`. |
| `GET` | `/tenant/customers/{id}` | `customers.view` | same | Numeric id. |
| `PATCH` | `/tenant/customers/{id}` | `customers.update` | same | Numeric id. |
| `DELETE` | `/tenant/customers/{id}` | `customers.delete` | same | Numeric id. |

Customer status is `active` or `inactive`. CRM overview/timeline/summary,
memories and AI summary routes exist in the backend but are not implemented in
mobile.

## 10. Inventory

| Method | Path | Permission | Mobile owner | Notes |
| --- | --- | --- | --- | --- |
| `GET` | `/tenant/inventory` | `inventory.view` | `features/inventory/data/inventory_data.dart` | Query `store_id`, `product_variant_id`, `low_stock`, `page`, `per_page`. |
| `GET` | `/tenant/inventory/low-stock` | `inventory.view` | same | Low-stock rows. |
| `GET` | `/tenant/inventory/{id}/movements` | `inventory.view` | same | Movement history with `direction` and `balance_after`. |
| `POST` | `/tenant/inventory/adjust` | `inventory.manage` | same | Absolute quantity: `{store_id, product_variant_id, quantity, low_stock_threshold?, note?, idempotency_key?}`. |
| `POST` | `/tenant/inventory/receive` | `inventory.manage` | same | Additive quantity with the same required fields. |
| `POST` | `/tenant/inventory/transfers` | `inventory.manage` | same | Defined in `ApiPaths`; no mobile screen calls it yet. |

`InventoryResource` uses `reserved_quantity` and computed `available`; product,
variant and store are nested only when loaded. The client tolerates their
absence.

## 11. Conversations

| Method | Path | Permission | Mobile owner | Notes |
| --- | --- | --- | --- | --- |
| `GET` | `/tenant/conversations` | `conversations.view` | `features/conversations/data/conversation_data.dart` | Filters `search`, `status`, `channel`, `mine`, `unassigned`, `unread`, `store_id`. |
| `GET` | `/tenant/conversations/summary` | `conversations.view` | same | Counts for open, pending, unassigned, unread. |
| `GET` | `/tenant/conversations/assignees` | `conversations.view` | same | Assignable team members. |
| `POST` | `/tenant/conversations` | `conversations.reply` | same | Create a conversation. |
| `GET` | `/tenant/conversations/{id}` | `conversations.view` | same | Numeric id. |
| `PATCH` | `/tenant/conversations/{id}` | `conversations.assign` | same | Status/assignment updates. |
| `DELETE` | `/tenant/conversations/{id}` | `conversations.assign` | same | Delete. |
| `GET` | `/tenant/conversations/{id}/messages` | `conversations.view` | same | Paginated, newest first. |
| `POST` | `/tenant/conversations/{id}/messages` | `conversations.reply` | same | Body `{body}` (plus media where supported). |
| `POST` | `/tenant/conversations/{id}/notes` | `conversations.reply` | same | Internal note. |
| `POST` | `/tenant/conversations/{id}/templates` | `conversations.reply` | same | Approved WhatsApp template; only for WhatsApp threads. |
| `POST` | `/tenant/conversations/{id}/messages/{message}/retry` | `conversations.reply` | same | Retry a failed outbound message. |
| `POST` | `/tenant/conversations/{id}/read` | `conversations.view` | same | Marks the thread read. |
| `POST` | `/tenant/conversations/{id}/assign` | `conversations.assign` | same | Assign to a user. |

Conversation statuses: `open`, `pending`, `closed`. Channels include
`whatsapp`, `web`, `manual`, `other`. Message media, voice messages, carts,
AI drafts/summaries, events and recovery opportunities are not implemented in
mobile.

## 12. Deliberately unimplemented backend surfaces

The following route groups exist and are intentionally out of scope for the
first mobile release:

| Area | Backend routes |
| --- | --- |
| Platform administration | `/platform/*` (tenants, users, roles, audit, pricing, FAQ, content, waitlist, contact, newsletters) |
| Workspace team and RBAC | `/tenant/users*`, `/tenant/roles*` |
| Product bundles | `/tenant/bundles*` |
| Product images | `/tenant/products/{slug}/images*` |
| Inventory intelligence and transfers | `/tenant/inventory/intelligence*`, `/tenant/inventory/transfers` |
| Customer CRM and memory | `/tenant/customers/{id}/crm*`, `/tenant/customers/{id}/memories*` |
| Conversation extras | `/tenant/conversations/{id}/events`, `/media`, `/voice-messages*`, `/cart*`, `/ai-*` |
| Recovery opportunities | `/tenant/recovery-opportunities*` |
| WhatsApp accounts | `/tenant/whatsapp-accounts*` |
| Profit intelligence | `/tenant/profit*` |
| Automations | `/tenant/automation*` |
| Audit logs | `/tenant/audit-logs*` |
| AI actions and copilots | `/tenant/ai/*`, `/tenant/conversations/{id}/ai-*` |

Adding any of these should follow the same feature-first structure: domain
entity and repository contract, data source plus model, Riverpod provider and
actions, then a presentation screen guarded by the matching permission slug.

## 13. Error handling contract

| Status | Meaning in the app |
| --- | --- |
| `401` | Session expired: clear token, return to login. |
| `403` | The role lacks the permission; show the server message. |
| `404` | The resource is gone or belongs to another tenant. |
| `409` | Business-rule conflict; `code` may carry a machine-readable reason. |
| `422` | Validation; `fields` are mapped onto form fields where available. |
| `429` | Throttled; show the server message and let the user retry later. |
| `0` | Network failure; `isNetworkError` is true. |

The UI never branches on a Dio type. Every failure reaching a screen is an
`ApiException`, and every screen renders it through the shared error view or
snackbar.
