import CoreData

enum CoreDataStack {
    static let container: NSPersistentContainer = {
        let c = NSPersistentContainer(name: "NotesModel")
        let d = c.persistentStoreDescriptions.first
        d?.shouldMigrateStoreAutomatically = true
        d?.shouldInferMappingModelAutomatically = true
        c.loadPersistentStores { _, error in
            if let error = error { fatalError("CoreData load error: \(error)") }
        }
        return c
    }()
}
