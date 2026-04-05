# Security.md — TextFlow SMS

## 1. Data Classification
- Highly sensitive (must remain in iCloud private):
  - recipientPhone
  - messageBody
  - schedules & history
- Non-sensitive:
  - anonymous feature usage counts

## 2. iOS Security
- Store RevenueCat identifiers in Keychain
- Use CloudKit private DB
- Never log message bodies or full phone numbers
- Provide “Delete All Data” option (removes CloudKit records)

## 3. Backend Security (optional)
- TLS only
- JWT auth
- Rate limiting (Nginx + app)
- No PII accepted at API layer (reject if detected)

## 4. Subscription security
- Use RevenueCat as source of truth for entitlements
- On-device gating must refresh CustomerInfo on app foreground

