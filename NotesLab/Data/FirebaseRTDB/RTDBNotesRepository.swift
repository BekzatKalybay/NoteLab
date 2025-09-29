import Foundation
import FirebaseDatabase

final class RTDBNotesRepository: NotesRepository {
    init() {}
    
    private let ref = Database.database().reference().child("notes")
    private var handle: DatabaseHandle?
    
    // MARK: CRUD
    
    func create(_ note: Note) throws {
        let dict: [String: Any] = [
            "id": note.id,
            "title": note.title,
            "body": note.body,
            "updatedAt": note.updatedAt.timeIntervalSince1970,
            "isPinned": note.isPinned
        ]
        ref.child(note.id).setValue(dict)
    }
    
    func get(id: String) throws -> Note? {
        let sem = DispatchSemaphore(value: 1)
        var result: Note?
        ref.child(id).getData { error, snap in
            defer { sem.signal() }
            guard error == nil, let v = snap?.value as? [String: Any] else { return }
            result = Self.map(v)
        }
        sem.wait()
        return result
    }
    
    func getAll(search: String?, limit: Int?) throws -> [Note] {
        let sem = DispatchSemaphore(value: 1)
        var arr: [Note] = []
        // Берём всю ветку, сортируем/фильтруем локально — просто и надёжно для демо
        ref.observeSingleEvent(of: .value) { snap in
            defer { sem.signal() }
            guard let dict = snap.value as? [String: Any] else { return }
            for (_, any) in dict {
                if let d = any as? [String: Any], let n = Self.map(d) { arr.append(n) }
            }
            if let s = search, !s.isEmpty {
                arr = arr.filter { $0.title.localizedCaseInsensitiveContains(s) ||
                    $0.body.localizedCaseInsensitiveContains(s) }
            }
            arr.sort { $0.updatedAt > $1.updatedAt }
            if let l = limit { arr = Array(arr.prefix(l)) }
        }
        sem.wait()
        return arr
    }
    
    func update(_ note: Note) throws { try create(note) }
    
    func delete(id: String) throws { ref.child(id).removeValue() }
    
    func deleteAll() throws { ref.removeValue() }
    
    // MARK: Realtime observe (для UI). Не в протоколе — используем через каст.
    
    func observeAll(_ onChange: @escaping ([Note]) -> Void) {
        stopObserving()
        handle = ref.observe(.value) { snap in
            var arr: [Note] = []
            if let dict = snap.value as? [String: Any] {
                for (_, any) in dict {
                    if let d = any as? [String: Any], let n = Self.map(d) { arr.append(n) }
                }
            }
            arr.sort { $0.updatedAt > $1.updatedAt }
            onChange(arr)
        }
    }
    
    func stopObserving() {
        if let h = handle {
            ref.removeObserver(withHandle: h)
            handle = nil
        }
    }
    
    // MARK: - Mapping
    
    private static func map(_ v: [String: Any]) -> Note? {
        guard let id = v["id"] as? String,
              let title = v["title"] as? String,
              let body = v["body"] as? String,
              let ts = v["updatedAt"] as? TimeInterval,
              let isPinned = v["isPinned"] as? Bool else { return nil }
        return Note(id: id, title: title, body: body,
                    updatedAt: Date(timeIntervalSince1970: ts), isPinned: isPinned)
    }
}
