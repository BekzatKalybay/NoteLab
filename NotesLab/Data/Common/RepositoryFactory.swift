enum RepositoryFactory {
    static func make(kind: StorageKind) throws -> NotesRepository {
        switch kind {
        case .realm:    return try RealmNotesRepository()
        case .coreData: return try CoreDataNotesRepository()
        case .sqlite:   return try SQLiteNotesRepository()
        case .rtdb:     return RTDBNotesRepository()
        }
    }
}
