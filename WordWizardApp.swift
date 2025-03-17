import SwiftUI
import SwiftData

@main
struct WordWizardApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [VocabularyWord.self, ReadingSession.self])
    }
}