import SwiftUI
import FirebaseCore
import FirebaseDatabase

@main
struct NotesLabApp: App {
    @StateObject private var appState = AppState()

    init() {
        FirebaseApp.configure()
        // ВАЖНО: включать офлайн-кэш ДО первого использования Database
        Database.database().isPersistenceEnabled = true
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}
