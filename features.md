
# Features.md — TextFlow SMS (MVP)

## Feature List (MVP)
1. Schedule SMS/iMessage reminders
2. Templates / quick replies
3. Quick contacts
4. History & search
5. Recurring schedules
6. Focus Mode reply assistant
7. Notification badges
8. Analytics dashboard
9. Time suggestions

---

## Feature Details + Acceptance Criteria

### 1) Schedule Messages
- Create schedule with phone + message + datetime
- Must validate phone format per locale (basic validation)
- Must disallow scheduling in past
- Must create local notification
- Must open Messages composer on notification tap

Acceptance:
- 100% reproducible open-to-compose flow
- Badge updates reflect pending schedules

### 2) Templates
- CRUD templates
- Insert template into schedule creation

Acceptance:
- <500ms load; iCloud sync works

### 3) Quick Contacts
- Save frequently used contacts
- Tap to create schedule

Acceptance:
- Works without Contacts permission (manual entry). Optional: import from Contacts with permission.

### 4) History & Search
- Show events and past schedules
- Search by keyword

Acceptance:
- 10k records search <1s

### 5) Recurring
- daily/weekly/monthly
- schedule only next occurrence
- pause/resume

Acceptance:
- No duplicate triggers; nextTriggerAt always in future

### 6) Focus Mode Reply Assistant
- Templates per Focus label
- CTA: “Compose reply” and “Schedule reply”
- Must not claim background auto-reply

### 7) Badges
- app icon badge count = # active pending schedules due in future
- clear on open / recalculated on launch

### 8) Analytics
- charts: scheduled per day (last 7/30)
- top contacts
- top templates
- peak hour

### 9) Time suggestions
- after at least 10 schedules to a contact
- show top 3 hours with confidence
