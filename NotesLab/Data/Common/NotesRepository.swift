import Foundation

protocol NotesRepository {
    func create(_ note: Note) throws
    func get(id: String) throws -> Note?
    func getAll(search: String?, limit: Int?) throws -> [Note]
    func update(_ note: Note) throws
    func delete(id: String) throws
    func deleteAll() throws
}
