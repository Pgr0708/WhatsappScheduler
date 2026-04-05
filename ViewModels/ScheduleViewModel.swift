// ViewModels/ScheduleViewModel.swift
// WhatsappScheduler

import Foundation
import Combine

@MainActor
final class ScheduleViewModel: ObservableObject {

    @Published var schedules: [ScheduledMessage] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let notificationService = NotificationService.shared
    private let cloudKit = CloudKitService.shared
    private let localStore = LocalStore.shared
    private var useCloud: Bool = false

    init() {
        Task { await load() }
    }

    // MARK: - Load

    func load() async {
        isLoading = true
        defer { isLoading = false }
        useCloud = await cloudKit.checkAvailability()
        if useCloud {
            do {
                schedules = try await cloudKit.fetchAllScheduledMessages()
            } catch {
                schedules = localStore.loadSchedules()
                errorMessage = error.localizedDescription
            }
        } else {
            schedules = localStore.loadSchedules()
        }
        // Remove expired one-time schedules from view (keep for history)
        pruneExpired()
    }

    // MARK: - Create / Update

    func save(_ message: ScheduledMessage) async {
        var msg = message
        msg.updatedAt = Date()

        // Set nextTriggerAt for recurring
        if msg.recurrenceRule != .none, msg.nextTriggerAt == nil {
            msg.nextTriggerAt = RecurrenceEngine.nextDate(
                rule: msg.recurrenceRule,
                days: msg.recurrenceDays,
                baseTime: msg.scheduledAt
            ) ?? msg.scheduledAt
        }

        // Upsert in local list
        if let idx = schedules.firstIndex(where: { $0.id == msg.id }) {
            schedules[idx] = msg
        } else {
            schedules.insert(msg, at: 0)
        }

        // Schedule notification
        do {
            try await notificationService.schedule(msg)
        } catch {
            errorMessage = error.localizedDescription
        }

        // Persist
        persist()
        if useCloud {
            try? await cloudKit.save(scheduledMessage: msg)
        }
        await updateBadge()
        NotificationCenter.default.post(name: .schedulesDidChange, object: nil)
    }

    // MARK: - Cancel

    func cancel(_ message: ScheduledMessage) async {
        var msg = message
        msg.status = .cancelled
        msg.updatedAt = Date()
        notificationService.cancel(scheduleId: msg.id)
        if let idx = schedules.firstIndex(where: { $0.id == msg.id }) {
            schedules[idx] = msg
        }
        persist()
        if useCloud {
            try? await cloudKit.save(scheduledMessage: msg)
        }
        await updateBadge()
    }

    // MARK: - Delete

    func delete(_ message: ScheduledMessage) async {
        notificationService.cancel(scheduleId: message.id)
        schedules.removeAll { $0.id == message.id }
        persist()
        if useCloud, let recordName = message.ckRecordName {
            try? await cloudKit.delete(recordName: recordName, recordType: ScheduledMessage.recordType)
        }
        await updateBadge()
    }

    // MARK: - Mark Sent (after WhatsApp opened)

    func markSent(scheduleId: UUID) async {
        guard let idx = schedules.firstIndex(where: { $0.id == scheduleId }) else { return }
        var msg = schedules[idx]

        if msg.recurrenceRule != .none {
            // Advance to next occurrence
            RecurrenceEngine.advance(schedule: &msg)
            if let next = msg.nextTriggerAt {
                // Re-schedule notification
                var nextMsg = msg
                nextMsg.scheduledAt = next
                try? await notificationService.schedule(nextMsg)
            }
        } else {
            msg.status = .sent
        }
        msg.updatedAt = Date()
        schedules[idx] = msg
        persist()
        if useCloud { try? await cloudKit.save(scheduledMessage: msg) }
    }

    // MARK: - Helpers

    var pending: [ScheduledMessage] {
        schedules.filter { $0.status == .pending && !$0.isPaused }
            .sorted { ($0.nextTriggerAt ?? $0.scheduledAt) < ($1.nextTriggerAt ?? $1.scheduledAt) }
    }

    var all: [ScheduledMessage] {
        schedules.sorted { $0.scheduledAt > $1.scheduledAt }
    }

    // Keep recently-expired one-time schedules for one hour so history can reference them
    private static let scheduleRetentionWindow: TimeInterval = 3600

    private func pruneExpired() {
        schedules = schedules.filter { msg in
            msg.status == .pending || msg.recurrenceRule != .none
                ? true
                : msg.scheduledAt > Date().addingTimeInterval(-Self.scheduleRetentionWindow)
        }
    }

    private func persist() {
        localStore.saveSchedules(schedules)
    }

    private func updateBadge() async {
        let count = schedules.filter { $0.status == .pending && !$0.isPaused }.count
        notificationService.updateBadge(pendingCount: count)
    }
}
