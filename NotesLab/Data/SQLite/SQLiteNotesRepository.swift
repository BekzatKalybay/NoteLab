import Foundation
import SQLite3

final class SQLiteNotesRepository: NotesRepository {
    private var db: OpaquePointer?
    
    init() throws {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let url = dir.appendingPathComponent("notes.sqlite")
        if sqlite3_open(url.path, &db) != SQLITE_OK { throw NSError(domain: "SQLiteOpen", code: 1) }
        try exec("""
CREATE TABLE IF NOT EXISTS notes (
id TEXT PRIMARY KEY,
title TEXT NOT NULL,
body TEXT NOT NULL,
updatedAt REAL NOT NULL,
isPinned INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_notes_updatedAt ON notes(updatedAt);
""")
    }
    
    deinit { sqlite3_close(db) }
    
    func create(_ n: Note) throws {
        let sql = "INSERT OR REPLACE INTO notes(id,title,body,updatedAt,isPinned) VALUES(?,?,?,?,?)"
        let stmt = try prepare(sql)
        defer { sqlite3_finalize(stmt) }
        bindText(stmt, 1, n.id)
        bindText(stmt, 2, n.title)
        bindText(stmt, 3, n.body)
        sqlite3_bind_double(stmt, 4, n.updatedAt.timeIntervalSince1970)
        sqlite3_bind_int(stmt, 5, n.isPinned ? 1 : 0)
        guard sqlite3_step(stmt) == SQLITE_DONE else { throw lastError("insert") }
    }
    
    func get(id: String) throws -> Note? {
        let sql = "SELECT id,title,body,updatedAt,isPinned FROM notes WHERE id=? LIMIT 1"
        let stmt = try prepare(sql)
        defer { sqlite3_finalize(stmt) }
        bindText(stmt, 1, id)
        if sqlite3_step(stmt) == SQLITE_ROW { return rowToNote(stmt) }
        return nil
    }
    
    func getAll(search: String?, limit: Int?) throws -> [Note] {
        var res: [Note] = []
        var sql = "SELECT id,title,body,updatedAt,isPinned FROM notes"
        if let s = search, !s.isEmpty { sql += " WHERE title LIKE ? OR body LIKE ?" }
        sql += " ORDER BY updatedAt DESC"
        if let l = limit { sql += " LIMIT \(l)" }
        let stmt = try prepare(sql)
        defer { sqlite3_finalize(stmt) }
        if let s = search, !s.isEmpty {
            bindText(stmt, 1, "%\(s)%"); bindText(stmt, 2, "%\(s)%")
        }
        while sqlite3_step(stmt) == SQLITE_ROW { res.append(rowToNote(stmt)) }
        return res
    }
    
    func update(_ n: Note) throws { try create(n) }
    
    func delete(id: String) throws {
        let stmt = try prepare("DELETE FROM notes WHERE id=?")
        defer { sqlite3_finalize(stmt) }
        bindText(stmt, 1, id)
        guard sqlite3_step(stmt) == SQLITE_DONE else { throw lastError("delete") }
    }
    
    func deleteAll() throws { try exec("DELETE FROM notes;") }
    
    // MARK: - Helpers
    private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    private func prepare(_ sql: String) throws -> OpaquePointer? {
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) != SQLITE_OK {
            throw lastError("prepare")
        }
        return stmt
    }
    
    private func bindText(_ stmt: OpaquePointer?, _ idx: Int32, _ text: String) {
        sqlite3_bind_text(stmt, idx, text, -1, SQLITE_TRANSIENT)
    }
    
    private func rowToNote(_ stmt: OpaquePointer?) -> Note {
        let id = String(cString: sqlite3_column_text(stmt, 0))
        let title = String(cString: sqlite3_column_text(stmt, 1))
        let body = String(cString: sqlite3_column_text(stmt, 2))
        let ts = sqlite3_column_double(stmt, 3)
        let isPinned = sqlite3_column_int(stmt, 4) == 1
        return Note(
            id: id,
            title: title,
            body: body,
            updatedAt: Date(timeIntervalSince1970: ts),
            isPinned: isPinned
        )
    }
    
    private func lastError(_ op: String) -> NSError {
        let msg = String(cString: sqlite3_errmsg(db))
        return NSError(
            domain: "SQLite.\(op)",
            code: Int(sqlite3_errcode(db)),
            userInfo: [NSLocalizedDescriptionKey: msg]
        )
    }
    
    private func exec(_ sql: String) throws {
        var err: UnsafeMutablePointer<Int8>? = nil
        if sqlite3_exec(db, sql, nil, nil, &err) != SQLITE_OK {
            let msg = String(cString: err!)
            sqlite3_free(err)
            throw NSError(domain: "SQLiteExec", code: 2,
                          userInfo: [NSLocalizedDescriptionKey: msg])
        }
    }
}
