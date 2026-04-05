# System Design.md — TextFlow SMS (iOS-first)

## 1. Goals
- iCloud-based storage & sync for: Schedules, Templates, Quick Contacts, History, Analytics.
- Scheduling engine to support:
  - One-time schedules
  - Recurring schedules (daily/weekly/monthly)
  - Time-based suggestions
- Feature gating using RevenueCat entitlements.

## 2. Non-goals (MVP)
- Auto-sending SMS/iMessage in background
- Reading SMS/iMessage inbox
- Automatic replies to incoming SMS/iMessage without user action
- Bulk messaging automation

## 3. Entities (CloudKit Records)
Use CloudKit private DB. Suggested record types:

### 3.1 CKRecord Types

#### TFUserProfile
- id (recordName = appleUserId hash)
- createdAt
- preferredLanguage
- theme (light/dark/system)
- timezone
- firstLaunchAt
- hasCompletedOnboarding (bool)
- analyticsOptIn (bool)

#### TFSchedule
- scheduleId (UUID string)
- createdAt, updatedAt
- recipientName (string, optional)
- recipientPhone (string)  ✅ stored in iCloud private DB
- messageBody (string)     ✅ stored in iCloud private DB
- scheduledAt (Date)       (for one-time or next occurrence)
- scheduleType (enum: oneTime, recurring)
- recurringRule (JSON string, optional)
- status (enum: active, paused, archived)
- lastTriggeredAt (Date, optional)
- nextTriggerAt (Date, optional)  (computed and stored)
- notificationId (string) (maps to UNNotificationRequest identifier)
- tags (array string optional: "work", "personal")

#### TFTemplate
- templateId
- name
- category (enum)
- body
- createdAt, updatedAt
- usageCount (int)

#### TFQuickContact
- contactId
- displayName
- phone
- group (enum or string)
- createdAt, updatedAt
- lastUsedAt

#### TFHistoryEvent
- eventId
- type (enum: scheduled_created, scheduled_triggered, schedule_opened_messages, template_used, etc.)
- timestamp
- scheduleId (optional)
- templateId (optional)
- contactId (optional)
- meta (JSON) — MUST NOT include message body or phone if analyticsOptIn=false

#### TFAnalyticsDaily
- day (YYYY-MM-DD)
- scheduledCount
- triggeredCount
- templatesUsedCount
- topHour (0-23)
- updatedAt

## 4. Scheduling Engine

### 4.1 One-time
- When user creates schedule:
  - Validate date in future
  - Persist TFSchedule with scheduledAt
  - Create local notification with identifier = scheduleId
  - On notification tap → open Messages composer with SMS URL scheme

### 4.2 Recurring
Store recurrence rule:
- daily: time HH:mm
- weekly: daysOfWeek [1..7] + time
- monthly: dayOfMonth [1..31] + time
All calculations in device timezone.

Algorithm:
- Compute nextTriggerAt = first next occurrence after now
- Schedule local notification for nextTriggerAt only (not infinite).
- When triggered and user taps:
  - Mark lastTriggeredAt = now
  - Compute nextTriggerAt again
  - Reschedule notification (next)

This avoids iOS limit problems with too many future notifications.

### 4.3 Notification limits handling
iOS has limits on pending notifications. Use “schedule only next occurrence” strategy.

## 5. Time-based scheduling suggestions
Inputs:
- User’s TFHistoryEvent (only those created in app)
- Recipient-specific interactions (quick contact usage, schedule creation times)

Method:
- Build histogram per recipient (hour buckets 0-23)
- Suggest top 3 hours with confidence score:
  confidence = (recipientSampleSize / 30) capped + dispersion adjustment
- Only show if sampleSize >= 10.

## 6. Paywall & Gating
RevenueCat entitlements:
- entitlement_pro (active for weekly/monthly/yearly)
- entitlement_lifetime

Free tier limits enforced locally:
- schedulesPerMonth = 5
- templatesMax = 3
- quickContactsMax = 5
- historyMax = 100

If user exceeds:
- show Paywall
- on purchase success → unlock.

## 7. Focus Mode “Auto-Reply” (App Store Safe MVP)
MVP implementation:
- Feature name: **Focus Reply Assistant**
- User sets reply templates per Focus mode (Work/Driving/Sleep/Custom)
- When Focus changes (or user opens app in Focus):
  - app shows suggested reply template + quick “compose in Messages” action
- Optional: scheduled reminder when Focus begins to send a reply to selected people (user chooses).

Do NOT claim background auto-reply to incoming texts.

## 8. Localization
All strings in Localizable.strings for:
- Arabic (RTL)
- Greek
- English (US/UK)
- Portuguese (BR)
- Chinese (Simplified)
- German
- Russian
- Japanese
- Korean
- Turkish
- Spanish
- Italian
- French
- Vietnamese

RTL:
- Use leading/trailing constraints; avoid hardcoded left/right.

## 9. Observability
- Local diagnostics screen (hidden) to export logs (no PII)
- Crash reporting optional (Sentry), must not include message data.

