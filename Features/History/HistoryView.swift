// Features/History/HistoryView.swift
// WhatsappScheduler

import SwiftUI

struct HistoryView: View {

    @EnvironmentObject var historyVM: HistoryViewModel
    @State private var showClearConfirm = false

    var body: some View {
        NavigationStack {
            Group {
                if historyVM.filtered.isEmpty {
                    EmptyStateView(
                        systemImage: "clock.arrow.circlepath",
                        title: NSLocalizedString("history_empty_title", comment: ""),
                        subtitle: NSLocalizedString("history_empty_subtitle", comment: "")
                    )
                } else {
                    List(historyVM.filtered) { event in
                        HistoryEventRow(event: event)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .searchable(text: $historyVM.searchText,
                        prompt: NSLocalizedString("history_search_prompt", comment: ""))
            .navigationTitle(NSLocalizedString("history_title", comment: ""))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Section(NSLocalizedString("history_filter_type", comment: "")) {
                            Button(NSLocalizedString("history_filter_all", comment: "")) {
                                historyVM.filterType = nil
                            }
                            ForEach(HistoryEventType.allCases, id: \.self) { type in
                                Button(type.displayName) {
                                    historyVM.filterType = type
                                }
                            }
                        }
                        Divider()
                        Button(role: .destructive) {
                            showClearConfirm = true
                        } label: {
                            Label(NSLocalizedString("history_clear", comment: ""), systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .confirmationDialog(
                NSLocalizedString("history_clear_confirm", comment: ""),
                isPresented: $showClearConfirm,
                titleVisibility: .visible
            ) {
                Button(NSLocalizedString("history_clear", comment: ""), role: .destructive) {
                    historyVM.clear()
                }
                Button(NSLocalizedString("cancel", comment: ""), role: .cancel) {}
            }
        }
    }
}

// MARK: - History Event Row

struct HistoryEventRow: View {
    let event: HistoryEvent

    var body: some View {
        HStack(spacing: DS.Spacing.sm) {
            Image(systemName: event.type.systemImage)
                .font(.title3)
                .foregroundStyle(event.type.color)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(event.type.displayName)
                    .font(.headline)
                if let name = event.recipientName {
                    Text(name).font(.subheadline).foregroundStyle(.secondary)
                } else if let phone = event.phoneNumber {
                    Text(phone).font(.subheadline).foregroundStyle(.secondary)
                } else if let snippet = event.messageSnippet {
                    Text(snippet).font(.subheadline).foregroundStyle(.secondary)
                }
                Text(event.occurredAt.relativeString)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, DS.Spacing.xs)
    }
}

// MARK: - HistoryEventType Display

extension HistoryEventType {
    var displayName: String {
        switch self {
        case .scheduleCreated:   return NSLocalizedString("history_type_schedule_created",   comment: "")
        case .scheduleEdited:    return NSLocalizedString("history_type_schedule_edited",    comment: "")
        case .scheduleCancelled: return NSLocalizedString("history_type_schedule_cancelled", comment: "")
        case .whatsAppOpened:    return NSLocalizedString("history_type_whatsapp_opened",    comment: "")
        case .templateUsed:      return NSLocalizedString("history_type_template_used",      comment: "")
        case .contactUsed:       return NSLocalizedString("history_type_contact_used",       comment: "")
        }
    }

    var systemImage: String {
        switch self {
        case .scheduleCreated:   return "calendar.badge.plus"
        case .scheduleEdited:    return "calendar.badge.clock"
        case .scheduleCancelled: return "calendar.badge.minus"
        case .whatsAppOpened:    return "arrow.up.right.square.fill"
        case .templateUsed:      return "rectangle.stack.fill"
        case .contactUsed:       return "person.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .scheduleCreated:   return .green
        case .scheduleEdited:    return .blue
        case .scheduleCancelled: return .gray
        case .whatsAppOpened:    return .whatsAppGreen
        case .templateUsed:      return .purple
        case .contactUsed:       return .orange
        }
    }
}

#Preview {
    HistoryView()
        .environmentObject(HistoryViewModel())
}
