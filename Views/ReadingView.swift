import SwiftUI
import SwiftData

struct ReadingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var currentSession: ReadingSession?
    @State private var searchText = ""
    @State private var showingDictionary = false
    @State private var selectedWord = ""
    @State private var wordDefinition = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Reading time indicator
                    if let session = currentSession {
                        Text("Reading for: \(formatTimeInterval(session.duration))")
                            .font(.headline)
                            .padding()
                    }
                    
                    // Word search area
                    HStack {
                        TextField("Enter word to lookup", text: $searchText)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .disableAutocorrection(true)
                        
                        Button(action: lookupWord) {
                            Image(systemName: "magnifyingglass")
                                .font(.title2)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Placeholder for main reading area
                    Text("Your reading content appears here")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(15)
                        .padding()
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("Reading Mode")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(currentSession == nil ? "Start Reading" : "End Reading") {
                            toggleReadingSession()
                        }
                        .bold()
                        .foregroundColor(currentSession == nil ? .green : .red)
                    }
                }
                .sheet(isPresented: $showingDictionary) {
                    DictionaryView(word: selectedWord, definition: $wordDefinition)
                }
            }
            .onAppear {
                // Prevent screen from timing out
                UIApplication.shared.isIdleTimerDisabled = true
            }
            .onDisappear {
                // Allow screen to time out again
                UIApplication.shared.isIdleTimerDisabled = false
                
                // End current session if one exists
                if let session = currentSession {
                    session.endSession()
                    currentSession = nil
                }
            }
        }
    }
    
    private func lookupWord() {
        guard !searchText.isEmpty else { return }
        
        selectedWord = searchText
        // In a real implementation, we'd use UIReferenceLibraryViewController
        // or another dictionary API to look up the definition
        wordDefinition = "Sample definition for \(searchText)"
        showingDictionary = true
        
        searchText = ""
    }
    
    private func toggleReadingSession() {
        if let session = currentSession {
            // End the session
            session.endSession()
            currentSession = nil
        } else {
            // Start new session
            let newSession = ReadingSession()
            modelContext.insert(newSession)
            currentSession = newSession
        }
    }
    
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    ReadingView()
}