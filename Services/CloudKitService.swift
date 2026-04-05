// Services/CloudKitService.swift
// WhatsappScheduler
//
// Handles iCloud/CloudKit sync for schedules, templates, contacts, and history.
// Falls back to local UserDefaults/JSON storage if iCloud is unavailable.

import Foundation
import CloudKit

enum CloudKitError: LocalizedError {
    case iCloudUnavailable
    case recordNotFound
    case saveFailed(Error)
    case fetchFailed(Error)
    case deleteFailed(Error)

    var errorDescription: String? {
        switch self {
        case .iCloudUnavailable: return NSLocalizedString("icloud_unavailable", comment: "")
        case .recordNotFound:    return NSLocalizedString("record_not_found", comment: "")
        case .saveFailed(let e):  return e.localizedDescription
        case .fetchFailed(let e): return e.localizedDescription
        case .deleteFailed(let e):return e.localizedDescription
        }
    }
}

final class CloudKitService {

    static let shared = CloudKitService()

    private let container: CKContainer
    private let privateDB: CKDatabase
    private var isAvailable: Bool = false

    private init() {
        container = CKContainer.default()
        privateDB = container.privateCloudDatabase
    }

    // MARK: - Availability Check

    func checkAvailability() async -> Bool {
        do {
            let status = try await container.accountStatus()
            isAvailable = (status == .available)
            return isAvailable
        } catch {
            isAvailable = false
            return false
        }
    }

    // MARK: - Save

    func save(record: CKRecord) async throws {
        guard isAvailable else { throw CloudKitError.iCloudUnavailable }
        do {
            _ = try await privateDB.save(record)
        } catch {
            throw CloudKitError.saveFailed(error)
        }
    }

    func save(scheduledMessage: ScheduledMessage) async throws {
        try await save(record: scheduledMessage.toCKRecord())
    }

    func save(template: MessageTemplate) async throws {
        try await save(record: template.toCKRecord())
    }

    func save(contact: QuickContact) async throws {
        try await save(record: contact.toCKRecord())
    }

    func save(event: HistoryEvent) async throws {
        try await save(record: event.toCKRecord())
    }

    // MARK: - Fetch All

    func fetchAllScheduledMessages() async throws -> [ScheduledMessage] {
        let records = try await fetchAll(recordType: ScheduledMessage.recordType)
        return records.compactMap { ScheduledMessage(record: $0) }
    }

    func fetchAllTemplates() async throws -> [MessageTemplate] {
        let records = try await fetchAll(recordType: MessageTemplate.recordType)
        return records.compactMap { MessageTemplate(record: $0) }
    }

    func fetchAllContacts() async throws -> [QuickContact] {
        let records = try await fetchAll(recordType: QuickContact.recordType)
        return records.compactMap { QuickContact(record: $0) }
    }

    func fetchAllHistory() async throws -> [HistoryEvent] {
        let records = try await fetchAll(recordType: HistoryEvent.recordType)
        return records.compactMap { HistoryEvent(record: $0) }
    }

    // MARK: - Delete

    func delete(recordName: String, recordType: String) async throws {
        guard isAvailable else { throw CloudKitError.iCloudUnavailable }
        let recordID = CKRecord.ID(recordName: recordName)
        do {
            try await privateDB.deleteRecord(withID: recordID)
        } catch {
            throw CloudKitError.deleteFailed(error)
        }
    }

    // MARK: - Private Helpers

    private func fetchAll(recordType: String) async throws -> [CKRecord] {
        guard isAvailable else { throw CloudKitError.iCloudUnavailable }
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        do {
            let (results, _) = try await privateDB.records(matching: query)
            return results.compactMap { try? $0.1.get() }
        } catch {
            throw CloudKitError.fetchFailed(error)
        }
    }
}

// MARK: - Local Fallback Storage (JSON + UserDefaults)

/// Lightweight JSON-backed local store used when iCloud is unavailable.
final class LocalStore {

    static let shared = LocalStore()
    private init() {}

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let defaults = UserDefaults.standard

    private enum Keys {
        static let schedules  = "local_schedules"
        static let templates  = "local_templates"
        static let contacts   = "local_contacts"
        static let history    = "local_history"
    }

    // MARK: - Schedules

    func loadSchedules() -> [ScheduledMessage] {
        load(key: Keys.schedules)
    }

    func saveSchedules(_ items: [ScheduledMessage]) {
        save(items, key: Keys.schedules)
    }

    // MARK: - Templates

    func loadTemplates() -> [MessageTemplate] {
        let stored: [MessageTemplate] = load(key: Keys.templates)
        return stored.isEmpty ? MessageTemplate.defaults : stored
    }

    func saveTemplates(_ items: [MessageTemplate]) {
        save(items, key: Keys.templates)
    }

    // MARK: - Contacts

    func loadContacts() -> [QuickContact] {
        load(key: Keys.contacts)
    }

    func saveContacts(_ items: [QuickContact]) {
        save(items, key: Keys.contacts)
    }

    // MARK: - History

    func loadHistory() -> [HistoryEvent] {
        load(key: Keys.history)
    }

    func saveHistory(_ items: [HistoryEvent]) {
        save(items, key: Keys.history)
    }

    // MARK: - Generics

    private func load<T: Codable>(key: String) -> [T] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return (try? decoder.decode([T].self, from: data)) ?? []
    }

    private func save<T: Codable>(_ items: [T], key: String) {
        guard let data = try? encoder.encode(items) else { return }
        defaults.set(data, forKey: key)
    }
}
