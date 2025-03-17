import SwiftUI
import SwiftData

struct DictionaryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let word: String
    @Binding var definition: String
    @State private var notes: String = ""
    @State private var isSaved = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                // Word display
                Text(word)
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                
                // Definition
                VStack(alignment: .leading) {
                    Text("Definition:")
                        .font(.headline)
                    Text(definition)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                
                // Notes
                VStack(alignment: .leading) {
                    Text("Your Notes:")
                        .font(.headline)
                    
                    TextEditor(text: $notes)
                        .padding(4)
                        .frame(minHeight: 100)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                
                // Save button
                Button(action: saveWord) {
                    HStack {
                        Image(systemName: isSaved ? "checkmark.circle.fill" : "plus.circle.fill")
                        Text(isSaved ? "Saved" : "Save to Learning")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isSaved ? Color.green.opacity(0.3) : Color.blue)
                    .foregroundColor(isSaved ? .black : .white)
                    .cornerRadius(10)
                }
                .disabled(isSaved)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Dictionary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveWord() {
        // Create a new vocabulary word and save it
        let newWord = VocabularyWord(word: word, definition: definition, notes: notes.isEmpty ? nil : notes)
        modelContext.insert(newWord)
        
        isSaved = true
    }
}

#Preview {
    DictionaryView(word: "Sample", definition: .constant("A small part or quantity intended to show what the whole is like."))
}