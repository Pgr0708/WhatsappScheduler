// Models/HistoryEvent.swift
// WhatsappScheduler

import Foundation
import CloudKit

enum HistoryEventType: String, Codable, CaseIterable {
    case scheduleCreated   = "schedule_created"
    case scheduleEdited    = "schedule_edited"
    case scheduleCancelled = "schedule_cancelled"
    case whatsAppOpened    = "whatsapp_opened"    // user tapped notification → WhatsApp opened
    case templateUsed      = "template_used"
    case contactUsed       = "contact_used"
}

struct HistoryEvent: Identifiable, Codable, Hashable {
    var id: UUID
    var type: HistoryEventType
    var scheduleId: UUID?
    var recipientName: String?
    var phoneNumber: String?
    var messageSnippet: String?   // first 60 chars of message body
    var templateId: UUID?
    var contactId: UUID?
    var occurredAt: Date
    var ckRecordName: String?

    init(
        id: UUID = UUID(),
        type: HistoryEventType,
        scheduleId: UUID? = nil,
        recipientName: String? = nil,
        phoneNumber: String? = nil,
        messageSnippet: String? = nil,
        templateId: UUID? = nil,
        contactId: UUID? = nil,
        occurredAt: Date = Date(),
        ckRecordName: String? = nil
    ) {
        self.id = id
        self.type = type
        self.scheduleId = scheduleId
        self.recipientName = recipientName
        self.phoneNumber = phoneNumber
        self.messageSnippet = messageSnippet
        self.templateId = templateId
        self.contactId = contactId
        self.occurredAt = occurredAt
        self.ckRecordName = ckRecordName
    }
}

// MARK: - CloudKit Conversion
extension HistoryEvent {
    static let recordType = "HistoryEvent"

    init?(record: CKRecord) {
        guard
            let idString = record["id"] as? String,
            let id = UUID(uuidString: idString),
            let typeRaw = record["type"] as? String,
            let type = HistoryEventType(rawValue: typeRaw),
            let occurredAt = record["occurredAt"] as? Date
        else { return nil }

        self.id = id
        self.type = type
        self.occurredAt = occurredAt
        if let sid = record["scheduleId"] as? String { self.scheduleId = UUID(uuidString: sid) }
        if let tid = record["templateId"] as? String { self.templateId = UUID(uuidString: tid) }
        if let cid = record["contactId"] as? String  { self.contactId  = UUID(uuidString: cid) }
        self.recipientName   = record["recipientName"]   as? String
        self.phoneNumber     = record["phoneNumber"]     as? String
        self.messageSnippet  = record["messageSnippet"]  as? String
        self.ckRecordName    = record.recordID.recordName
    }

    func toCKRecord() -> CKRecord {
        let recordName = ckRecordName ?? id.uuidString
        let record = CKRecord(recordType: HistoryEvent.recordType,
                              recordID: CKRecord.ID(recordName: recordName))
        record["id"]            = id.uuidString
        record["type"]          = type.rawValue
        record["occurredAt"]    = occurredAt
        record["scheduleId"]    = scheduleId?.uuidString
        record["templateId"]    = templateId?.uuidString
        record["contactId"]     = contactId?.uuidString
        record["recipientName"] = recipientName
        record["phoneNumber"]   = phoneNumber
        record["messageSnippet"]= messageSnippet
        return record
    }
}
