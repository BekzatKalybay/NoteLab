import Foundation

enum StorageKind: String, CaseIterable, Identifiable {
    case realm, coreData, sqlite, rtdb

    var id: String { rawValue }

    var title: String {
        switch self {
        case .realm: return "Realm"
        case .coreData: return "Core Data"
        case .sqlite: return "SQLite"
        case .rtdb: return "Firebase RTDB"
        }
    }
}
