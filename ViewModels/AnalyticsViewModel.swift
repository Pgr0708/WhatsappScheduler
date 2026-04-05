// ViewModels/AnalyticsViewModel.swift
// WhatsappScheduler

import Foundation

struct DailyCount: Identifiable {
    var id: Date { date }
    let date: Date
    let count: Int
}

@MainActor
final class AnalyticsViewModel: ObservableObject {

    @Published var dailyCounts: [DailyCount] = []
    @Published var topContacts: [(name: String, phone: String, count: Int)] = []
    @Published var topTemplates: [(title: String, count: Int)] = []
    @Published var peakHour: Int? = nil
    @Published var totalScheduled: Int = 0

    private let localStore = LocalStore.shared

    init() {
        Task { await compute() }
    }

    func compute() async {
        let events   = localStore.loadHistory()
        let schedules = localStore.loadSchedules()
        let templates = localStore.loadTemplates()

        totalScheduled = schedules.count

        // Daily counts (last 30 days)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var dayCounts: [Date: Int] = [:]
        for i in 0..<30 {
            if let day = calendar.date(byAdding: .day, value: -i, to: today) {
                dayCounts[day] = 0
            }
        }
        for event in events where event.type == .scheduleCreated {
            let day = calendar.startOfDay(for: event.occurredAt)
            if dayCounts[day] != nil {
                dayCounts[day]! += 1
            }
        }
        dailyCounts = dayCounts
            .map { DailyCount(date: $0.key, count: $0.value) }
            .sorted { $0.date < $1.date }

        // Top contacts
        var contactCounts: [String: (name: String, count: Int)] = [:]
        for s in schedules {
            let phone = s.phoneNumber
            let name  = s.recipientName ?? phone
            contactCounts[phone, default: (name: name, count: 0)].count += 1
        }
        topContacts = contactCounts
            .map { (name: $0.value.name, phone: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
            .prefix(5)
            .map { $0 }

        // Top templates (by useCount)
        topTemplates = templates
            .sorted { $0.useCount > $1.useCount }
            .prefix(5)
            .map { (title: $0.title, count: $0.useCount) }

        // Peak hour
        var hourCounts = [Int: Int]()
        for s in schedules {
            let hour = Calendar.current.component(.hour, from: s.scheduledAt)
            hourCounts[hour, default: 0] += 1
        }
        peakHour = hourCounts.max(by: { $0.value < $1.value })?.key
    }
}
