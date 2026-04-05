// WhatsappSchedulerApp.swift
// WhatsappScheduler
//
// App entry point. Sets up services and decides whether to show
// onboarding or the main tab interface.

import SwiftUI

@main
struct WhatsappSchedulerApp: App {

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    @StateObject private var scheduleVM  = ScheduleViewModel()
    @StateObject private var templateVM  = TemplatesViewModel()
    @StateObject private var contactsVM  = ContactsViewModel()
    @StateObject private var historyVM   = HistoryViewModel()

    init() {
        NotificationService.shared.setup()
    }

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
                    .environmentObject(scheduleVM)
                    .environmentObject(templateVM)
                    .environmentObject(contactsVM)
                    .environmentObject(historyVM)
                    .task { await RevenueCatService.shared.setup() }
            } else {
                OnboardingView()
            }
        }
    }
}
