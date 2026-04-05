// ContentView.swift
// WhatsappScheduler
//
// Root tab navigation for the app.

import SwiftUI

struct ContentView: View {

    @EnvironmentObject var scheduleVM: ScheduleViewModel
    @EnvironmentObject var templateVM: TemplatesViewModel
    @EnvironmentObject var contactsVM: ContactsViewModel
    @EnvironmentObject var historyVM:  HistoryViewModel

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label(NSLocalizedString("tab_home", comment: ""),
                          systemImage: "clock.badge.checkmark.fill")
                }

            TemplatesView()
                .tabItem {
                    Label(NSLocalizedString("tab_templates", comment: ""),
                          systemImage: "rectangle.stack.fill")
                }

            ContactsView()
                .tabItem {
                    Label(NSLocalizedString("tab_contacts", comment: ""),
                          systemImage: "person.2.fill")
                }

            HistoryView()
                .tabItem {
                    Label(NSLocalizedString("tab_history", comment: ""),
                          systemImage: "clock.arrow.circlepath")
                }

            AnalyticsView()
                .tabItem {
                    Label(NSLocalizedString("tab_analytics", comment: ""),
                          systemImage: "chart.bar.fill")
                }

            SettingsView()
                .tabItem {
                    Label(NSLocalizedString("tab_settings", comment: ""),
                          systemImage: "gearshape.fill")
                }
        }
        .tint(DS.Color.whatsAppGreen)
    }
}

#Preview {
    ContentView()
        .environmentObject(ScheduleViewModel())
        .environmentObject(TemplatesViewModel())
        .environmentObject(ContactsViewModel())
        .environmentObject(HistoryViewModel())
}
