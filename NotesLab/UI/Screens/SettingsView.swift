import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var app: AppState
    @State private var seedCount: Int = 1000
    
    var body: some View {
        Form {
            Section("Storage") {
                Picker("Backend", selection: $app.storage) {
                    ForEach(StorageKind.allCases) { kind in
                        Text(kind.title).tag(kind)
                    }
                }
                .onChange(of: app.storage) { oldValue, newValue in
                    app.switchStorage(newValue)
                }
            }
            
            Section("Tools") {
                Stepper("Seed count: \(seedCount)", value: $seedCount, in: 100...10_000, step: 100)
                Button("Seed notes") { seed(seedCount) }
                Button("Wipe all", role: .destructive) { wipe() }
                Button("Benchmark (insert)") { benchmarkInsert(seedCount) }
            }
        }
        .navigationTitle("Settings")
    }
    
    private func seed(_ n: Int) {
        do {
            for i in 0..<n {
                try app.repository.create(Note(title: "Note #\(i)", body: String(repeating: "x", count: 64), isPinned: i % 10 == 0))
            }
        } catch { print("seed error: \(error)") }
    }
    private func wipe() {
        do { try app.repository.deleteAll() } catch { print("wipe error: \(error)") }
    }
    private func benchmarkInsert(_ n: Int) {
        let t0 = CFAbsoluteTimeGetCurrent()
        seed(n)
        let t1 = CFAbsoluteTimeGetCurrent()
        let ms = (t1 - t0) * 1000
        print("Insert \(n) notes: \(String(format: "%.1f", ms)) ms on \(app.storage.title)")
    }
}
