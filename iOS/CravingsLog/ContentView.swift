import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showAdd = false
    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var editingEntry: CravingEntry?

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.entries) { entry in
                    Button {
                        editingEntry = entry
                    } label: {
                        row(entry)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("entryRow_\(entry.id)")
                }
                .onDelete { offsets in
                    store.delete(at: offsets)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(AppTheme.backdrop)
            .navigationTitle("Cravings Log")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showAdd = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addEntryButton")
                }
            }
            .sheet(isPresented: $showAdd) {
                EntrySheet(entry: nil)
            }
            .sheet(item: $editingEntry) { entry in
                EntrySheet(entry: entry)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    @ViewBuilder
    private func row(_ entry: CravingEntry) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title)
                    .font(AppTheme.headlineFont)
                    .foregroundStyle(AppTheme.ink)
                Text("\(entry.tag) \u{00B7} \(entry.date.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(AppTheme.inkFaded)
                if !entry.note.isEmpty {
                    Text(entry.note)
                        .font(.footnote)
                        .foregroundStyle(AppTheme.inkFaded)
                        .lineLimit(2)
                }
            }
            Spacer()
            Text("\(entry.metric)")
                .font(AppTheme.headlineFont)
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(AppTheme.accent)
                .clipShape(Capsule())
        }
        .padding(.vertical, 4)
    }
}

struct EntrySheet: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss
    let entry: CravingEntry?

    @State private var title: String = ""
    @State private var metric: Double = 5
    @State private var tag: String = CravingsLogTags.all.first ?? ""
    @State private var note: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Craving") {
                    TextField("Title", text: $title)
                        .accessibilityIdentifier("entryTitleField")
                }
                Section("Intensity: \(Int(metric))") {
                    Slider(value: $metric, in: 0...10, step: 1)
                        .accessibilityIdentifier("entryMetricSlider")
                }
                Section("Outcome") {
                    Picker("Outcome", selection: $tag) {
                        ForEach(CravingsLogTags.all, id: \.self) { t in
                            Text(t).tag(t)
                        }
                    }
                    .pickerStyle(.menu)
                    .accessibilityIdentifier("entryTagPicker")
                }
                Section("Note") {
                    TextField("Optional note", text: $note, axis: .vertical)
                        .accessibilityIdentifier("entryNoteField")
                }
                if entry != nil {
                    Section {
                        Button("Delete", role: .destructive) {
                            if let entry { store.delete(entry) }
                            dismiss()
                        }
                        .accessibilityIdentifier("entryDeleteButton")
                    }
                }
            }
            .dismissKeyboardOnTap()
            .navigationTitle(entry == nil ? "New Craving" : "Edit Craving")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("entryCancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let t = title.isEmpty ? "Craving" : title
                        if var existing = entry {
                            existing.title = t
                            existing.metric = Int(metric)
                            existing.tag = tag
                            existing.note = note
                            store.update(existing)
                        } else {
                            store.add(title: t, metric: Int(metric), tag: tag, note: note)
                        }
                        dismiss()
                    }
                    .accessibilityIdentifier("entrySaveButton")
                }
            }
            .onAppear {
                if let entry {
                    title = entry.title
                    metric = Double(entry.metric)
                    tag = entry.tag
                    note = entry.note
                }
            }
        }
    }
}
