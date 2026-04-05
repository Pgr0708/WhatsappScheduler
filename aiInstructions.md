# AI Instructions.md — TextFlow SMS Coding Agent Playbook

## 0. Objective
Generate production-quality iOS SwiftUI code for TextFlow SMS based on Docs + Figma.

## 1. Hard Constraints (must follow)
- Do not implement background SMS sending.
- Do not read SMS inbox.
- Do not implement “auto-reply to incoming SMS” as a claim or feature in MVP.
- Store schedules/templates/history in CloudKit private DB (iCloud).
- Use SwiftUI, StoreKit 2, RevenueCat.
- Local notifications for reminders.
- When user taps reminder, open Messages composer with `sms:` URL scheme.
- Localization: all user-facing strings via `LocalizedStringKey` and .strings files.
- No backend dependency for core flows.

## 2. Output Requirements
- Implement in chunks (PR-by-PR):
  1) App shell + navigation + design system
  2) CloudKit repository + models
  3) Scheduling + notifications
  4) Templates + quick contacts
  5) History + search
  6) Recurrence engine
  7) Analytics
  8) Settings + localization
  9) Paywall + RevenueCat integration

## 3. Code Quality Rules
- Use async/await.
- Mark UI updates @MainActor.
- Add unit tests for recurrence calculation.
- Avoid force unwrap.
- Provide clear error states.

## 4. Figma Usage
- Recreate components:
  - GlassCard
  - PrimaryButton
  - Chip
  - PlanSelectorCard
- Ensure spacing and typography match.

## 5. Monetization Rules
Products:
- weekly_2
- monthly_6
- yearly_50_trial3d
- lifetime_150
- lifetime_offer_20 (welcome offer)
Only yearly has trial.

Free tier limits:
- 5 schedules / month
- 3 templates
- 5 quick contacts
When exceeded -> show paywall.

## 6. Localization
Generate base English first, then add keys for other languages.
Arabic must be RTL safe.

## 7. Privacy
Never log message body or phone number to analytics.
If analytics events exist, they must be aggregated and anonymous.
