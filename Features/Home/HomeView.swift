// Features/Home/HomeView.swift
// WhatsappScheduler

import SwiftUI

struct HomeView: View {

    private static let maxQuickContactsDisplayed = 5

    @EnvironmentObject var scheduleVM: ScheduleViewModel
    @EnvironmentObject var contactsVM: ContactsViewModel
    @State private var showCreateSchedule = false
    @State private var editingMessage: ScheduledMessage?
    @State private var whatsAppError: String?
    @State private var showWhatsAppError = false

    var body: some View {
        NavigationStack {
            Group {
                if scheduleVM.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if scheduleVM.pending.isEmpty {
                    EmptyStateView(
                        systemImage: "clock.badge.checkmark",
                        title: NSLocalizedString("home_empty_title", comment: ""),
                        subtitle: NSLocalizedString("home_empty_subtitle", comment: ""),
                        action: { showCreateSchedule = true },
                        actionTitle: NSLocalizedString("home_empty_action", comment: "")
                    )
                } else {
                    scheduleList
                }
            }
            .navigationTitle(NSLocalizedString("home_title", comment: ""))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showCreateSchedule = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(DS.Color.whatsAppGreen)
                            .font(.title3)
                    }
                }
            }
            // Quick contacts strip
            .safeAreaInset(edge: .bottom) {
                if !contactsVM.contacts.isEmpty {
                    QuickContactStrip(contacts: contactsVM.contacts.prefix(HomeView.maxQuickContactsDisplayed).map { $0 }) { contact in
                        let prefilledMsg = ScheduledMessage(
                            recipientName: contact.name,
                            phoneNumber: contact.phoneNumber,
                            messageBody: "",
                            scheduledAt: Date().addingTimeInterval(3600)
                        )
                        editingMessage = prefilledMsg
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    .background(.ultraThinMaterial)
                }
            }
        }
        .sheet(isPresented: $showCreateSchedule) {
            ScheduleCreateView()
        }
        .sheet(item: $editingMessage) { msg in
            ScheduleCreateView(editingMessage: msg)
        }
        .alert(NSLocalizedString("whatsapp_error_title", comment: ""), isPresented: $showWhatsAppError) {
            Button(NSLocalizedString("ok", comment: ""), role: .cancel) {}
        } message: {
            Text(whatsAppError ?? "")
        }
    }

    // MARK: - Schedule List

    private var scheduleList: some View {
        List {
            ForEach(scheduleVM.pending) { msg in
                ScheduleRowView(message: msg) {
                    openWhatsApp(for: msg)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        Task { await scheduleVM.cancel(msg) }
                    } label: {
                        Label(NSLocalizedString("cancel", comment: ""), systemImage: "xmark.circle")
                    }

                    Button {
                        editingMessage = msg
                    } label: {
                        Label(NSLocalizedString("edit", comment: ""), systemImage: "pencil")
                    }
                    .tint(.blue)
                }
            }
        }
        .listStyle(.insetGrouped)
        .refreshable { await scheduleVM.load() }
    }

    // MARK: - Open WhatsApp

    private func openWhatsApp(for message: ScheduledMessage) {
        Task {
            await WhatsAppService.shared.openWhatsApp(
                phoneNumber: message.phoneNumber,
                message: message.messageBody
            ) { error in
                if let error {
                    whatsAppError = error.localizedDescription
                    showWhatsAppError = true
                }
            }
            await scheduleVM.markSent(scheduleId: message.id)
        }
    }
}

// MARK: - Schedule Row

struct ScheduleRowView: View {
    let message: ScheduledMessage
    var onOpen: () -> Void

    var body: some View {
        HStack(spacing: DS.Spacing.sm) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(message.recipientName ?? message.phoneNumber)
                        .font(.headline)
                    if message.recurrenceRule != .none {
                        Image(systemName: "repeat")
                            .font(.caption2)
                            .foregroundStyle(DS.Color.whatsAppGreen)
                    }
                }
                Text(message.messageBody.snippet())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text((message.nextTriggerAt ?? message.scheduledAt).shortDateTimeString)
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: onOpen) {
                Image(systemName: "arrow.up.right.circle.fill")
                    .font(.title2)
                    .foregroundStyle(DS.Color.whatsAppGreen)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, DS.Spacing.xs)
    }
}

// MARK: - Quick Contact Strip

struct QuickContactStrip: View {
    let contacts: [QuickContact]
    var onTap: (QuickContact) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DS.Spacing.sm) {
                Text(NSLocalizedString("home_quick_contacts", comment: ""))
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)

                ForEach(contacts) { contact in
                    Button {
                        onTap(contact)
                    } label: {
                        VStack(spacing: 4) {
                            Circle()
                                .fill(DS.Color.whatsAppGreen.opacity(0.2))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Text(contact.avatarInitials)
                                        .font(.subheadline.bold())
                                        .foregroundStyle(DS.Color.whatsAppGreen)
                                )
                            Text(contact.name.split(separator: " ").first.map(String.init) ?? contact.name)
                                .font(.caption2)
                                .lineLimit(1)
                        }
                    }
                    .foregroundStyle(.primary)
                }
            }
            .padding(.vertical, DS.Spacing.xs)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(ScheduleViewModel())
        .environmentObject(ContactsViewModel())
}
