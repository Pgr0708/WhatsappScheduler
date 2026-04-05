// Models/MessageTemplate.swift
// WhatsappScheduler

import Foundation
import CloudKit

struct MessageTemplate: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var body: String
    var category: String
    var useCount: Int
    var createdAt: Date
    var updatedAt: Date
    var ckRecordName: String?

    init(
        id: UUID = UUID(),
        title: String,
        body: String,
        category: String = "General",
        useCount: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        ckRecordName: String? = nil
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.category = category
        self.useCount = useCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.ckRecordName = ckRecordName
    }
}

// MARK: - CloudKit Conversion
extension MessageTemplate {
    static let recordType = "MessageTemplate"

    init?(record: CKRecord) {
        guard
            let idString = record["id"] as? String,
            let id = UUID(uuidString: idString),
            let title = record["title"] as? String,
            let body = record["body"] as? String,
            let createdAt = record["createdAt"] as? Date,
            let updatedAt = record["updatedAt"] as? Date
        else { return nil }

        self.id = id
        self.title = title
        self.body = body
        self.category = (record["category"] as? String) ?? "General"
        self.useCount = (record["useCount"] as? Int) ?? 0
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.ckRecordName = record.recordID.recordName
    }

    func toCKRecord() -> CKRecord {
        let recordName = ckRecordName ?? id.uuidString
        let record = CKRecord(recordType: MessageTemplate.recordType,
                              recordID: CKRecord.ID(recordName: recordName))
        record["id"] = id.uuidString
        record["title"] = title
        record["body"] = body
        record["category"] = category
        record["useCount"] = useCount
        record["createdAt"] = createdAt
        record["updatedAt"] = updatedAt
        return record
    }
}

// MARK: - Default Templates
extension MessageTemplate {
    static let defaults: [MessageTemplate] = [
        MessageTemplate(
            title: "Birthday Wish",
            body: "🎂 Happy Birthday! Wishing you a wonderful day filled with joy and happiness! 🎉",
            category: "Celebration"
        ),
        MessageTemplate(
            title: "Meeting Reminder",
            body: "Hi! Just a friendly reminder about our meeting scheduled for today. See you soon! 📅",
            category: "Business"
        ),
        MessageTemplate(
            title: "Follow Up",
            body: "Hi, just following up on our last conversation. Let me know if you have any questions! 😊",
            category: "Business"
        ),
        MessageTemplate(
            title: "Running Late",
            body: "Hey, sorry I'm running a bit late. I'll be there in about 10–15 minutes. 🚗",
            category: "Personal"
        ),
        MessageTemplate(
            title: "Thank You",
            body: "Thank you so much! I really appreciate your help and support. 🙏",
            category: "Personal"
        )
    ]
}
