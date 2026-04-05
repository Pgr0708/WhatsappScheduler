// Features/Settings/SettingsView.swift
// WhatsappScheduler

import SwiftUI

struct SettingsView: View {

    @StateObject private var purchaseService = RevenueCatService.shared
    @AppStorage("appColorScheme") private var colorScheme: String = "system"
    @AppStorage("appLanguage")    private var appLanguage: String = "en"
    @State private var showPaywall = false
    @State private var showSignOutConfirm = false
    @State private var notificationsEnabled = false

    var body: some View {
        NavigationStack {
            List {

                // MARK: Account
                Section(NSLocalizedString("settings_account", comment: "")) {
                    HStack {
                        Label(NSLocalizedString("settings_subscription", comment: ""),
                              systemImage: "checkmark.seal.fill")
                        Spacer()
                        Text(purchaseService.isPro
                             ? NSLocalizedString("settings_pro", comment: "")
                             : NSLocalizedString("settings_free", comment: ""))
                            .foregroundStyle(purchaseService.isPro ? DS.Color.whatsAppGreen : .secondary)
                            .font(.subheadline.bold())
                    }
                    if !purchaseService.isPro {
                        Button {
                            showPaywall = true
                        } label: {
                            Label(NSLocalizedString("settings_upgrade", comment: ""),
                                  systemImage: "crown.fill")
                                .foregroundStyle(DS.Color.whatsAppGreen)
                        }
                    }
                    Button {
                        Task { await purchaseService.restorePurchases() }
                    } label: {
                        Label(NSLocalizedString("settings_restore", comment: ""),
                              systemImage: "arrow.clockwise")
                    }
                }

                // MARK: Notifications
                Section(NSLocalizedString("settings_notifications", comment: "")) {
                    HStack {
                        Label(NSLocalizedString("settings_notifications_status", comment: ""),
                              systemImage: "bell.fill")
                        Spacer()
                        Text(notificationsEnabled
                             ? NSLocalizedString("settings_enabled", comment: "")
                             : NSLocalizedString("settings_disabled", comment: ""))
                            .foregroundStyle(notificationsEnabled ? .green : .red)
                            .font(.subheadline)
                    }
                    if !notificationsEnabled {
                        Button {
                            Task {
                                _ = try? await NotificationService.shared.requestAuthorization()
                                await refreshNotificationStatus()
                            }
                        } label: {
                            Label(NSLocalizedString("settings_enable_notifications", comment: ""),
                                  systemImage: "bell.badge.fill")
                                .foregroundStyle(DS.Color.whatsAppGreen)
                        }
                    }
                }

                // MARK: Appearance
                Section(NSLocalizedString("settings_appearance", comment: "")) {
                    Picker(NSLocalizedString("settings_theme", comment: ""),
                           selection: $colorScheme) {
                        Text(NSLocalizedString("settings_theme_system", comment: "")).tag("system")
                        Text(NSLocalizedString("settings_theme_light",  comment: "")).tag("light")
                        Text(NSLocalizedString("settings_theme_dark",   comment: "")).tag("dark")
                    }
                }

                // MARK: WhatsApp
                Section("WhatsApp") {
                    HStack {
                        Label(NSLocalizedString("settings_whatsapp_installed", comment: ""),
                              systemImage: "checkmark.circle.fill")
                        Spacer()
                        Text(WhatsAppService.shared.isWhatsAppInstalled()
                             ? NSLocalizedString("settings_yes", comment: "")
                             : NSLocalizedString("settings_no", comment: ""))
                            .foregroundStyle(WhatsAppService.shared.isWhatsAppInstalled() ? .green : .red)
                            .font(.subheadline)
                    }
                }

                // MARK: Privacy & Legal
                Section(NSLocalizedString("settings_privacy", comment: "")) {
                    Link(NSLocalizedString("settings_privacy_policy", comment: ""),
                         destination: URL(string: "https://yourwebsite.com/privacy")!)
                    Link(NSLocalizedString("settings_terms", comment: ""),
                         destination: URL(string: "https://yourwebsite.com/terms")!)
                }

                // MARK: About
                Section(NSLocalizedString("settings_about", comment: "")) {
                    HStack {
                        Text(NSLocalizedString("settings_version", comment: ""))
                        Spacer()
                        Text(appVersion).foregroundStyle(.secondary)
                    }
                }

                // MARK: Sign Out
                Section {
                    Button(role: .destructive) {
                        showSignOutConfirm = true
                    } label: {
                        Label(NSLocalizedString("settings_sign_out", comment: ""),
                              systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle(NSLocalizedString("settings_title", comment: ""))
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .confirmationDialog(
                NSLocalizedString("settings_sign_out_confirm", comment: ""),
                isPresented: $showSignOutConfirm,
                titleVisibility: .visible
            ) {
                Button(NSLocalizedString("settings_sign_out", comment: ""), role: .destructive) {
                    signOut()
                }
                Button(NSLocalizedString("cancel", comment: ""), role: .cancel) {}
            }
            .task { await refreshNotificationStatus() }
        }
    }

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(v) (\(b))"
    }

    private func refreshNotificationStatus() async {
        let status = await NotificationService.shared.authorizationStatus()
        notificationsEnabled = (status == .authorized || status == .provisional)
    }

    private func signOut() {
        // Clear local preferences (schedules/templates/contacts stored in iCloud)
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        // In production: sign out from Sign in with Apple credentials
        // ASAuthorizationAppleIDProvider().getCredentialState(...)
    }
}

#Preview {
    SettingsView()
}
