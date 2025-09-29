import Foundation
import Combine


final class AppState: ObservableObject {
    @Published var storage: StorageKind {
        didSet { UserDefaults.standard.set(storage.rawValue, forKey: "storage.kind") }
    }
    
    @Published private(set) var repository: NotesRepository
    
    init() {
        let raw = UserDefaults.standard.string(forKey: "storage.kind")
        let kind = StorageKind(rawValue: raw ?? "realm") ?? .realm
        self.storage = kind
        self.repository = try! RepositoryFactory.make(kind: kind)
    }
    
    func switchStorage(_ kind: StorageKind) {
        guard kind != storage else { return }
        storage = kind
        repository = try! RepositoryFactory.make(kind: kind)
        objectWillChange.send()
    }
}
