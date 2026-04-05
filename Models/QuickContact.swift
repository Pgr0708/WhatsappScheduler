// Models/QuickContact.swift
// WhatsappScheduler

import Foundation
import CloudKit

struct QuickContact: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var phoneNumber: String
    var group: String
    var avatarInitials: String {
        let words = name.split(separator: " ")
        let initials = words.prefix(2).compactMap { $0.first }.map { String($0) }.joined()
        return initials.isEmpty ? "?" : initials.uppercased()
    }
    var createdAt: Date
    var updatedAt: Date
    var ckRecordName: String?

    init(
        id: UUID = UUID(),
        name: String,
        phoneNumber: String,
        group: String = "All",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        ckRecordName: String? = nil
    ) {
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.group = group
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.ckRecordName = ckRecordName
    }
}

// MARK: - CloudKit Conversion
extension QuickContact {
    static let recordType = "QuickContact"

    init?(record: CKRecord) {
        guard
            let idString = record["id"] as? String,
            let id = UUID(uuidString: idString),
            let name = record["name"] as? String,
            let phoneNumber = record["phoneNumber"] as? String,
            let createdAt = record["createdAt"] as? Date,
            let updatedAt = record["updatedAt"] as? Date
        else { return nil }

        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.group = (record["group"] as? String) ?? "All"
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.ckRecordName = record.recordID.recordName
    }

    func toCKRecord() -> CKRecord {
        let recordName = ckRecordName ?? id.uuidString
        let record = CKRecord(recordType: QuickContact.recordType,
                              recordID: CKRecord.ID(recordName: recordName))
        record["id"] = id.uuidString
        record["name"] = name
        record["phoneNumber"] = phoneNumber
        record["group"] = group
        record["createdAt"] = createdAt
        record["updatedAt"] = updatedAt
        return record
    }
}
