# System Design Document — TextFlow SMS
Version 1.0 — 2026-04-01

## Document Overview
This document defines system architecture, data models, workflows, and non-functional requirements for TextFlow SMS.

## 1. System Context
TextFlow is an iOS app that:
- Stores user-generated schedules/templates in iCloud (CloudKit private DB).
- Schedules local notifications for reminders.
- Opens Apple Messages app with prefilled data via URL scheme.

External systems:
- Apple iCloud/CloudKit
- Apple Push/Local Notifications
- RevenueCat + App Store

Optional external:
- Node.js backend (no message content)

## 2. Component Diagram
- iOS App (SwiftUI)
  - Scheduling module
  - Templates module
  - Contacts module
  - History module
  - Analytics module
  - Settings module
  - Paywall module
  - CloudKit repository
  - Notification service
- CloudKit Private DB
- RevenueCat

## 3. Key Workflows
### 3.1 Create schedule
User → Schedule form → validate → save schedule record → schedule local notification → update badge.

### 3.2 Notification triggered
Notification → user tap → app opens → open Messages composer via sms: URL → mark history event → compute next (if recurring).

### 3.3 Purchase unlock
Paywall → RevenueCat purchase → entitlement activated → local gating disabled.

## 4. Data Model
(Use models defined in System Design.md; repeated here as canonical.)

## 5. Non-Functional Requirements
- Reliability: local notification scheduling must succeed 99.9%
- Performance: history search < 1s for 10k records
- Privacy: do not transmit message content
- Accessibility: VoiceOver + Dynamic Type
- Localization: 15 languages + RTL Arabic

## 6. Edge Cases
- User changes timezone/clock → recompute nextTriggerAt at app launch
- Notifications disabled → show persistent banner and explain limitations
- iCloud disabled → app works locally only, show “Sync Off” indicator
- Purchase restore required → provide Restore button in paywall/settings
- Duplicate schedule IDs → use UUID scheduleId

## 7. Deployment
- iOS: App Store / TestFlight
- Backend (optional): Hostinger VPS + Nginx + Node.js + MySQL
