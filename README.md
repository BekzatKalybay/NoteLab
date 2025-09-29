# 📒 NotesLab

An educational iOS app built with **SwiftUI**, demonstrating data persistence with multiple database solutions:

- **SQLite**
- **Core Data**
- **Realm**
- **Firebase Realtime Database**

---

## 🎯 Purpose
The goal of this project is to explore and compare different persistence technologies on iOS.  
It provides implementations of CRUD operations (Create, Read, Update, Delete), basic performance tests, as well as approaches for migrations and synchronization.

---

🏗 Architecture
- **SwiftUI** for UI
- **AppState** manages the selected storage (`StorageKind`)
- **NotesRepository** protocol defines the storage interface
- Implementations:
  - `SQLiteNotesRepository`
  - `CoreDataNotesRepository`
  - `RealmNotesRepository`
  - `RTDBNotesRepository` (Firebase)

---

📂 Project Structure
NotesLab/
├── App/
│ ├── NotesLabApp.swift
│ └── AppState.swift
├── Data/
│ ├── Common/ (protocols, factory)
│ ├── SQLite/
│ ├── CoreData/
│ ├── Realm/
│ └── FirebaseRTDB/
├── Models/ (Note.swift)
├── UI/
│ ├── NotesListView.swift
│ ├── NoteEditorView.swift
│ └── SettingsView.swift
└── Assets/


---

## 🚀 Getting Started

### 1. Clone the project
```bash
git clone https://github.com/yourname/NotesLab.git
cd NotesLab
```
### 2. Dependencies
This project uses Swift Package Manager:
Realm → https://github.com/realm/realm-swift
Firebase iOS SDK → https://github.com/firebase/firebase-ios-sdk
Xcode will resolve these automatically.
### 3. Firebase Setup
To enable Firebase Realtime Database:
Create a project at Firebase Console.
Register your iOS app (Bundle ID = your app’s identifier from Xcode).
Download GoogleService-Info.plist and add it to the Xcode project (target NotesLab).
In Firebase Console, enable Realtime Database → Start in test mode (for development).
FirebaseApp.configure() is already called in NotesLabApp.swift.
## 🛠 Usage
Settings → choose storage backend (SQLite / Core Data / Realm / Firebase)
Notes List:
➕ add note
tap → edit note
swipe left → 🗑 delete
swipe left → 📌 pin/unpin
Firebase RTDB:
Realtime sync across devices
Offline support with automatic resync
🔑 CRUD Examples (Create)
SQLite
```bash
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
```
Core Data
```bash
func create(_ n: Note) throws {
    let entity = NoteEntity(context: ctx)
    entity.id = n.id
    entity.title = n.title
    entity.body = n.body
    entity.updatedAt = n.updatedAt
    entity.isPinned = n.isPinned
    try ctx.save()
}
```
Realm
```bash
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
```
📊 Comparison
Storage	Features	Migration	Sync
SQLite	Lightweight, full SQL control	manual	❌
Core Data	Apple-native, integrated with iOS	built-in	❌
Realm	Simple API, reactive collections	built-in	❌
Firebase	Cloud sync, offline cache	SDK-based	✅
📦 Requirements
iOS 15+
Xcode 15+
Swift 5.9+
📚 Extras
Add unit tests to benchmark CRUD performance across storages.
Configure Firebase security rules for production (restrict by user UID).
👨‍💻 Author
Project created for learning and interview demonstration.
Author: Bekzat Kalybayev
