import SwiftUI

struct NotesListView: View {
    @EnvironmentObject private var app: AppState
    @State private var search = ""
    @State private var notes: [Note] = []
    @State private var isPresentingEditor = false
    @State private var editing: Note? = nil
    
    var body: some View {
        NavigationStack {
            List(filteredNotes()) { note in
                Button {
                    editing = note
                    isPresentingEditor = true
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(note.title).font(.headline)
                            Text(note.body)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                        Spacer()
                        if note.isPinned { Image(systemName: "pin.fill") }
                    }
                }
                .swipeActions {
                    Button(role: .destructive) { delete(note) } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    Button { togglePin(note) } label: {
                        Label("Pin", systemImage: "pin")
                    }
                }
            }
            .searchable(text: $search)
            .navigationTitle("Notes (\(app.storage.title))") // один Text -> нет ошибки
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        editing = nil
                        isPresentingEditor = true
                    } label: { Image(systemName: "plus") }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: reload) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .sheet(isPresented: $isPresentingEditor) {
                NoteEditorView(note: editing, onSave: upsert)
                    .presentationDetents([.medium, .large])
            }
            .onAppear(perform: reload)

            .sheet(isPresented: $isPresentingEditor) {
                NoteEditorView(note: editing, onSave: upsert)
                    .presentationDetents([.medium, .large])
            }
            .onAppear {
                reload()
                // Если выбран RTDB — подключим realtime
                if let rtdb = app.repository as? RTDBNotesRepository {
                    rtdb.observeAll { newNotes in
                        notes = newNotes
                    }
                }
            }
            .onDisappear {
                if let rtdb = app.repository as? RTDBNotesRepository {
                    rtdb.stopObserving()
                }
            }
            // + можно реагировать на смену стораджа:
            .onChange(of: app.storage) { _, newValue in
                if let rtdb = app.repository as? RTDBNotesRepository, newValue == .rtdb {
                    rtdb.observeAll { notes = $0 }
                } else {
                    if let rtdb = app.repository as? RTDBNotesRepository { rtdb.stopObserving() }
                    reload()
                }
            }
        }
    }
    
    // MARK: - Actions / Helpers
    
    private func filteredNotes() -> [Note] {
        guard !search.isEmpty else { return notes }
        return notes.filter {
            $0.title.localizedCaseInsensitiveContains(search) ||
            $0.body.localizedCaseInsensitiveContains(search)
        }
    }
    
    private func reload() {
        do {
            notes = try app.repository.getAll(search: search, limit: nil)
        } catch {
            print("Reload error: \(error)")
        }
    }
    
    private func upsert(_ n: Note) {
        do {
            if notes.contains(where: { $0.id == n.id }) {
                try app.repository.update(n)
            } else {
                try app.repository.create(n)
            }
            reload()
        } catch {
            print("Upsert error: \(error)")
        }
    }
    
    private func delete(_ n: Note) {
        do {
            try app.repository.delete(id: n.id)
            reload()
        } catch {
            print("Delete error: \(error)")
        }
    }
    
    private func togglePin(_ n: Note) {
        var m = n
        m.isPinned.toggle()
        m.updatedAt = .init()
        upsert(m)
    }
    
}
