// Models/ScheduledMessage.swift
// WhatsappScheduler

import Foundation
import CloudKit

// MARK: - Recurrence Rule
enum RecurrenceRule: String, Codable, CaseIterable {
    case none     = "none"
    case daily    = "daily"
    case weekly   = "weekly"
    case monthly  = "monthly"
}

// MARK: - Schedule Status
enum ScheduleStatus: String, Codable, CaseIterable {
    case pending   = "pending"
    case sent      = "sent"     // user tapped Send in WhatsApp
    case cancelled = "cancelled"
    case failed    = "failed"
}

// MARK: - ScheduledMessage
struct ScheduledMessage: Identifiable, Codable, Hashable {
    var id: UUID
    var recipientName: String?
    var phoneNumber: String          // E.164 or local, e.g. "+919876543210"
    var messageBody: String
    var scheduledAt: Date
    var recurrenceRule: RecurrenceRule
    var recurrenceDays: [Int]        // 1–7 for weekly (1=Sunday)
    var status: ScheduleStatus
    var nextTriggerAt: Date?
    var isPaused: Bool
    var templateId: UUID?
    var contactId: UUID?
    var createdAt: Date
    var updatedAt: Date

    // CloudKit record name for sync
    var ckRecordName: String?

    init(
        id: UUID = UUID(),
        recipientName: String? = nil,
        phoneNumber: String,
        messageBody: String,
        scheduledAt: Date,
        recurrenceRule: RecurrenceRule = .none,
        recurrenceDays: [Int] = [],
        status: ScheduleStatus = .pending,
        nextTriggerAt: Date? = nil,
        isPaused: Bool = false,
        templateId: UUID? = nil,
        contactId: UUID? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        ckRecordName: String? = nil
    ) {
        self.id = id
        self.recipientName = recipientName
        self.phoneNumber = phoneNumber
        self.messageBody = messageBody
        self.scheduledAt = scheduledAt
        self.recurrenceRule = recurrenceRule
        self.recurrenceDays = recurrenceDays
        self.status = status
        self.nextTriggerAt = nextTriggerAt
        self.isPaused = isPaused
        self.templateId = templateId
        self.contactId = contactId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.ckRecordName = ckRecordName
    }
}

// MARK: - CloudKit Conversion
extension ScheduledMessage {
    static let recordType = "ScheduledMessage"

    init?(record: CKRecord) {
        guard
            let idString = record["id"] as? String,
            let id = UUID(uuidString: idString),
            let phoneNumber = record["phoneNumber"] as? String,
            let messageBody = record["messageBody"] as? String,
            let scheduledAt = record["scheduledAt"] as? Date,
            let recurrenceRawValue = record["recurrenceRule"] as? String,
            let recurrenceRule = RecurrenceRule(rawValue: recurrenceRawValue),
            let statusRawValue = record["status"] as? String,
            let status = ScheduleStatus(rawValue: statusRawValue),
            let createdAt = record["createdAt"] as? Date,
            let updatedAt = record["updatedAt"] as? Date
        else { return nil }

        self.id = id
        self.phoneNumber = phoneNumber
        self.messageBody = messageBody
        self.scheduledAt = scheduledAt
        self.recurrenceRule = recurrenceRule
        self.recurrenceDays = (record["recurrenceDays"] as? [Int]) ?? []
        self.status = status
        self.nextTriggerAt = record["nextTriggerAt"] as? Date
        self.isPaused = (record["isPaused"] as? Int ?? 0) == 1
        self.recipientName = record["recipientName"] as? String
        if let templateIdStr = record["templateId"] as? String {
            self.templateId = UUID(uuidString: templateIdStr)
        }
        if let contactIdStr = record["contactId"] as? String {
            self.contactId = UUID(uuidString: contactIdStr)
        }
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.ckRecordName = record.recordID.recordName
    }

    func toCKRecord() -> CKRecord {
        let recordName = ckRecordName ?? id.uuidString
        let record = CKRecord(recordType: ScheduledMessage.recordType,
                              recordID: CKRecord.ID(recordName: recordName))
        record["id"] = id.uuidString
        record["phoneNumber"] = phoneNumber
        record["messageBody"] = messageBody
        record["scheduledAt"] = scheduledAt
        record["recurrenceRule"] = recurrenceRule.rawValue
        record["recurrenceDays"] = recurrenceDays as CKRecordValue
        record["status"] = status.rawValue
        record["nextTriggerAt"] = nextTriggerAt
        record["isPaused"] = isPaused ? 1 : 0
        record["recipientName"] = recipientName
        record["templateId"] = templateId?.uuidString
        record["contactId"] = contactId?.uuidString
        record["createdAt"] = createdAt
        record["updatedAt"] = updatedAt
        return record
    }
}
