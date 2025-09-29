import Foundation
import CoreData

final class CoreDataNotesRepository: NotesRepository {
    private let ctx: NSManagedObjectContext
    
    // Инициализация стека — берём viewContext из NSPersistentContainer
    init() throws {
        self.ctx = CoreDataStack.container.viewContext
    }
    
    // MARK: - CRUD
    
    func create(_ note: Note) throws {
        let e = NoteEntity(context: ctx)
        e.id = note.id
        e.title = note.title
        e.body = note.body
        e.updatedAt = note.updatedAt
        e.isPinned = note.isPinned
        try ctx.save()
    }
    
    func get(id: String) throws -> Note? {
        let r = NSFetchRequest<NoteEntity>(entityName: "NoteEntity")
        r.fetchLimit = 1
        r.predicate = NSPredicate(format: "id == %@", id)
        let res = try ctx.fetch(r).first
        return res.map(map)
    }
    
    // ⚠️ Обрати внимание: сигнатура должна совпасть с протоколом
    // func getAll(search: String?, limit: Int?) throws -> [Note]
    func getAll(search: String?, limit: Int?) throws -> [Note] {
        let r = NSFetchRequest<NoteEntity>(entityName: "NoteEntity")
        
        if let s = search, !s.isEmpty {
            r.predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR body CONTAINS[cd] %@", s, s)
        } else {
            r.predicate = nil
        }
        
        r.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        if let limit = limit { r.fetchLimit = limit }
        
        let res = try ctx.fetch(r)
        return res.map(map)
    }
    
    func update(_ note: Note) throws {
        let r = NSFetchRequest<NoteEntity>(entityName: "NoteEntity")
        r.fetchLimit = 1
        r.predicate = NSPredicate(format: "id == %@", note.id)
        if let e = try ctx.fetch(r).first {
            e.title = note.title
            e.body = note.body
            e.updatedAt = note.updatedAt
            e.isPinned = note.isPinned
            try ctx.save()
        }
    }
    
    func delete(id: String) throws {
        let r = NSFetchRequest<NoteEntity>(entityName: "NoteEntity")
        r.fetchLimit = 1
        r.predicate = NSPredicate(format: "id == %@", id)
        if let e = try ctx.fetch(r).first {
            ctx.delete(e)
            try ctx.save()
        }
    }
    
    func deleteAll() throws {
        let r = NSFetchRequest<NSFetchRequestResult>(entityName: "NoteEntity")
        let del = NSBatchDeleteRequest(fetchRequest: r)
        try ctx.execute(del)
        try ctx.save()
    }
    
    // MARK: - Mapping
    
    private func map(_ e: NoteEntity) -> Note {
        Note(
            id: e.id ?? UUID().uuidString,
            title: e.title ?? "",
            body: e.body ?? "",
            updatedAt: e.updatedAt ?? .init(),
            isPinned: e.isPinned
        )
    }
}
