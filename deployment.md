# Deployment.md — TextFlow SMS

## iOS Deployment
1. Apple Developer Program active
2. Configure Bundle ID
3. Capabilities:
   - iCloud (CloudKit)
   - Push Notifications (optional; local notifications still work)
4. Setup RevenueCat:
   - Products in App Store Connect
   - Offerings in RevenueCat dashboard
   - Welcome offer for Lifetime (special price) via StoreKit promotional offer if possible; otherwise implement as limited-time product in ASC.
5. TestFlight:
   - Internal testing
   - Fix crashes
6. App Store submission:
   - Clear wording: “Reminds you to send” not “auto-sends”

## Optional Backend Deployment (Hostinger VPS)
1. Provision Ubuntu VPS
2. Install Node.js 18, MySQL 8, Nginx, PM2
3. Configure Nginx reverse proxy to Node
4. Enable SSL with Let’s Encrypt
5. Setup PM2 ecosystem
6. Backup MySQL daily

