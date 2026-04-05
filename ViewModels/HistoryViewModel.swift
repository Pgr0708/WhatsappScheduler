// ViewModels/HistoryViewModel.swift
// WhatsappScheduler

import Foundation
import Combine

@MainActor
final class HistoryViewModel: ObservableObject {

    @Published var events: [HistoryEvent] = []
    @Published var searchText: String = ""
    @Published var filterType: HistoryEventType? = nil

    private let cloudKit = CloudKitService.shared
    private let localStore = LocalStore.shared
    private var useCloud: Bool = false
    private var cancellables = Set<AnyCancellable>()

    init() {
        Task { await load() }
        observeWhatsAppOpened()
    }

    // MARK: - Filtered View

    var filtered: [HistoryEvent] {
        var result = events
        if let type = filterType {
            result = result.filter { $0.type == type }
        }
        if !searchText.trimmed.isEmpty {
            let q = searchText.lowercased()
            result = result.filter {
                ($0.recipientName?.lowercased().contains(q) ?? false) ||
                ($0.phoneNumber?.contains(q) ?? false) ||
                ($0.messageSnippet?.lowercased().contains(q) ?? false)
            }
        }
        return result.sorted { $0.occurredAt > $1.occurredAt }
    }

    // MARK: - Load

    func load() async {
        useCloud = await cloudKit.checkAvailability()
        if useCloud {
            if let remote = try? await cloudKit.fetchAllHistory(), !remote.isEmpty {
                events = remote
            } else {
                events = localStore.loadHistory()
            }
        } else {
            events = localStore.loadHistory()
        }
    }

    // MARK: - Log Events

    func log(_ event: HistoryEvent) async {
        events.insert(event, at: 0)
        persist()
        if useCloud { try? await cloudKit.save(event: event) }
    }

    func logScheduleCreated(message: ScheduledMessage) async {
        let event = HistoryEvent(
            type: .scheduleCreated,
            scheduleId: message.id,
            recipientName: message.recipientName,
            phoneNumber: message.phoneNumber,
            messageSnippet: message.messageBody.snippet()
        )
        await log(event)
    }

    func logWhatsAppOpened(scheduleId: UUID, phone: String) async {
        let event = HistoryEvent(
            type: .whatsAppOpened,
            scheduleId: scheduleId,
            phoneNumber: phone
        )
        await log(event)
    }

    func logTemplateUsed(template: MessageTemplate) async {
        let event = HistoryEvent(
            type: .templateUsed,
            templateId: template.id,
            messageSnippet: template.title
        )
        await log(event)
    }

    // MARK: - Clear

    func clear() {
        events = []
        persist()
    }

    // MARK: - Private

    private func persist() {
        localStore.saveHistory(events)
    }

    private func observeWhatsAppOpened() {
        NotificationCenter.default
            .publisher(for: .didOpenWhatsAppFromSchedule)
            .receive(on: RunLoop.main)
            .sink { [weak self] notification in
                guard let self else { return }
                let userInfo = notification.userInfo
                guard
                    let idStr = userInfo?[kNotificationScheduleIDKey] as? String,
                    let sid   = UUID(uuidString: idStr),
                    let phone = userInfo?[kNotificationPhoneKey] as? String
                else { return }
                Task {
                    await self.logWhatsAppOpened(scheduleId: sid, phone: phone)
                }
            }
            .store(in: &cancellables)
    }
}
