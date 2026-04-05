// Features/Schedule/ScheduleCreateView.swift
// WhatsappScheduler
//
// Screen for creating or editing a scheduled WhatsApp message.

import SwiftUI

struct ScheduleCreateView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var scheduleVM: ScheduleViewModel
    @EnvironmentObject var templateVM: TemplatesViewModel
    @EnvironmentObject var historyVM: HistoryViewModel

    // Editing an existing schedule?
    var editingMessage: ScheduledMessage?

    // Form state
    @State private var recipientName: String = ""
    @State private var phoneNumber: String = ""
    @State private var messageBody: String = ""
    @State private var scheduledAt: Date = Date().addingTimeInterval(3600)
    @State private var recurrenceRule: RecurrenceRule = .none
    @State private var recurrenceDays: Set<Int> = []
    @State private var showTemplatePicker = false
    @State private var showValidationError = false
    @State private var validationMessage = ""
    @State private var isSaving = false

    private var isEditing: Bool { editingMessage != nil }
    private let weekdaySymbols = Calendar.current.shortWeekdaySymbols

    var body: some View {
        NavigationStack {
            Form {
                // MARK: Recipient
                Section(NSLocalizedString("schedule_section_recipient", comment: "")) {
                    TextField(NSLocalizedString("schedule_field_name", comment: ""), text: $recipientName)
                        .textContentType(.name)

                    HStack {
                        TextField(NSLocalizedString("schedule_field_phone", comment: ""), text: $phoneNumber)
                            .textContentType(.telephoneNumber)
                            .keyboardType(.phonePad)
                        if !phoneNumber.isEmpty {
                            Image(systemName: WhatsAppService.shared.isValidPhoneNumber(phoneNumber)
                                  ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                .foregroundStyle(WhatsAppService.shared.isValidPhoneNumber(phoneNumber)
                                                 ? .green : .orange)
                        }
                    }
                }

                // MARK: Message
                Section(NSLocalizedString("schedule_section_message", comment: "")) {
                    ZStack(alignment: .topLeading) {
                        if messageBody.isEmpty {
                            Text(NSLocalizedString("schedule_field_message_placeholder", comment: ""))
                                .foregroundStyle(.secondary)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        TextEditor(text: $messageBody)
                            .frame(minHeight: 100)
                    }

                    Button {
                        showTemplatePicker = true
                    } label: {
                        Label(NSLocalizedString("schedule_use_template", comment: ""),
                              systemImage: "rectangle.stack.fill")
                            .foregroundStyle(DS.Color.whatsAppGreen)
                    }
                }

                // MARK: Date & Time
                Section(NSLocalizedString("schedule_section_datetime", comment: "")) {
                    DatePicker(
                        NSLocalizedString("schedule_field_datetime", comment: ""),
                        selection: $scheduledAt,
                        in: Date()...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }

                // MARK: Recurrence
                Section(NSLocalizedString("schedule_section_recurrence", comment: "")) {
                    Picker(NSLocalizedString("schedule_field_recurrence", comment: ""), selection: $recurrenceRule) {
                        ForEach(RecurrenceRule.allCases, id: \.self) { rule in
                            Text(rule.displayName).tag(rule)
                        }
                    }

                    if recurrenceRule == .weekly {
                        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                            Text(NSLocalizedString("schedule_field_days", comment: ""))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            HStack {
                                ForEach(1...7, id: \.self) { day in
                                    let symbol = weekdaySymbols[day - 1]
                                    Button {
                                        if recurrenceDays.contains(day) {
                                            recurrenceDays.remove(day)
                                        } else {
                                            recurrenceDays.insert(day)
                                        }
                                    } label: {
                                        Text(symbol)
                                            .font(.caption2.bold())
                                            .frame(width: 34, height: 34)
                                            .background(recurrenceDays.contains(day)
                                                        ? DS.Color.whatsAppGreen
                                                        : DS.Color.secondaryBG)
                                            .foregroundStyle(recurrenceDays.contains(day) ? .white : .primary)
                                            .clipShape(Circle())
                                    }
                                }
                            }
                        }
                    }
                }

                // MARK: Preview Deep Link
                if !phoneNumber.isEmpty {
                    Section(NSLocalizedString("schedule_section_preview", comment: "")) {
                        let url = WhatsAppService.shared.deepLinkURL(
                            phoneNumber: phoneNumber,
                            message: messageBody
                        )
                        Text(url?.absoluteString ?? NSLocalizedString("schedule_preview_invalid", comment: ""))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(3)
                    }
                }
            }
            .navigationTitle(isEditing
                             ? NSLocalizedString("schedule_edit_title", comment: "")
                             : NSLocalizedString("schedule_create_title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("cancel", comment: "")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("save", comment: "")) {
                        Task { await saveSchedule() }
                    }
                    .disabled(isSaving)
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showTemplatePicker) {
                TemplatePickerView { @MainActor template in
                    messageBody = template.body
                    await templateVM.incrementUseCount(for: template)
                    await historyVM.logTemplateUsed(template: template)
                }
                .environmentObject(templateVM)
            }
            .alert(NSLocalizedString("validation_error_title", comment: ""),
                   isPresented: $showValidationError) {
                Button(NSLocalizedString("ok", comment: ""), role: .cancel) {}
            } message: {
                Text(validationMessage)
            }
        }
        .onAppear { populateForEditing() }
    }

    // MARK: - Populate for editing

    private func populateForEditing() {
        guard let msg = editingMessage else { return }
        recipientName  = msg.recipientName ?? ""
        phoneNumber    = msg.phoneNumber
        messageBody    = msg.messageBody
        scheduledAt    = msg.scheduledAt
        recurrenceRule = msg.recurrenceRule
        recurrenceDays = Set(msg.recurrenceDays)
    }

    // MARK: - Save

    private func saveSchedule() async {
        // Validate
        guard !phoneNumber.trimmed.isEmpty else {
            validationMessage = NSLocalizedString("validation_phone_required", comment: "")
            showValidationError = true
            return
        }
        guard WhatsAppService.shared.isValidPhoneNumber(phoneNumber) else {
            validationMessage = NSLocalizedString("validation_phone_invalid", comment: "")
            showValidationError = true
            return
        }
        guard !messageBody.trimmed.isEmpty else {
            validationMessage = NSLocalizedString("validation_message_required", comment: "")
            showValidationError = true
            return
        }
        guard scheduledAt > Date() else {
            validationMessage = NSLocalizedString("validation_date_future", comment: "")
            showValidationError = true
            return
        }

        isSaving = true
        defer { isSaving = false }

        let message = ScheduledMessage(
            id: editingMessage?.id ?? UUID(),
            recipientName: recipientName.trimmed.isEmpty ? nil : recipientName.trimmed,
            phoneNumber: WhatsAppService.shared.sanitize(phoneNumber: phoneNumber),
            messageBody: messageBody.trimmed,
            scheduledAt: scheduledAt,
            recurrenceRule: recurrenceRule,
            recurrenceDays: Array(recurrenceDays),
            status: .pending,
            ckRecordName: editingMessage?.ckRecordName
        )

        await scheduleVM.save(message)
        await historyVM.logScheduleCreated(message: message)
        dismiss()
    }
}

// MARK: - Template Picker Sheet

struct TemplatePickerView: View {
    @EnvironmentObject var templateVM: TemplatesViewModel
    @Environment(\.dismiss) private var dismiss
    var onSelect: (MessageTemplate) async -> Void

    var body: some View {
        NavigationStack {
            Group {
                if templateVM.templates.isEmpty {
                    EmptyStateView(
                        systemImage: "rectangle.stack",
                        title: NSLocalizedString("templates_empty_title", comment: ""),
                        subtitle: NSLocalizedString("templates_empty_subtitle", comment: "")
                    )
                } else {
                    List(templateVM.templates) { template in
                        Button {
                            Task {
                                await onSelect(template)
                                dismiss()
                            }
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(template.title).font(.headline)
                                Text(template.body.snippet()).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
            .navigationTitle(NSLocalizedString("templates_pick_title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("cancel", comment: "")) { dismiss() }
                }
            }
        }
    }
}

// MARK: - RecurrenceRule Display

extension RecurrenceRule {
    var displayName: String {
        switch self {
        case .none:    return NSLocalizedString("recurrence_none",    comment: "")
        case .daily:   return NSLocalizedString("recurrence_daily",   comment: "")
        case .weekly:  return NSLocalizedString("recurrence_weekly",  comment: "")
        case .monthly: return NSLocalizedString("recurrence_monthly", comment: "")
        }
    }
}

#Preview {
    ScheduleCreateView()
        .environmentObject(ScheduleViewModel())
        .environmentObject(TemplatesViewModel())
        .environmentObject(HistoryViewModel())
}
