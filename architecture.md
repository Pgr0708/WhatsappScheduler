# Architecture.md — TextFlow SMS

## 0. Summary
TextFlow is an iOS 17+ SwiftUI app for planning and organizing SMS/iMessage communication:
- Schedules message reminders that open the Messages composer with prefilled content.
- Manages templates, quick contacts, history/search, recurring schedules, and analytics.
- Uses iCloud (CloudKit) for sync across devices (no server storage of user messages).
- Monetization via RevenueCat + StoreKit.

Backend (Node.js + MySQL) is **optional** and must not be required for core features.

---

## 1. Architectural Principles (Non‑negotiable)
1. **Privacy-first**: message text, phone numbers, schedule history stored in iCloud/private CloudKit.
2. **No background sending**: Messages are only sent when user taps Send in Messages composer.
3. **Offline-first**: core UX works without internet (except paywall and RevenueCat).
4. **Deterministic scheduling**: local notifications are the source of truth for reminders.
5. **Feature-gated**: free users can browse UI but hitting gated actions triggers paywall.

---

## 2. iOS Architecture (Clean MVVM + Services)

### 2.1 Modules
- AppShell (navigation, routing, tabs)
- Auth (Sign in with Apple)
- Paywall (RevenueCat)
- Scheduling (scheduled items + notification scheduling)
- Templates
- Contacts (quick access list)
- History + Search
- Recurrence Engine
- Analytics
- Settings (appearance, language, account, purchases)
- Localization

### 2.2 Layers
**Presentation**
- SwiftUI views
- Design system components (Liquid Glass)
- ViewModels (ObservableObject / @MainActor)

**Domain**
- Use cases: CreateSchedule, UpdateSchedule, ComputeNextOccurrence, etc.

**Data**
- Repositories with CloudKit + local caching
- NotificationScheduler service
- RevenueCat service
- Optional backend client

---

## 3. Data Storage Strategy (iCloud First)
### 3.1 Primary
- CloudKit private database (user-specific)
- Sync across user devices automatically

### 3.2 Secondary
- Local cache (optional) using SwiftData/CoreData for performance + offline
- Must reconcile with CloudKit.

> If you must choose one for MVP: **CloudKit only** (simpler, but needs careful error handling).

---

## 4. Optional Backend (Node.js + MySQL)
### 4.1 Allowed server responsibilities (must NOT store message body)
- Remote config (feature flags, onboarding copy, paywall experiments)
- Anonymous analytics events (no phone numbers, no message content)
- Support tickets (user initiated)
- App version/announcement feed

### 4.2 Not allowed on backend
- Storing full phone numbers
- Storing message text/body
- Storing schedules/history
- Any content that could reconstruct a user’s communication graph

---

## 5. Integrations
- **RevenueCat**: subscription status and offerings
- **StoreKit**: purchase and restore
- **CloudKit**: schedules/templates/contacts/history/analytics
- **UNUserNotificationCenter**: reminders
- **Intents / Shortcuts** (optional phase): quick schedule actions

---

## 6. Risks & Mitigations
- CloudKit sync failure → local fallback + retries + user messaging
- Notification permission denied → show in-app “Scheduling requires notifications” banner
- Country pricing handled by App Store tiering in RevenueCat/StoreKit (do not hardcode conversions)
- “Auto-reply” risk → implement as Focus-based templates + reminders, not background replies

---

## 7. Repository Layout (recommended)
/TextFlow-iOS
  /TextFlowApp
    /App
    /DesignSystem
    /Features
      /Onboarding
      /Paywall
      /Schedule
      /Templates
      /Contacts
      /History
      /Analytics
      /Settings
    /Services
      CloudKitService
      NotificationService
      RevenueCatService
      LocalizationService
    /Models
    /Repositories
    /Utilities
  /Docs
  /Scripts

/Backend (optional)
/backend
  /src
  /docs
