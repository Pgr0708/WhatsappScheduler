# TechStack.md — TextFlow SMS

## iOS
- Swift 5.9+
- SwiftUI
- CloudKit (iCloud sync)
- UNUserNotificationCenter (scheduled reminders)
- StoreKit 2
- RevenueCat SDK
- Charts framework
- App Intents (optional v1.1)

## Backend (Optional)
- Node.js 18 LTS
- Express
- MySQL 8
- Nginx reverse proxy (Hostinger VPS)
- PM2 process manager

## Why backend is optional
Core feature data must stay in iCloud private DB. Backend can be used for:
- remote config
- non-PII analytics
- support system
- marketing announcements

## Dependencies (iOS)
- RevenueCat (SPM)
Optional:
- Sentry
- Firebase Analytics (only if policy allows; keep minimal)

