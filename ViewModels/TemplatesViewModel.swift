// ViewModels/TemplatesViewModel.swift
// WhatsappScheduler

import Foundation

@MainActor
final class TemplatesViewModel: ObservableObject {

    @Published var templates: [MessageTemplate] = []
    @Published var searchText: String = ""

    private let cloudKit = CloudKitService.shared
    private let localStore = LocalStore.shared
    private var useCloud: Bool = false

    init() {
        Task { await load() }
    }

    var filtered: [MessageTemplate] {
        guard !searchText.trimmed.isEmpty else { return templates }
        let q = searchText.lowercased()
        return templates.filter {
            $0.title.lowercased().contains(q) || $0.body.lowercased().contains(q)
        }
    }

    var categories: [String] {
        Array(Set(templates.map { $0.category })).sorted()
    }

    func load() async {
        useCloud = await cloudKit.checkAvailability()
        if useCloud {
            if let remote = try? await cloudKit.fetchAllTemplates(), !remote.isEmpty {
                templates = remote
            } else {
                templates = localStore.loadTemplates()
            }
        } else {
            templates = localStore.loadTemplates()
        }
    }

    func save(_ template: MessageTemplate) async {
        var t = template
        t.updatedAt = Date()
        if let idx = templates.firstIndex(where: { $0.id == t.id }) {
            templates[idx] = t
        } else {
            templates.insert(t, at: 0)
        }
        persist()
        if useCloud { try? await cloudKit.save(template: t) }
    }

    func delete(_ template: MessageTemplate) async {
        templates.removeAll { $0.id == template.id }
        persist()
        if useCloud, let recordName = template.ckRecordName {
            try? await cloudKit.delete(recordName: recordName, recordType: MessageTemplate.recordType)
        }
    }

    func incrementUseCount(for template: MessageTemplate) async {
        guard let idx = templates.firstIndex(where: { $0.id == template.id }) else { return }
        templates[idx].useCount += 1
        templates[idx].updatedAt = Date()
        persist()
        if useCloud { try? await cloudKit.save(template: templates[idx]) }
    }

    private func persist() {
        localStore.saveTemplates(templates)
    }
}
