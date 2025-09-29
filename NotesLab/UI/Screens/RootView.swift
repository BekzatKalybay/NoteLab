import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            NotesListView()
                .tabItem { Label("Notes", systemImage: "note.text") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}
