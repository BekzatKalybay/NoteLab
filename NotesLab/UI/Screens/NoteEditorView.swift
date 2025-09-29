import SwiftUI

struct NoteEditorView: View {
    var note: Note?
    var onSave: (Note) -> Void
    
    @Environment(\ .dismiss) private var dismiss
    @State private var title: String = ""
    @State private var bodyText: String = ""
    @State private var isPinned: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                TextField("Body", text: $bodyText, axis: .vertical)
                    .lineLimit(3...8)
                Toggle("Pinned", isOn: $isPinned)
            }
            .navigationTitle(note == nil ? "New Note" : "Edit Note")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel", action: { dismiss() }) }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let n = Note(id: note?.id ?? UUID().uuidString,
                                     title: title.isEmpty ? "(untitled)" : title,
                                     body: bodyText,
                                     updatedAt: .init(),
                                     isPinned: isPinned)
                        onSave(n); dismiss()
                    }
                }
            }
            .onAppear {
                if let n = note { title = n.title; bodyText = n.body; isPinned = n.isPinned }
            }
        }
    }
}
