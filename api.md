# API.md — TextFlow SMS (Optional Backend)

## Base URL
https://api.textflow.app/v1

## Auth
- Sign in with Apple token exchanged for backend JWT
- JWT stored in Keychain

## Endpoints (No PII)

### POST /auth/apple
Request:
- identityToken (string)
Response:
- jwt (string)
- userId (uuid)

### POST /events
Headers: Authorization: Bearer <jwt>
Body:
- eventName
- timestamp
- properties (JSON, no message text, no phone)

### GET /config
Headers: Authorization
Response:
- paywallCopy
- featureFlags
- announcement

