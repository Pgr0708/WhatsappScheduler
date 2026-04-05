# UIUX.md — TextFlow SMS (Figma/Design Source of Truth)

## 0. Design Goals
- Premium iOS look, minimal friction.
- “Liquid Glass” elements (blur, translucency, layered cards).
- Accessibility: Dynamic Type, high contrast.
- RTL support for Arabic.

## 1. Brand & Visual System
### 1.1 Name
TextFlow

### 1.2 Theme
- System default + toggle (Light/Dark/System)
- Liquid glass surfaces: `Material.ultraThin` and `Material.thin`

### 1.3 Colors (tokens)
- Primary: #3B82F6 (Blue)
- Accent: #22C55E (Green)
- Warning: #F59E0B
- Danger: #EF4444
- Background Light: #F7F8FA
- Background Dark: #0B0F17
- Card: glass material + subtle border

### 1.4 Typography
- Title: SF Pro Display Semibold
- Body: SF Pro Text Regular
- Captions: SF Pro Text Regular (smaller)
- Use Dynamic Type styles (`.title`, `.headline`, `.body`, `.caption`)

### 1.5 Iconography
- SF Symbols only for MVP (fast, consistent)
- App Icon: minimal chat bubble + clock motif

---

## 2. Navigation Structure
Tab Bar (5 tabs):
1. Home
2. Schedule
3. Templates
4. History
5. Settings

Home shows next scheduled items + shortcuts.

---

## 3. Screen-by-screen Specs

### 3.1 Splash Screen
- Center logo (glass card)
- Fade in/out 1.0s
- Background gradient subtle

### 3.2 Onboarding (3–5 pages)
Each page:
- Illustration area (top 60%)
- Title + subtitle
- Page dots
- Primary button “Continue”
- Secondary “Skip” visible at top-right
Pages:
1) Schedule messages
2) Templates
3) Recurring reminders
4) Focus reply assistant
5) Analytics

### 3.3 Apple Sign-In
- “Continue with Apple” button
- Explain iCloud sync & privacy

### 3.4 Permissions
- Notifications permission rationale
- iCloud status check screen (if iCloud disabled, show instructions)

### 3.5 Paywall
- Hero title: “Unlock Pro”
- Feature bullets (icons)
- Plans:
  - Weekly $2
  - Monthly $6
  - Yearly $50 (3-day free trial ONLY)
  - Lifetime $150
  - Welcome offer lifetime $20 (highlighted)
- Buttons:
  - Primary: “Start Free Trial” when Yearly selected
  - Primary: “Continue” for other plans
  - Secondary: Restore Purchases
  - Close/Skip: visible
- Legal: auto-renew disclosure

### 3.6 Home
- Top: greeting + search
- Card: “Next scheduled”
- Quick actions row:
  - New schedule
  - Templates
  - Quick contacts
- List: upcoming schedules

### 3.7 Schedule Create/Edit
Fields:
- Recipient (name optional)
- Phone (required)
- Message body (required; counter)
- Date picker + time picker
- Recurrence toggle:
  - None / Daily / Weekly / Monthly
  - Weekly: choose days chips
  - Monthly: day-of-month selector
- CTA:
  - “Schedule”
- Secondary:
  - “Preview in Messages” (opens composer)

### 3.8 Templates
- Search bar
- Categories filter chips
- List of templates (glass rows)
- FAB: “New Template”

Template editor:
- Name
- Category
- Body
- Save

### 3.9 Quick Contacts
- List with groups
- Add contact modal
- Optional “Import from Contacts” (permission)

### 3.10 History
- Search
- Filters (date range, contact)
- Timeline list:
  - scheduled created
  - reminder opened
  - template used

### 3.11 Analytics
Cards:
- Scheduled over last 7 days (bar chart)
- Peak hour
- Top contacts
- Top templates

### 3.12 Settings
Sections:
- Manage Account
- Profile
- Payments / Manage Subscriptions
- Appearance
- Language
- Notifications
- About
- Log Out

---

## 4. Components (Design System)
- GlassCard
- PrimaryButton
- SecondaryButton
- PlanSelectorCard
- Chip (filter/day)
- FormField (with icon)
- EmptyStateView
- PaywallFeatureRow

---

## 5. Micro-interactions
- Haptics on schedule success
- Smooth transitions between tabs
- Animated checkmark when copied template

---

## 6. Accessibility & Localization
- Use SF Symbols with accessibility labels
- Ensure text expands gracefully
- Arabic RTL: mirror layout; avoid directional icons unless mirrored

