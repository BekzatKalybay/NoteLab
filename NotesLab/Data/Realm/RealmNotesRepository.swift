import Foundation
import RealmSwift

final class NoteObject: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var title: String = ""
    @Persisted var body: String = ""
    @Persisted var updatedAt: Date = .init()
    @Persisted var isPinned: Bool = false
}

final class RealmNotesRepository: NotesRepository {
    private let realm: Realm
    
    init() throws {
        let config = Realm.Configuration(schemaVersion: 1)
        Realm.Configuration.defaultConfiguration = config
        self.realm = try Realm()
    }
    
    func create(_ note: Note) throws {
        try realm.write {
            realm.add(NoteObject(value: [
                "id": note.id,
                "title": note.title,
                "body": note.body,
                "updatedAt": note.updatedAt,
                "isPinned": note.isPinned
            ]), update: .modified)
        }
    }
    
    func get(id: String) throws -> Note? {
        guard let o = realm.object(ofType: NoteObject.self, forPrimaryKey: id) else { return nil }
        return map(o)
    }
    
    func getAll(search: String?, limit: Int?) throws -> [Note] {
        var results = realm.objects(NoteObject.self)
        if let s = search, !s.isEmpty {
            results = results.where { $0.title.contains(s) || $0.body.contains(s) }
        }
        results = results.sorted(byKeyPath: "updatedAt", ascending: false)
        let arr = Array(results.prefix(limit ?? Int.max))
        return arr.map(map)
    }
    
    func update(_ note: Note) throws { try create(note) }
    
    func delete(id: String) throws {
        if let o = realm.object(ofType: NoteObject.self, forPrimaryKey: id) {
            try realm.write { realm.delete(o) }
        }
    }
    
    func deleteAll() throws {
        try realm.write { realm.delete(realm.objects(NoteObject.self)) }
    }
    
    private func map(_ o: NoteObject) -> Note {
        .init(id: o.id, title: o.title, body: o.body, updatedAt: o.updatedAt, isPinned: o.isPinned)
    }
}
