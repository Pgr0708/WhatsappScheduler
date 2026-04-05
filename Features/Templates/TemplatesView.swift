// Features/Templates/TemplatesView.swift
// WhatsappScheduler

import SwiftUI

struct TemplatesView: View {

    @EnvironmentObject var templateVM: TemplatesViewModel
    @State private var showCreate = false
    @State private var editingTemplate: MessageTemplate?
    @State private var showDeleteConfirm = false
    @State private var templateToDelete: MessageTemplate?

    var body: some View {
        NavigationStack {
            Group {
                if templateVM.filtered.isEmpty {
                    EmptyStateView(
                        systemImage: "rectangle.stack",
                        title: NSLocalizedString("templates_empty_title", comment: ""),
                        subtitle: NSLocalizedString("templates_empty_subtitle", comment: ""),
                        action: { showCreate = true },
                        actionTitle: NSLocalizedString("templates_add_first", comment: "")
                    )
                } else {
                    List {
                        ForEach(templateVM.categories, id: \.self) { category in
                            Section(category) {
                                ForEach(templateVM.filtered.filter { $0.category == category }) { template in
                                    TemplateRow(template: template)
                                        .onTapGesture { editingTemplate = template }
                                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            Button(role: .destructive) {
                                                templateToDelete = template
                                                showDeleteConfirm = true
                                            } label: {
                                                Label(NSLocalizedString("delete", comment: ""),
                                                      systemImage: "trash")
                                            }
                                        }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .searchable(text: $templateVM.searchText,
                        prompt: NSLocalizedString("templates_search_prompt", comment: ""))
            .navigationTitle(NSLocalizedString("templates_title", comment: ""))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showCreate = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(DS.Color.whatsAppGreen)
                    }
                }
            }
            .sheet(isPresented: $showCreate) {
                TemplateEditView()
                    .environmentObject(templateVM)
            }
            .sheet(item: $editingTemplate) { template in
                TemplateEditView(editing: template)
                    .environmentObject(templateVM)
            }
            .confirmationDialog(
                NSLocalizedString("templates_delete_confirm", comment: ""),
                isPresented: $showDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button(NSLocalizedString("delete", comment: ""), role: .destructive) {
                    if let t = templateToDelete {
                        Task { await templateVM.delete(t) }
                    }
                }
                Button(NSLocalizedString("cancel", comment: ""), role: .cancel) {}
            }
        }
    }
}

// MARK: - Template Row

struct TemplateRow: View {
    let template: MessageTemplate

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(template.title).font(.headline)
                Spacer()
                if template.useCount > 0 {
                    Text("\(template.useCount)×")
                        .font(.caption2.bold())
                        .foregroundStyle(DS.Color.whatsAppGreen)
                }
            }
            Text(template.body.snippet())
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, DS.Spacing.xs)
    }
}

// MARK: - Template Edit View

struct TemplateEditView: View {

    @EnvironmentObject var templateVM: TemplatesViewModel
    @Environment(\.dismiss) private var dismiss

    var editing: MessageTemplate?

    @State private var title: String = ""
    @State private var body_: String = ""
    @State private var category: String = "General"
    @State private var newCategory: String = ""

    private var isEditing: Bool { editing != nil }

    let defaultCategories = ["General", "Business", "Personal", "Celebration"]

    var body: some View {
        NavigationStack {
            Form {
                Section(NSLocalizedString("template_field_title_section", comment: "")) {
                    TextField(NSLocalizedString("template_field_title", comment: ""), text: $title)
                }
                Section(NSLocalizedString("template_field_body_section", comment: "")) {
                    TextEditor(text: $body_)
                        .frame(minHeight: 120)
                }
                Section(NSLocalizedString("template_field_category_section", comment: "")) {
                    Picker(NSLocalizedString("template_field_category", comment: ""), selection: $category) {
                        ForEach(defaultCategories + templateVM.categories.filter { !defaultCategories.contains($0) }, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                }
            }
            .navigationTitle(isEditing
                             ? NSLocalizedString("template_edit_title", comment: "")
                             : NSLocalizedString("template_create_title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("cancel", comment: "")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("save", comment: "")) {
                        Task { await save() }
                    }
                    .disabled(title.trimmed.isEmpty || body_.trimmed.isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            if let t = editing {
                title    = t.title
                body_    = t.body
                category = t.category
            }
        }
    }

    private func save() async {
        let template = MessageTemplate(
            id: editing?.id ?? UUID(),
            title: title.trimmed,
            body: body_.trimmed,
            category: category,
            useCount: editing?.useCount ?? 0,
            ckRecordName: editing?.ckRecordName
        )
        await templateVM.save(template)
        dismiss()
    }
}

#Preview {
    TemplatesView()
        .environmentObject(TemplatesViewModel())
}
