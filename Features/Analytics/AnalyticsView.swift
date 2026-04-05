// Features/Analytics/AnalyticsView.swift
// WhatsappScheduler

import SwiftUI
import Charts

struct AnalyticsView: View {

    @StateObject private var vm = AnalyticsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DS.Spacing.lg) {

                    // Summary Card
                    summaryCard

                    // Daily Schedule Chart
                    if !vm.dailyCounts.isEmpty {
                        dailyChart
                    }

                    // Top Contacts
                    if !vm.topContacts.isEmpty {
                        topContactsCard
                    }

                    // Top Templates
                    if !vm.topTemplates.isEmpty {
                        topTemplatesCard
                    }

                    // Peak Hour
                    if let hour = vm.peakHour {
                        peakHourCard(hour: hour)
                    }
                }
                .padding(DS.Spacing.md)
            }
            .navigationTitle(NSLocalizedString("analytics_title", comment: ""))
            .refreshable { await vm.compute() }
        }
    }

    // MARK: - Summary Card

    private var summaryCard: some View {
        HStack(spacing: DS.Spacing.md) {
            AnalyticsStatCell(
                value: "\(vm.totalScheduled)",
                label: NSLocalizedString("analytics_total_scheduled", comment: ""),
                icon: "calendar.badge.clock",
                color: .whatsAppGreen
            )
            Divider()
            AnalyticsStatCell(
                value: vm.peakHour.map { hourString($0) } ?? "—",
                label: NSLocalizedString("analytics_peak_hour", comment: ""),
                icon: "clock.fill",
                color: .orange
            )
        }
        .padding(DS.Spacing.md)
        .cardStyle()
    }

    // MARK: - Daily Chart

    private var dailyChart: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text(NSLocalizedString("analytics_chart_daily", comment: ""))
                .font(DS.Font.headline)

            Chart(vm.dailyCounts) { item in
                BarMark(
                    x: .value("Date", item.date, unit: .day),
                    y: .value("Count", item.count)
                )
                .foregroundStyle(DS.Color.whatsAppGreen)
                .cornerRadius(4)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 7)) {
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                }
            }
            .frame(height: 180)
        }
        .padding(DS.Spacing.md)
        .cardStyle()
    }

    // MARK: - Top Contacts

    private var topContactsCard: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text(NSLocalizedString("analytics_top_contacts", comment: ""))
                .font(DS.Font.headline)

            ForEach(vm.topContacts.indices, id: \.self) { i in
                let item = vm.topContacts[i]
                HStack {
                    Text("\(i + 1).").foregroundStyle(.secondary).frame(width: 24)
                    Text(item.name).font(.subheadline)
                    Spacer()
                    Text("\(item.count)×").font(.subheadline.bold()).foregroundStyle(DS.Color.whatsAppGreen)
                }
                if i < vm.topContacts.count - 1 { Divider() }
            }
        }
        .padding(DS.Spacing.md)
        .cardStyle()
    }

    // MARK: - Top Templates

    private var topTemplatesCard: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text(NSLocalizedString("analytics_top_templates", comment: ""))
                .font(DS.Font.headline)

            ForEach(vm.topTemplates.indices, id: \.self) { i in
                let item = vm.topTemplates[i]
                HStack {
                    Text("\(i + 1).").foregroundStyle(.secondary).frame(width: 24)
                    Text(item.title).font(.subheadline)
                    Spacer()
                    Text("\(item.count)×").font(.subheadline.bold()).foregroundStyle(.purple)
                }
                if i < vm.topTemplates.count - 1 { Divider() }
            }
        }
        .padding(DS.Spacing.md)
        .cardStyle()
    }

    // MARK: - Peak Hour Card

    private func peakHourCard(hour: Int) -> some View {
        HStack {
            Image(systemName: "clock.fill").foregroundStyle(.orange)
            Text(NSLocalizedString("analytics_peak_hour_desc", comment: ""))
                .font(.subheadline)
            Spacer()
            Text(hourString(hour))
                .font(.headline)
                .foregroundStyle(.orange)
        }
        .padding(DS.Spacing.md)
        .cardStyle()
    }

    private func hourString(_ hour: Int) -> String {
        let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Stat Cell

struct AnalyticsStatCell: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: DS.Spacing.xs) {
            Image(systemName: icon).font(.title2).foregroundStyle(color)
            Text(value).font(.title.bold())
            Text(label).font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    AnalyticsView()
}
