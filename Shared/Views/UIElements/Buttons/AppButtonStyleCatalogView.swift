//
//  AppButtonStyleCatalogView.swift
//  debtMe
//
//  Catalog preview for every approved app button style.
//

import SwiftUI

struct AppButtonStyleCatalogView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Forms") {
                    Button {
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                    .buttonStyle(.appAdd)

                    Button {
                    } label: {
                        Label("Save", systemImage: "checkmark")
                    }
                    .buttonStyle(.appContinue)

                    Button(role: .destructive) {
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .buttonStyle(.appDestructive)
                }

                Section("Detail Actions") {
                    Button {
                    } label: {
                        Label("Edit", systemImage: AppIcons.edit)
                    }
                    .buttonStyle(.appEdit)

                    Button {
                    } label: {
                        Label("Mark paid", systemImage: "checkmark")
                    }
                    .buttonStyle(.appPaid)

                    Button {
                    } label: {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                    }
                    .buttonStyle(.appReset)
                }

                Section("Toolbar") {
                    HStack(spacing: 16) {
                        ToolbarAddButton(edition: false) {}

                        Button {
                        } label: {
                            Label("Close", systemImage: "xmark")
                        }
                        .buttonStyle(.appToolbarCancel)

                        Button {
                        } label: {
                            Label("Edit", systemImage: AppIcons.edit)
                        }
                        .buttonStyle(.appToolbarEdit)
                    }
                    .padding(.vertical, 8)
                }

                Section("Navigation Context") {
                    NavigationLink("Open Button Form Preview") {
                        AppButtonStyleFormPreview()
                    }
                }
            }
            .navigationTitle("Button Styles")
        }
    }
}

struct AppButtonStyleFormPreview: View {
    var body: some View {
        Form {
            Section("Inside Form") {
                Button {
                } label: {
                    Label("Add", systemImage: "plus")
                }
                .buttonStyle(.appAdd)

                Button {
                } label: {
                    Label("Edit", systemImage: AppIcons.edit)
                }
                .buttonStyle(.appEdit)
            }

            Section("Inside List") {
                Button(role: .destructive) {
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                .buttonStyle(.appDestructive)
            }
        }
        .navigationTitle("Form Preview")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                } label: {
                    Label("Close", systemImage: "xmark")
                }
                .buttonStyle(.appToolbarCancel)
            }

            ToolbarItem(placement: .confirmationAction) {
                ToolbarAddButton(edition: true) {}
            }
        }
        .appSheetBottomConfirmationAction(edition: true) {}
    }
}

struct AppButtonStylePreviewContainer<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Outside")
                .font(.headline)
            content

            List {
                Section("List") {
                    content
                }
            }
            .frame(height: 160)

            NavigationStack {
                Form {
                    Section("Form") {
                        content
                    }
                }
                .navigationTitle("Preview")
            }
            .frame(height: 220)
        }
        .padding()
    }
}

#Preview("Button Style Catalog") {
    AppButtonStyleCatalogView()
}
