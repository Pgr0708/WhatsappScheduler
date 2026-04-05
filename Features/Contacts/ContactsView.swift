// Features/Contacts/ContactsView.swift
// WhatsappScheduler

import SwiftUI

struct ContactsView: View {

    @EnvironmentObject var contactsVM: ContactsViewModel
    @State private var showCreate = false
    @State private var editingContact: QuickContact?
    @State private var contactToDelete: QuickContact?
    @State private var showDeleteConfirm = false

    var body: some View {
        NavigationStack {
            Group {
                if contactsVM.filtered.isEmpty {
                    EmptyStateView(
                        systemImage: "person.2",
                        title: NSLocalizedString("contacts_empty_title", comment: ""),
                        subtitle: NSLocalizedString("contacts_empty_subtitle", comment: ""),
                        action: { showCreate = true },
                        actionTitle: NSLocalizedString("contacts_add_first", comment: "")
                    )
                } else {
                    List {
                        ForEach(contactsVM.groups, id: \.self) { group in
                            Section(group) {
                                ForEach(contactsVM.filtered.filter { $0.group == group }) { contact in
                                    ContactRow(contact: contact)
                                        .onTapGesture { editingContact = contact }
                                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            Button(role: .destructive) {
                                                contactToDelete = contact
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
            .searchable(text: $contactsVM.searchText,
                        prompt: NSLocalizedString("contacts_search_prompt", comment: ""))
            .navigationTitle(NSLocalizedString("contacts_title", comment: ""))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showCreate = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(DS.Color.whatsAppGreen)
                    }
                }
            }
            .sheet(isPresented: $showCreate) {
                ContactEditView()
                    .environmentObject(contactsVM)
            }
            .sheet(item: $editingContact) { contact in
                ContactEditView(editing: contact)
                    .environmentObject(contactsVM)
            }
            .confirmationDialog(
                NSLocalizedString("contacts_delete_confirm", comment: ""),
                isPresented: $showDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button(NSLocalizedString("delete", comment: ""), role: .destructive) {
                    if let c = contactToDelete { Task { await contactsVM.delete(c) } }
                }
                Button(NSLocalizedString("cancel", comment: ""), role: .cancel) {}
            }
        }
    }
}

// MARK: - Contact Row

struct ContactRow: View {
    let contact: QuickContact

    var body: some View {
        HStack(spacing: DS.Spacing.sm) {
            Circle()
                .fill(DS.Color.whatsAppGreen.opacity(0.2))
                .frame(width: 44, height: 44)
                .overlay(
                    Text(contact.avatarInitials)
                        .font(.subheadline.bold())
                        .foregroundStyle(DS.Color.whatsAppGreen)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(contact.name).font(.headline)
                Text(contact.phoneNumber).font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Contact Edit View

struct ContactEditView: View {

    @EnvironmentObject var contactsVM: ContactsViewModel
    @Environment(\.dismiss) private var dismiss

    var editing: QuickContact?

    @State private var name: String = ""
    @State private var phoneNumber: String = ""
    @State private var group: String = "All"

    private var isEditing: Bool { editing != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(NSLocalizedString("contact_field_name", comment: ""), text: $name)
                        .textContentType(.name)

                    HStack {
                        TextField(NSLocalizedString("contact_field_phone", comment: ""), text: $phoneNumber)
                            .textContentType(.telephoneNumber)
                            .keyboardType(.phonePad)

                        if !phoneNumber.isEmpty {
                            Image(systemName: WhatsAppService.shared.isValidPhoneNumber(phoneNumber)
                                  ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                .foregroundStyle(WhatsAppService.shared.isValidPhoneNumber(phoneNumber)
                                                 ? .green : .orange)
                        }
                    }
                }

                Section(NSLocalizedString("contact_field_group_section", comment: "")) {
                    TextField(NSLocalizedString("contact_field_group", comment: ""), text: $group)
                }
            }
            .navigationTitle(isEditing
                             ? NSLocalizedString("contact_edit_title", comment: "")
                             : NSLocalizedString("contact_create_title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("cancel", comment: "")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("save", comment: "")) {
                        Task { await save() }
                    }
                    .disabled(name.trimmed.isEmpty || !WhatsAppService.shared.isValidPhoneNumber(phoneNumber))
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            if let c = editing {
                name        = c.name
                phoneNumber = c.phoneNumber
                group       = c.group
            }
        }
    }

    private func save() async {
        let contact = QuickContact(
            id: editing?.id ?? UUID(),
            name: name.trimmed,
            phoneNumber: WhatsAppService.shared.sanitize(phoneNumber: phoneNumber),
            group: group.trimmed.isEmpty ? "All" : group.trimmed,
            ckRecordName: editing?.ckRecordName
        )
        await contactsVM.save(contact)
        dismiss()
    }
}

#Preview {
    ContactsView()
        .environmentObject(ContactsViewModel())
}
