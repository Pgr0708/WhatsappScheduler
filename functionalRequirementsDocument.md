# Functional Requirements Document (FRD) — TextFlow SMS

## 1. Scope
MVP features:
1) Schedule SMS Messages
2) Templates/Quick Replies
3) Contact Quick Access
4) History & Search
5) Recurring Messages
6) Focus Mode Reply Assistant
7) Notification Badges
8) Scheduled Analytics
9) Time-based suggestions

## 2. Roles
- Free User
- Paid User (Pro)
- Lifetime User
- Admin (internal only: QA/testing flags)

## 3. Functional Requirements

### FR-001 Onboarding
- Show splash
- Show 3–5 onboarding pages (features + images)
- Ask permissions:
  - Notifications
  - iCloud usage explanation (no separate permission toggle, but detect iCloud availability)
- Proceed to Paywall with Skip

Acceptance:
- User can skip paywall and reach app
- App clearly indicates feature limits for free tier

### FR-010 Sign in
- Authentication via Sign in with Apple only
- No manual login form

Acceptance:
- If user declines Sign in with Apple, app offers limited local-only mode OR blocks (choose policy).
Recommended: require Apple sign-in to enable iCloud sync.

### FR-100 Schedule message (one-time)
Inputs:
- recipient name (optional)
- phone number (required)
- message body (required)
- date/time (required, must be in future)

Behaviors:
- Save schedule in CloudKit
- Create local notification with id = scheduleId
- Update app badge count

Acceptance:
- When notification is tapped, open Messages composer with prefilled number + message body
- User must tap Send in Messages

### FR-110 Schedule message (edit/cancel)
- User can edit scheduledAt/message/recipient
- Editing reschedules notification
- Cancel removes schedule and cancels notification

### FR-120 Recurring schedule
- daily at time
- weekly on selected days at time
- monthly on day-of-month at time
- pause/resume
- only next occurrence scheduled as local notification

Acceptance:
- After each trigger (tap), next occurrence computed and notification rescheduled

### FR-200 Templates
- Create/edit/delete templates
- Categories
- Insert template into schedule composer

Acceptance:
- Template insertion is 1 tap

### FR-300 Quick Contacts
- Create/edit/delete quick contacts
- Grouping
- Tap contact → create schedule prefilled

### FR-400 History & Search
- Log events: created schedule, opened Messages from schedule, used template
- Search by name/phone/message text (stored in iCloud private)
- Filter by date range

### FR-500 Analytics
- Display aggregates:
  - scheduled per day
  - most used templates
  - most messaged contact (based on schedules)
  - most common hour
- Only from app-created data (not device SMS database)

### FR-600 Focus Mode Reply Assistant (MVP-safe)
- User sets template per Focus mode label (Work/Driving/Sleep/Custom)
- When Focus is on, app suggests quick reply + schedule for later
- Does not read incoming messages; does not auto-send replies

### FR-700 Settings
- Manage Account (Apple ID identity + iCloud status)
- Profile (display name optional)
- Payment methods (link to Apple subscriptions)
- Log out (sign out local; keep iCloud data as per Apple)
- Appearance (light/dark/system)
- Language selection
- Restore purchases

### FR-800 Paywall gating
- Free tier can use limited counts
- When user tries gated action beyond limit, show paywall
- Yearly plan includes 3-day trial only

### FR-900 Localization
- All UI strings localizable
- Arabic RTL support

