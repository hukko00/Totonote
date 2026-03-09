import SwiftUI
import SwiftData

@main
struct TotonoteApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: TodoItem.self)
    }
}
