# Technical Requirements Document (TRD)
## TextFlow SMS - iOS Application

**Version:** 1.0
**Last Updated:** 2026-04-01
**App Name:** TextFlow SMS
**Platform:** iOS 17.0+

---

## 1. SYSTEM REQUIREMENTS

### 1.1 Hardware Requirements

#### Minimum Requirements (Support Tier)
- **Device:** iPhone 11 or newer
- **Storage:** 200MB available space
- **RAM:** 3GB minimum
- **Processor:** A13 Bionic or newer
- **Network:** WiFi or Cellular (4G/5G)
- **iOS Version:** iOS 17.0 minimum

#### Recommended Requirements (Optimal Experience)
- **Device:** iPhone 13 Pro or newer
- **Storage:** 500MB+ available
- **RAM:** 4GB+
- **Processor:** A15 Bionic or newer
- **Network:** 5G preferred
- **iOS Version:** iOS 18+

### 1.2 Supported iOS Versions
- **Minimum:** iOS 17.0
- **Target:** iOS 18+
- **Testing:** Test on iOS 17.0, 17.5, 18.0
- **Support Duration:** Latest 2 iOS versions

### 1.3 Supported Device Models
Primary Support: 
├─ iPhone 15 Pro Max 
├─ iPhone 15 Pro 
├─ iPhone 15 
├─ iPhone 14 Pro Max 
├─ iPhone 14 Pro 
├─ iPhone 14 
├─ iPhone 13 Pro Max 
├─ iPhone 13 Pro 
├─ iPhone 13 
├─ iPhone 13 mini 
├─ iPhone SE (3rd generation) 
└─ iPhone 12 series

Secondary Support (Basic): 
├─ iPhone 11 series 
├─ iPhone XS series 
└─ iPhone XR

Not Supported: 
├─ iPhone X or older 
├─ iPad (future consideration) 
└─ Watch/Mac versions



### 1.4 Network Requirements
- **Minimum Speed:** 1 Mbps
- **Optimal Speed:** 5+ Mbps
- **Bandwidth/Month:** <100MB
- **Connection Types:** WiFi, Cellular (2G/3G/4G/5G)
- **Offline Support:** Limited (local operations only)

---

## 2. TECHNOLOGY STACK

### 2.1 Frontend Stack

#### Swift & SwiftUI
Language: Swift 5.9+ UI Framework: SwiftUI Minimum Deployment Target: iOS 17.0

Core Libraries: 
├─ Foundation (Core Data, UserDefaults) 
├─ CloudKit (iCloud sync) 
├─ MessageUI (SMS/iMessage integration) 
├─ NotificationCenter (Local notifications) 
├─ Charts (Analytics graphs) 
├─ StoreKit 2 (In-app purchases) 
└─ Vision (Image processing, optional)


#### Key Frameworks
SwiftUI Components: 
├─ NavigationView/NavigationStack 
├─ TabView (bottom navigation) 
├─ Sheet/Modal presentations 
├─ List (scrollable content) 
├─ ScrollView (custom scrolling) 
├─ Form (input forms) 
└─ LazyVStack/HStack (performance)

Data Persistence: 
├─ CloudKit (iCloud sync) 
├─ Core Data (local storage) 
└─ UserDefaults (simple key-value)

Notifications: 
├─ UNUserNotificationCenter (local) 
├─ UNNotificationRequest (scheduling) 
└─ UNNotificationResponse (handling)

Payments: 
├─ StoreKit 2 API 
├─ RevenueCat SDK 
└─ Transaction management




#### Third-Party Libraries
```swift
Dependencies:
├─ RevenueCat-iOS (v7.0+) // In-app purchases
├─ Firebase-Analytics (v10+) // Analytics (optional)
├─ Sentry-iOS (v8+) // Crash reporting (optional)
└─ Lottie-iOS (v4+) // Animations (optional)

Package Manager: Swift Package Manager (SPM)
CocoaPods: None (prefer SPM)
Carthage: Not used


2.2 Backend Stack
Node.js Environment
Runtime: Node.js 18.0+ LTS
Package Manager: npm 8.0+
JavaScript: ES6+ / TypeScript 5.0+
Framework: Express.js 4.18+

Core Dependencies:
├─ express 4.18.2
├─ typescript 5.0+
├─ dotenv 16.0+
├─ cors 2.8.5
├─ helmet 7.0+
├─ mysql2 3.0+
├─ jsonwebtoken 9.0+
├─ bcryptjs 2.4+
├─ axios 1.4+
└─ joi 17.10+ (validation)

Development Tools:
├─ nodemon (auto-reload)
├─ ts-node (TS execution)
├─ jest (testing)
└─ eslint (linting)


Express.js Architecture
project/
├─ src/
│  ├─ controllers/ (route handlers)
│  ├─ services/ (business logic)
│  ├─ middleware/ (auth, validation)
│  ├─ models/ (database schemas)
│  ├─ routes/ (endpoint definitions)
│  ├─ config/ (environment setup)
│  ├─ utils/ (helper functions)
│  └─ app.ts (Express app)
├─ tests/ (unit & integration tests)
├─ .env (environment variables)
├─ package.json
└─ tsconfig.json



2.3 Database Stack
MySQL 8.0+
DBMS: MySQL 8.0 Community Edition
Port: 3306 (default)
Encoding: utf8mb4 (Unicode support)
Collation: utf8mb4_unicode_ci

Connection Pooling:
├─ Max Connections: 100
├─ Min Connections: 10
├─ Timeout: 30 seconds
└─ Retry Logic: 3 attempts

Backup Strategy:
├─ Daily automated backups
├─ Point-in-time recovery
├─ Replication to secondary (optional)
└─ Off-site backup storage


Database Client Library

Node.js MySQL Driver: mysql2/promise
ORM: Not used (raw queries or query builder)
Migrations: Manual versioning


2.4 Infrastructure & Hosting
Server Setup

Hosting Provider: Hostinger (Recommended)
Server Type: VPS (Virtual Private Server)
Operating System: Linux (Ubuntu 22.04 LTS)
CPU: 4 cores (2GB minimum)
RAM: 4GB (8GB recommended)
Storage: 100GB SSD
Bandwidth: 500GB/month (unlimited for overage)


Web Server
Web Server: Nginx 1.24+
SSL/TLS: Let's Encrypt (auto-renewal)
HTTP Version: HTTP/2
Compression: Gzip enabled
Caching: Nginx reverse proxy cache

Nginx Configuration:
├─ Reverse proxy to Node.js (port 3000)
├─ SSL termination
├─ Static file serving
├─ Rate limiting
└─ Gzip compression



Deployment Platform
Hosting: Hostinger VPS
CI/CD: GitHub Actions (or manual)
Monitoring: PM2 process manager
Logs: Nginx access/error logs
Database: MySQL on same VPS (initially)
Backup: Daily snapshots

PM2 Configuration:
├─ Auto-restart on crash
├─ Cluster mode (4 processes)
├─ Memory restart limit: 500MB
└─ Log rotation




2.5 Third-Party Services

Analytics & Monitoring

RevenueCat (Subscription Management)
├─ API: https://api.revenuecat.com/v1/
├─ SDK: RevenueCat-iOS
├─ Features: Subscription tracking, analytics
└─ Pricing: Free up to $10K MRR

Firebase Analytics (Optional)
├─ Event tracking
├─ User properties
├─ Crash reporting
└─ Pricing: Free tier sufficient

Sentry (Error Tracking - Optional)
├─ Crash reporting
├─ Performance monitoring
├─ Error aggregation
└─ Pricing: Free tier (50K errors/month)




Payment Processing

Stripe (Backend - Optional)
├─ Direct payment handling
├─ Webhook notifications
├─ Testing in Stripe Dashboard
└─ Security: PCI-DSS compliant

Apple Pay / StoreKit 2 (Preferred)
├─ In-app purchases
├─ Transaction verification
├─ Server-side receipt validation
└─ No additional fees (30% taken by Apple)





3. SYSTEM ARCHITECTURE

3.1 High-Level Architecture Diagram

┌─────────────────────────────────────────────────────┐
│              iOS Device (iPhone)                    │
│                                                     │
│  ┌──────────────────────────────────────────────┐ │
│  │           TextFlow SMS App (SwiftUI)         │ │
│  │  ┌─────────────────────────────────────────┐ │ │
│  │  │ UI Layer (Views & Navigation)           │ │ │
│  │  │  - Schedule Screen                      │ │ │
│  │  │  - Templates Screen                     │ │ │
│  │  │  - Analytics Screen                     │ │ │
│  │  │  - Settings Screen                      │ │ │
│  │  └─────────────────────────────────────────┘ │ │
│  │  ┌─────────────────────────────────────────┐ │ │
│  │  │ Data Layer                              │ │ │
│  │  │  - Core Data (Local Storage)            │ │ │
│  │  │  - UserDefaults (Settings)              │ │ │
│  │  │  - CloudKit (iCloud Sync)               │ │ │
│  │  └─────────────────────────────────────────┘ │ │
│  └──────────────────────────────────────────────┘ │
│  ┌──────────────────────────────────────────────┐ │
│  │ Native iOS APIs                              │ │
│  │  - MessageUI (SMS/iMessage)                  │ │
│  │  - NotificationCenter (Scheduling)           │ │
│  │  - StoreKit 2 (In-app purchases)             │ │
│  │  - CloudKit (Sync)                           │ │
│  └──────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘
         ↓                          ↓
┌─────────────────────────────────────────────────────┐
│        iCloud (Apple's Cloud Services)              │
│  - Automatic device sync                           │
│  - Backup & recovery                               │
│  - CloudKit database                               │
└─────────────────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────────────────┐
│    RevenueCat (Subscription Management)             │
│  - Purchase processing                             │
│  - Subscription tracking                           │
│  - Analytics                                       │
└─────────────────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────────────────┐
│    Apple App Store (Distribution)                   │
│  - App hosting                                     │
│  - Updates delivery                                │
│  - Review/approval                                 │
└─────────────────────────────────────────────────────┘




3.2 Data Flow Architecture

User Action (Schedule Message)
         ↓
SwiftUI View captures input
         ↓
ViewModel processes data
         ↓
Validation (date, time, phone)
         ↓
Data saved to Core Data
         ↓
Data synced to iCloud via CloudKit
         ↓
UNNotificationCenter schedules reminder
         ↓
At scheduled time: Notification fires
         ↓
User taps notification
         ↓
Messages app opens with pre-filled message
         ↓
User manually taps "Send"
         ↓
SMS/iMessage sent (native iOS)
         ↓
App logs message as "sent" to Core Data
         ↓
Update syncs to iCloud
         ↓
Analytics updated locally
         ↓
User sees message in History




3.3 Data Storage Architecture

Device Local Storage:
├─ Core Data
│  ├─ ScheduledMessages entity
│  ├─ MessageTemplates entity
│  ├─ Contacts entity
│  ├─ MessageHistory entity
│  └─ UserPreferences entity
├─ UserDefaults
│  ├─ App settings
│  ├─ User preferences
│  └─ Feature toggles
└─ Files
   └─ Backup exports (optional)

iCloud Sync (CloudKit):
├─ ScheduledMessages
├─ MessageTemplates
├─ Contacts
├─ MessageHistory
└─ Analytics data

Backend (MySQL - Future):
└─ User profile (optional)
└─ Subscription status (via RevenueCat)




4. API SPECIFICATIONS

4.1 Backend API Endpoints (Future Phase)

Base URL: https://api.textflow.app/v1

Endpoint: POST /api/users/register
├─ Headers: Content-Type: application/json
├─ Body: { applerId, email, deviceId }
└─ Response: { userId, token }

Endpoint: GET /api/users/profile
├─ Headers: Authorization: Bearer {token}
└─ Response: { userId, email, createdAt, subscriptionStatus }

Endpoint: POST /api/messages/schedule
├─ Headers: Authorization: Bearer {token}
├─ Body: { phoneNumber, messageText, scheduledTime }
└─ Response: { messageId, status }

Endpoint: GET /api/messages/history
├─ Headers: Authorization: Bearer {token}
├─ Query Params: ?limit=50&offset=0
└─ Response: { messages: [], total }

Endpoint: POST /api/analytics/events
├─ Headers: Authorization: Bearer {token}
├─ Body: { eventName, properties }
└─ Response: { success: true }




4.2 RevenueCat Integration

RevenueCat API Calls (from iOS):
├─ Purchases.shared.customerInfo()
│  └─ Get current subscription status
├─ Purchases.shared.purchasePackage()
│  └─ Handle purchase
├─ Purchases.shared.restorePurchases()
│  └─ Restore previous purchases
└─ Purchases.shared.getOfferings()
   └─ Get available plans

RevenueCat Events Tracked:
├─ Purchase initiated
├─ Purchase completed
├─ Subscription renewed
├─ Subscription cancelled
├─ Trial started
├─ Trial ended
└─ Refund requested





5. SECURITY REQUIREMENTS

5.1 Data Security

Encryption

Data at Rest:
├─ Core Data: iOS default encryption
├─ iCloud CloudKit: Apple's encryption
├─ Keychain: Sensitive tokens/keys
└─ No unencrypted data storage

Data in Transit:
├─ HTTPS/TLS 1.2+ (mandatory)
├─ Certificate pinning (optional)
├─ All API calls encrypted
└─ iCloud uses SSL/TLS



Authentication

Apple Sign-In (OAuth 2.0):
├─ Only authentication method
├─ No username/password storage
├─ Token-based verification
└─ Automatic account management

Session Management:
├─ Session timeout: 30 days
├─ Automatic re-authentication: Required
├─ Device ID verification: Yes
└─ Revoke token on logout: Yes




5.2 Privacy & Compliance

Privacy Standards:
├─ GDPR (EU users) - Compliant
├─ CCPA (California) - Compliant
├─ HIPAA - Not applicable
├─ PCI-DSS - Handled by Apple/RevenueCat
└─ COPPA - Not applicable (13+ only)

Data Collection:
├─ NO message content logging
├─ NO location tracking
├─ NO device activity monitoring
├─ NO user behavior profiling
├─ NO third-party data sharing

Data Retention:
├─ User account: Until deletion
├─ Messages: User-controlled (can delete)
├─ Analytics: Aggregated, anonymous
└─ Backups: 30-day retention



5.3 Apple Security Guidelines

Compliance:
├─ ✅ No background message sending
├─ ✅ User consent for all automation
├─ ✅ No deceptive practices
├─ ✅ Transparent data handling
├─ ✅ Approved frameworks only
└─ ✅ Follow App Store guidelines

App Transport Security:
├─ Minimum TLS 1.2
├─ All connections HTTPS
├─ No cleartext allowed
└─ Certificate validation enabled




6. PERFORMANCE REQUIREMENTS

6.1 Load & Response Times

Critical Paths:
├─ App launch: <2 seconds
├─ Schedule message: <1 second
├─ Template selection: <500ms
├─ Analytics load: <2 seconds
├─ Contact search: <300ms
└─ History scroll: Smooth (60 FPS)

API Response Times (Future):
├─ GET requests: <200ms
├─ POST requests: <500ms
├─ List operations: <1 second
└─ Search operations: <300ms




6.2 Storage & Memory

App Size:
├─ Minimum: 50MB
├─ Maximum: 150MB
├─ Over-the-air updates: <20MB increments

Memory Usage:
├─ Idle: <50MB
├─ Active use: 100-200MB
├─ Peak: <300MB
├─ No memory leaks

Local Storage Usage:
├─ With 1000 messages: ~5MB
├─ With 5000 messages: ~20MB
├─ With 10000 messages: ~40MB
├─ User data: <100MB total
└─ Recommended free space: 500MB+



6.3 Battery & Network Impact

Battery Consumption:
├─ Idle (per hour): <2% battery
├─ Active use (per hour): 5-10% battery
├─ Scheduling notifications: Minimal impact
└─ Sync operations: <1% per sync

Network Usage:
├─ Average session: 1-5MB
├─ Monthly average: 10-50MB
├─ iCloud sync: <5MB/day
├─ Analytics: <100KB/day
└─ No heavy downloads





7. INFRASTRUCTURE REQUIREMENTS

7.1 Server Specifications (MVP - Minimal)

For first 50K users:

CPU: 2-4 cores
├─ Dual-core sufficient initially
├─ Quad-core recommended
└─ Scale to 8-core at 500K users

Memory (RAM): 4-8GB
├─ 4GB minimum
├─ 8GB recommended
└─ 16GB+ at scale

Storage: 100GB SSD
├─ Database: ~50GB (grows with users)
├─ Backups: ~50GB
├─ Logs: ~10GB/month

Network: 100 Mbps
├─ Sufficient for <100K users
├─ Upgrade to 1 Gbps at scale
└─ Redundant connections (optional)





7.2 Database Specifications

MySQL Database:
├─ Database size (50K users): ~20GB
├─ Database size (500K users): ~200GB
├─ Backup frequency: Daily
├─ Replication: Secondary instance (optional)
├─ High availability: Master-slave setup (v2.0)
└─ Connection pool: 100 max connections

Indexes:
├─ User ID (primary)
├─ Message scheduled time
├─ Contact phone number
├─ History timestamp
└─ Analytics date





7.3 CDN & Static Content

Static Assets:
├─ App binary: App Store
├─ Images/icons: Bundle with app
├─ Analytics data: Local only
└─ No CDN needed (initially)

Future CDN (v2.0):
├─ Provider: Cloudflare or AWS CloudFront
├─ Content types: Updated assets
├─ TTL: 24 hours
└─ Geo-distribution: Global




8. TESTING REQUIREMENTS

8.1 Test Coverage Goals

Unit Tests:
├─ Target: >80% code coverage
├─ Models: 100% coverage
├─ ViewModels: 90% coverage
├─ Utilities: 95% coverage
└─ Services: 85% coverage

Integration Tests:
├─ Core Data operations
├─ CloudKit synchronization
├─ iCloud backup/restore
├─ Notification scheduling
└─ Payment flow

UI Tests:
├─ Critical user flows
├─ Onboarding flow
├─ Payment flow
├─ Schedule message flow
├─ Settings changes
└─ Language switching





8.2 Device Testing

Testing Devices:
├─ iPhone 15 Pro (primary)
├─ iPhone 15 (secondary)
├─ iPhone 14 (compatibility)
├─ iPhone 13 (compatibility)
├─ iPhone SE (minimum spec)
├─ iPad Air (future)
└─ Simulator (development)

iOS Versions Tested:
├─ iOS 17.0 (minimum support)
├─ iOS 17.5 (mid-range)
├─ iOS 18.0+ (latest)
└─ Beta versions (during development)





8.3 Performance Testing

Load Testing:
├─ Simulate 1000 scheduled messages
├─ Simulate 5000 message history
├─ Simulate 100+ contacts
├─ Monitor memory during operations
└─ Test with low bandwidth (3G)

Stress Testing:
├─ Rapid schedule/cancel messages
├─ Mass delete operations
├─ Concurrent iCloud sync
├─ Multiple app instances (OS level)
└─ Extended usage (2+ hours)




9. MONITORING & LOGGING

9.1 Application Monitoring

Metrics to Track:
├─ App crashes (Sentry)
├─ Error rates
├─ API response times
├─ User session duration
├─ Feature usage (analytics)
├─ Subscription events
├─ Payment success rate
└─ iCloud sync status

Alerting Thresholds:
├─ Crash rate >1%: CRITICAL
├─ API errors >5%: HIGH
├─ Message delivery <95%: MEDIUM
├─ Feature broken: CRITICAL
└─ Unusual spike: LOW




9.2 Logging Strategy

App-Level Logs:
├─ Info: Major user actions
├─ Warning: Non-critical errors
├─ Error: Operations failed
├─ Debug: Development only
└─ Verbose: Detailed debugging

Sensitive Data:
├─ NO message content logged
├─ NO phone numbers logged
├─ NO personal data logged
├─ NO tokens logged
└─ Hash user IDs when logging

Log Retention:
├─ Device local: 7 days
├─ Server logs: 30 days
├─ Archived logs: 90 days
└─ PII: Purged immediately



10. DEPLOYMENT REQUIREMENTS

10.1 Build & Release Process

Build Steps:
├─ Compile Swift code
├─ Run unit tests
├─ Run UI tests
├─ Build signing
├─ Asset validation
├─ IPA generation
└─ TestFlight upload

Version Management:
├─ Semantic versioning (1.0.0)
├─ Build number: Auto-increment
├─ Release notes: Required
├─ Change log: Maintained
└─ Git tagging: Per release




10.2 App Store Submission

Requirements:
├─ Bundle ID: com.textflow.sms
├─ Minimum iOS: 17.0
├─ Privacy policy: Required
├─ Screenshots: 5 languages
├─ App description: 4000 chars max
├─ Keywords: 100 chars max
├─ Support URL: Required
├─ Contact email: Required
└─ Category: Productivity

Signing:
├─ Distribution certificate: Required
├─ Provisioning profile: App Store
├─ Code signing identity: Verified
└─ Entitlements: iCloud, Push (optional)




10.3 Backend Deployment

Server Deployment:
├─ Platform: Hostinger VPS
├─ OS: Ubuntu 22.04 LTS
├─ Node.js: v18 LTS
├─ Process manager: PM2
├─ Web server: Nginx
├─ SSL: Let's Encrypt
├─ Database: MySQL 8.0
└─ Backups: Automated daily

CI/CD Pipeline:
├─ Git repo: GitHub
├─ Trigger: Push to main branch
├─ Build: GitHub Actions
├─ Test: Run test suite
├─ Deploy: SSH to VPS
├─ Health check: Verify service
└─ Rollback: On failure





11. LOCALIZATION REQUIREMENTS

11.1 Supported Languages

Priority 1 (Launch):
├─ English (USA)
├─ English (UK)
├─ Spanish (Spain)
├─ French (France)
├─ German
└─ Japanese

Priority 2 (Month 1-2):
├─ Chinese (Simplified)
├─ Portuguese (Brazil)
├─ Italian
├─ Korean
└─ Russian

Priority 3 (Month 2-3):
├─ Arabic (Saudi Arabia)
├─ Turkish
├─ Vietnamese
├─ Greek
└─ Hindi




11.2 Localization Assets

Strings Files (.strings):
├─ Localizable.strings (UI text)
├─ Localizable.stringsdict (plurals)
├─ Infoplist.strings (metadata)
└─ One file per language

Numbers & Currency:
├─ Locale-specific formatting
├─ Currency symbols ($ £ ₹ د.إ)
├─ Decimal separators
└─ Date/time formats

RTL Languages:
├─ Arabic support (RTL)
├─ Text alignment dynamic
├─ Button order reversed
└─ Image mirroring (if needed)




12. ACCESSIBILITY REQUIREMENTS

12.1 Accessibility Standards

WCAG 2.1 Level AA Compliance:

Visual:
├─ Color contrast: 4.5:1 (text)
├─ Large text support: 2x default
├─ No color-only information
└─ Content distinguishable

Audio & Video:
├─ Captions: Not applicable
├─ Transcripts: Not applicable
└─ Audio descriptions: N/A

Motor:
├─ Touch target: 44x44 points min
├─ No long press required
├─ Keyboard navigation: Full support
└─ Alternative input: Siri supported

Cognitive:
├─ Clear language (10th-grade level)
├─ Consistent navigation
├─ Clear error messages
└─ Predictable interactions




12.2 VoiceOver Support

Features:
├─ All text: Readable by screen reader
├─ Icons: Descriptive labels
├─ Buttons: Clear action descriptions
├─ Form fields: Associated labels
├─ Tables: Proper markup
└─ Images: Descriptive alt text

Testing:
├─ Enable VoiceOver in Settings
├─ Navigate entire app with rotor
├─ Test all critical flows
├─ Verify content order
└─ Check hint text



13. COMPLIANCE & LEGAL

13.1 App Store Compliance

Guidelines Adherence:
├─ No unauthorized API access
├─ No private framework use
├─ Clear metadata (no keywords stuffing)
├─ Honest feature descriptions
├─ No misleading screenshots
├─ No deceptive pricing
├─ Clear auto-renewal terms
└─ Easy subscription management

Required Disclosures:
├─ Privacy policy (prominent link)
├─ Terms of service
├─ Subscription details (pricing, renewal)
├─ Free trial conditions
└─ Cancellation method (visible)



13.2 Privacy Regulations

GDPR (European Union):
├─ Data processing agreement
├─ Right to access data
├─ Right to deletion
├─ Data portability
├─ Consent for processing
└─ Privacy policy (specific requirements)

CCPA (California):
├─ Privacy policy transparency
├─ Consumer rights
├─ Opt-out mechanisms
├─ Data sale disclosure
└─ Non-discrimination on privacy



13.2 Privacy Regulations

GDPR (European Union):
├─ Data processing agreement
├─ Right to access data
├─ Right to deletion
├─ Data portability
├─ Consent for processing
└─ Privacy policy (specific requirements)

CCPA (California):
├─ Privacy policy transparency
├─ Consumer rights
├─ Opt-out mechanisms
├─ Data sale disclosure
└─ Non-discrimination on privacy



14. DOCUMENT HISTORY
Version    Date        Changes
 1.0    2026-04-01    Initial TRD
 
 
 
---

Due to length constraints, I'll create a comprehensive **SUMMARY** and provide the remaining files in a structured format.

---

## **SUMMARY OF WHAT I'VE CREATED & NEXT STEPS**

### **CREATED SO FAR:**
✅ **Product Requirements Document (PRD)** - Complete with:
- Project overview, vision, goals
- 9 core features detailed
- Target user personas (4 types)
- 15+ language support
- Pricing strategy (4 plans with country-specific pricing)
- KPIs and success metrics
- Privacy & safety compliance

✅ **Technical Requirements Document (TRD)** - Complete with:
- Hardware/iOS version requirements
- Technology stack (SwiftUI, Node.js, MySQL, Hostinger)
- System architecture diagrams
- API specifications
- Security requirements
- Performance benchmarks
- Deployment strategy

### **REMAINING FILES TO CREATE (I'll continue):**

1. **System Design Document.md** - Architecture, database schema, data flows
2. **Functional Requirements Document.md** - Detailed feature specifications
3. **Architecture.md** - System architecture breakdown
4. **MVP Tech Doc.md** - Minimum viable product specifications
5. **Features.md** - Feature list with acceptance criteria
6. **UI/UX.md** - Design specifications, wireframes
7. **TechStack.md** - Detailed technology choices & justifications
8. **Database.md** - Schema, queries, optimization
9. **API.md** - Complete API endpoints documentation
10. **Security.md** - Security protocols, encryption, compliance
11. **Deployment.md** - Step-by-step deployment guide
12. **AI Instructions.md** - Prompts for Claude agents
13. **Development Checklist.md** - Day-by-day build checklist

### **WHICH FILES FOR GOOGLE STITCHLY (for Figma Design):**

**Send these 3 files to Google Stitchly:**
1. **UI/UX.md** (wireframes, color schemes, typography)
2. **Features.md** (feature specifications with user flows)
3. **ProductRequirements.md** (reference for design requirements)

**Google Stitchly will generate:**
- Figma design file automatically
- Component library
- Design system
- Prototype interactions

### **WORKFLOW (Step-by-Step):**





STEP 1: Get all MD files ✅ (Creating now) 
↓ 
STEP 2: Create Figma Design File 
└─ Upload PRD + UI/UX to Google Stitchly 
└─ Generate Figma file 
└─ Export as JSON/Component library 
↓ 
STEP 3: Create Figma Account 
└─ Login to figma.com 
└─ Import generated design 
└─ Create API token 
└─ Export design specifications 
↓ 
STEP 4: Create Claude Agent Instructions (AI Instructions.md) 
└─ Reference Figma designs 
└─ Include all MD documents 
└─ Define code generation rules 
↓ 
STEP 5: Feed to Claude Opus 4.6 
└─ Frontend: Swift UI code generation 
└─ Backend: Node.js code generation 
└─ Database: MySQL schema 
↓ 
STEP 6: Deploy 
└─ iOS: TestFlight → App Store 
└─ Backend: Hostinger VPS 
└─ Database: MySQL on Hostinger






