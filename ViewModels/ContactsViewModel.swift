// ViewModels/ContactsViewModel.swift
// WhatsappScheduler

import Foundation

@MainActor
final class ContactsViewModel: ObservableObject {

    @Published var contacts: [QuickContact] = []
    @Published var searchText: String = ""

    private let cloudKit = CloudKitService.shared
    private let localStore = LocalStore.shared
    private var useCloud: Bool = false

    init() {
        Task { await load() }
    }

    var filtered: [QuickContact] {
        guard !searchText.trimmed.isEmpty else { return contacts }
        let q = searchText.lowercased()
        return contacts.filter {
            $0.name.lowercased().contains(q) || $0.phoneNumber.contains(q)
        }
    }

    var groups: [String] {
        Array(Set(contacts.map { $0.group })).sorted()
    }

    func load() async {
        useCloud = await cloudKit.checkAvailability()
        if useCloud {
            if let remote = try? await cloudKit.fetchAllContacts(), !remote.isEmpty {
                contacts = remote
            } else {
                contacts = localStore.loadContacts()
            }
        } else {
            contacts = localStore.loadContacts()
        }
    }

    func save(_ contact: QuickContact) async {
        var c = contact
        c.updatedAt = Date()
        if let idx = contacts.firstIndex(where: { $0.id == c.id }) {
            contacts[idx] = c
        } else {
            contacts.insert(c, at: 0)
        }
        persist()
        if useCloud { try? await cloudKit.save(contact: c) }
    }

    func delete(_ contact: QuickContact) async {
        contacts.removeAll { $0.id == contact.id }
        persist()
        if useCloud, let recordName = contact.ckRecordName {
            try? await cloudKit.delete(recordName: recordName, recordType: QuickContact.recordType)
        }
    }

    private func persist() {
        localStore.saveContacts(contacts)
    }
}
